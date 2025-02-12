// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/forge-std/src/Script.sol";
import "src/ChainlinkOracle/LatestPriceFeedFlattened.sol"; 

contract DeployvPFPToken is Script {
    function run() external {

        vm.startBroadcast();
        DataConsumerV3 data = new DataConsumerV3();
        vm.stopBroadcast();

        console.log("vPFP Token deployed at:", address(data));
    }
}