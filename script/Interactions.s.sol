// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    // function fundFundMe(address mostRecentDeployed) public {
    //     console.log("FundFundMe / msg.sender: %s", msg.sender);
    //     console.log(
    //         "FundFundeMe / sender balance: %s",
    //         address(msg.sender).balance
    //     );
    //     vm.startBroadcast();
    //     FundMe(payable(mostRecentDeployed)).fund{value: SEND_VALUE}();
    //     vm.stopBroadcast();
    //     console.log("Funded FundMe contract with %s", SEND_VALUE);
    // }

    function fundFundMe(address mostRecentDeployed) public {
        address USER = makeAddr("USER");
        console.log("FundFundMe / msg.sender: %s", msg.sender);
        console.log(
            "FundFundeMe / sender balance: %s",
            address(msg.sender).balance
        );
        vm.startBroadcast();
        // vm.startBroadcast(address(USER));
        console.log(
            "FundMe balance Before interaction %s",
            address(mostRecentDeployed).balance
        );
        console.log("FundFundMe / origin address: %s", tx.origin);
        console.log("FundFundMe / 2nd msg.sender: %s", msg.sender);
        FundMe(payable(mostRecentDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe contract with %s", SEND_VALUE);
        console.log("FundMe address: %s", mostRecentDeployed);
        console.log("FundMe balance: %s", address(mostRecentDeployed).balance);
        console.log(
            "FundFundeMe / sender balance: %s",
            address(msg.sender).balance
        );
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        // vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        // vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function withdrawFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).withdraw();
        vm.stopBroadcast();
        console.log(
            "FundMe owner address: %s",
            FundMe(payable(mostRecentDeployed)).getOwner()
        );
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentlyDeployed);
    }
}
