// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeTestInteractions is Test {
    FundMe fundMe;

    // address USER = makeAddr("USER");
    address DEF_USER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // setup state
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // vm.deal(USER, STARTING_BALANCE);
        vm.deal(DEF_USER, STARTING_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }

    function test_SendValueShouldEqualBalancesDiff_WhenUserFund() public {
        FundFundMe fundFundMe = new FundFundMe();
        uint256 fundMeBalanceBefore = address(fundMe).balance;
        uint256 defUserBalanceBefore = address(DEF_USER).balance;
        // vm.prank(USER);
        // vm.deal(USER, STARTING_BALANCE);
        // ⚠️ prank & broadcast are not compatible !
        // i.e. prank in test and call a script with broadcast is not possible
        // => defUser will be the sender
        console.log("DEF_USER address: %s", DEF_USER);
        console.log("DEF_USER balance before: %s", defUserBalanceBefore);
        console.log("FundME balance before: %s", fundMeBalanceBefore);

        fundFundMe.fundFundMe(address(fundMe));

        uint256 defUserBalanceAfter = DEF_USER.balance;
        uint256 amountSent = defUserBalanceBefore - defUserBalanceAfter;
        uint256 fundMeBalanceAfter = address(fundMe).balance;
        uint256 amountReceived = fundMeBalanceAfter - fundMeBalanceBefore;

        console.log("DEF_USER balance after: %s", defUserBalanceAfter);
        console.log("FundME balance after: %s", fundMeBalanceAfter);
        assertEq(amountReceived, amountSent);
        assertEq(amountReceived, SEND_VALUE);
    }

    function test_ShouldSetDefUserAsFunder_WhenUserFund() public {
        FundFundMe fundFundMe = new FundFundMe();

        fundFundMe.fundFundMe(address(fundMe));

        address funder = fundMe.getFunder(0);
        console.log("funder address: %s", funder);
        assertEq(funder, DEF_USER);
    }

    function test_ShouldSendFundMeBalanceToOwner_WhenWhithdraw() public {
        // Arrange
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        address owner = fundMe.getOwner();
        uint256 fundMeBalanceAfterFunding = address(fundMe).balance;
        uint256 ownerBalanceBeforeWithdrawing = address(owner).balance;

        // Act
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        // Assert
        uint256 fundMeBalanceAfterWithdrawing = address(fundMe).balance;
        uint256 ownerBalanceAfterWithdrawing = address(owner).balance;
        uint256 balanceReceivedByOwner = ownerBalanceAfterWithdrawing -
            ownerBalanceBeforeWithdrawing;
        assertEq(
            fundMeBalanceAfterWithdrawing,
            0,
            "fundMeBalanceAfterWithdrawing"
        );
        assertEq(
            balanceReceivedByOwner,
            fundMeBalanceAfterFunding,
            "balanceReceivedByOwner"
        );
    }
}
