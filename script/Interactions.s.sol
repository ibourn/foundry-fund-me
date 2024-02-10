// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentDeployed) public {
        console.log(
            "Interactions:FundFundMe / fundMe balance before interaction: %s",
            address(mostRecentDeployed).balance
        );
        console.log("Interactions:FundFundMe / msg.sender: %s", msg.sender);
        console.log("Interactions:FundFundMe / origin address: %s", tx.origin);
        // = defUSER : 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38

        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();

        console.log(
            "Interactions:FundFundMe / fundMe owner: %s",
            FundMe(mostRecentDeployed).getOwner()
        );
        console.log(
            "Interactions:FundFundMe / fundMe balance: %s",
            address(mostRecentDeployed).balance
        );
        console.log("Interactions:FundFundMe / amount sent : %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentDeployed) public {
        console.log(
            "Interactions:WithdrawFundMe / fundMe balance: %s",
            address(mostRecentDeployed).balance
        );

        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).withdraw();
        vm.stopBroadcast();

        console.log(
            "Interactions:WithdrawFundMe /FundMe owner address: %s",
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
