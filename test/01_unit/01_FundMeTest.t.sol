// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

/**
 Tests
 Unit => testing a specific piece of code
 Integration => testing how different pieces of code work together
 Forked => testing how your smart contract behaves on simlated real environment
 Staging => testing how your smart contract behaves on a real environment (but no prod)
**/

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    // Entry point, run before each test
    function setUp() external {
        // setup state
        // 1. fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // there : test contract deploy FundMe and so it's the owner
        // 2. Using DeployFundMe script to deploy FundMe contract
        // In the script the defUser is the sender
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        console.log(
            "HERHEHEHEHEHHEEHHEHE FundMe owner address: %s",
            fundMe.getOwner()
        );
        vm.deal(USER, STARTING_BALANCE);
    }

    // regular test : prefix with test
    function test_MinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function test_OwnerIsMsgSender() public {
        // assertEq(fundMe.i_owner(), address(this));
        // after refactoring : fundMe created by DeployFundMe script and caller is msg.sender
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function test_PriceFeedVersionIsAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function test_FundFailsWithoutEnoughEth() public {
        vm.expectRevert();

        fundMe.fund();
    }

    // failing test version : prefix with testFail
    function testFail_FundFailsWithoutEnoughEth() public {
        // vm.expectRevert();
        fundMe.fund();
    }

    function test_FundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function test_AddsFunderToArrayFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    // Branch tree testing (modifiers used to test different branches)
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
    // function testOnlyOwnerCanWithdraw() public {
    //     vm.prank(USER);
    //     fundMe.fund{value: SEND_VALUE}();

    //     vm.expectRevert();
    //     vm.prank(USER);
    //     fundMe.withdraw();
    // }
    function test_OnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function test_WithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());

        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Gas used: %s", gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    function test_WithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // to not send to 0 address (in case of sanity checks...)

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        // Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    function test_WithdrawFromMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // to not send to 0 address (in case of sanity checks...)

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        // Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
    }
}
