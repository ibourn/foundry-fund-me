// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe} from "../../script/Interactions.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;

    address USER = makeAddr("USER");
    address defUSER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000 or 10^17
    uint256 constant STARTING_BALANCE = 10 ether; // 10000000000000000000 or 10^19
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // setup state
        // number = 2;
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
        vm.deal(defUSER, STARTING_BALANCE);
    }

    function testUserCanFundInteraction() public {
        FundFundMe fundFundMe = new FundFundMe();
        // vm.prank(USER);
        // vm.deal(USER, STARTING_BALANCE);
        console.log("USER address: %s", USER);
        console.log("USER balance: %s", address(USER).balance);
        console.log("msg.sender address: %s", msg.sender);
        console.log("msg.sender balance: %s", address(msg.sender).balance);
        console.log("address this: %s", address(this));

        fundFundMe.fundFundMe(address(fundMe));

        address funder = fundMe.getFunder(0);
        // assertEq(funder, USER);
        assertEq(funder, defUSER);
        // assertEq(funder, msg.sender);
    }
}
