// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeTestInteractions is Test {
    FundMe fundMe;

    address USER = makeAddr("USER");
    address defUSER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // setup state
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
        vm.deal(defUSER, STARTING_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }

    function test_UserCanFundInteraction() public {
        // Arrange
        uint256 fundMeBalanceBefore = address(fundMe).balance;
        uint256 userBalanceBefore = address(USER).balance;

        // Act
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        uint256 fundMeBalanceAfter = address(fundMe).balance;
        uint256 fundMeBalanceDiff = fundMeBalanceAfter - fundMeBalanceBefore;
        uint256 userBalanceAfter = address(USER).balance;
        // Assert
        assertEq(fundMeBalanceDiff, SEND_VALUE);
        assertEq(userBalanceBefore - userBalanceAfter, SEND_VALUE);
    }

    function test_OwnerCanWithdrawInteraction() public {
        // Arrange
        address owner = fundMe.getOwner();
        uint256 ownerBalanceBefore = address(owner).balance;
        uint256 fundMeBalanceBefore = address(fundMe).balance;
        console.log("owner address: %s", owner);
        console.log("owner balance: %s", ownerBalanceBefore);
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
        console.log("owner balance after funding: %s", address(owner).balance);
        // uint256 ownerBalanceAfterFunding = address(owner).balance;
        // uint256 balanceSentByOwner = ownerBalanceAfterFunding -
        //     ownerBalanceBefore;
        uint256 fundMeBalanceAfterFunding = address(fundMe).balance;
        uint256 fundingBalance = fundMeBalanceAfterFunding -
            fundMeBalanceBefore;

        uint256 ownerBalanceBeforeWithdrawing = address(owner).balance;
        // Act
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        console.log(
            "owner balance after whithdrawal: %s",
            address(owner).balance
        );
        console.log(
            "Fundme balance after whithdrawal: %s",
            address(fundMe).balance
        );
        uint256 ownerBalanceAfterWithdrawing = address(owner).balance;
        uint256 balanceReceivedByOwner = ownerBalanceAfterWithdrawing -
            ownerBalanceBeforeWithdrawing;
        uint256 fundMeBalanceAfterWithdrawing = address(fundMe).balance;
        uint256 withdrawalBalance = fundMeBalanceAfterFunding -
            fundMeBalanceAfterWithdrawing;

        // Assert
        assertEq(fundingBalance, SEND_VALUE, "fundingBalance");
        // assertEq(withdrawalBalance, SEND_VALUE);
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

    // function test_OwnerWithdrawAllBalanceInteraction() public {
    //     // Arrange
    //     uint256 fundMeBalanceBefore = address(fundMe).balance;
    //     FundFundMe fundFundMe = new FundFundMe();
    //     fundFundMe.fundFundMe(address(fundMe));

    //     uint256 fundMeBalanceAfterFunding = address(fundMe).balance;
    //     uint256 fundingBalance = fundMeBalanceAfterFunding -
    //         fundMeBalanceBefore;

    //     // Act
    //     WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
    //     withdrawFundMe.withdrawFundMe(address(fundMe));

    //     uint256 fundMeBalanceAfterWithdrawing = address(fundMe).balance;
    //     uint256 withdrawalBalance = fundMeBalanceAfterFunding -
    //         fundMeBalanceAfterWithdrawing;

    //     // Assert
    //     assertEq(fundingBalance, SEND_VALUE);
    //     assertEq(withdrawalBalance, SEND_VALUE);
    //     assertEq(fundMeBalanceAfterWithdrawing, 0);
    // }

    function test_UserCanFundInteraction2() public {
        FundFundMe fundFundMe = new FundFundMe();
        // vm.prank(USER);
        // vm.deal(USER, STARTING_BALANCE);
        console.log("USER address: %s", USER);
        console.log("USER balance: %s", address(USER).balance);
        console.log("msg.sender address: %s", msg.sender);
        console.log("msg.sender balance: %s", address(msg.sender).balance);
        console.log("address this: %s", address(this));
        console.log("FundME balance: %s", address(fundMe).balance);

        fundFundMe.fundFundMe(address(fundMe));

        address funder = fundMe.getFunder(0);
        console.log("defUSER balance: %s", address(defUSER).balance);
        console.log("USER balance: %s", address(USER).balance);
        console.log("FundME balance: %s", address(fundMe).balance);

        assertEq(funder, address(this));
        // assertEq(funder, USER); //ok si startBroadcast(USER)

        // assertEq(funder, defUSER);
        // assertEq(funder, msg.sender);
    }
}
