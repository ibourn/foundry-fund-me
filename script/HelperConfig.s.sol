// SPDX-License-Identifier: MIT

// Allows to manage many strategies : different networks, forks, mocks for testing.
// 1. Deploy mocks when on local network
// 2. Keep track of contract add across different networks

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8; // intial price of 2000 USD

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed.address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    // ! using console.log in a function will make it non-pure !
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        // console.log("HelperConfig : loading sepoliaConfig");
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        // console.log("HelperConfig : loading mainnetConfig");
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            console.log(
                "HelperConfig : loading activeNetworkConfig / address != 0"
            );
            return activeNetworkConfig;
        }
        //price feed address

        // 1. Deploy the mocks (contracts that we own)
        // 2. Return the address of the mock

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_ANSWER
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        // console.log("HelperConfig : loading anvilConfig");

        return anvilConfig;
    }
}
