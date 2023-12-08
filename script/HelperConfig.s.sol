// 1. Deploy mocks when we are on a local anvil chain.
// 2. Keep track of contract addresses across different chains.
// Example: Sepolia ETH/USD has different address
//          Mainnet ETH/USD has different address

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local anvil, we deploy mocks.
    // Otherwise, grab the existing addresses from the live networks.
    NetworkConfig public activeNetworkConfig;

    // Magic Numbers
    uint256 public constant ETH_CHAINID = 1;
    uint256 public constant SEPOLIA_CHAINID = 11155111;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == SEPOLIA_CHAINID) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == ETH_CHAINID) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    // Another example to work with different chains
    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    // Work with local chain "Anvil"
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // Without this, we actually will create a new price feed
        // If it's not address(0), it means we've already set it
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // price feed address

        // 1. Deploy the mocks (dummy contract)
        // 2. Return the mock addresses
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS, // = 8
            INITIAL_PRICE // = 2000e8
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
