// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    FundMe fundMe;

    // Entry point, base of the script
    function run() external returns (FundMe) {
        // Before broadcast => not a real tx (no gas)
        HelperConfig helperConfig = new HelperConfig();
        address ethusdPriceFeed = helperConfig.activeNetworkConfig();

        // After broadcast => real tx (uses gas)
        vm.startBroadcast();
        fundMe = new FundMe(ethusdPriceFeed);
        vm.stopBroadcast();
        // console.log("FundMe owner address: %s", fundMe.getOwner());
        return fundMe;
    }
}
