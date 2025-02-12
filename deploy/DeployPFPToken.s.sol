// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "lib/forge-std/src/Script.sol";

import {PFPToken} from "src/PFP.sol";  // Adjust the path if needed


contract DeployPFPToken is Script {
    function run() external {
        // Start broadcasting the transaction
        vm.startBroadcast();

        // Deploy the PFPToken contract
        PFPToken token = new PFPToken();

        // Log the deployed contract address to verify the deployment
        console.log("PFPToken deployed at:", address(token));

        // Stop broadcasting the transaction
        vm.stopBroadcast();
    }
}

