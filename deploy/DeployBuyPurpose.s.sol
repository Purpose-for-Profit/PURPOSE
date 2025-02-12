// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "lib/forge-std/src/Script.sol";
import {BuyPurpose} from "src/BuyPurpose.sol";  // Adjust the path if needed

contract DeployBuyPurpose is Script {
    function run() external {

        // Variables
        address PFP = 0x484A5C5Cd349876eF7B0291032e829Ec4385E49a;
        address USDC = 0x5dEaC602762362FE5f135FA5904351916053cF70;
        address oracle = 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1;
        
        // Start broadcasting the transaction
        vm.startBroadcast();

        // Deploy the PFPToken contract
        BuyPurpose dynamic = new BuyPurpose(PFP,USDC ,oracle);

        // Log the deployed contract address to verify the deployment
        console.log("PFPToken deployed at:", address(dynamic));

        // Stop broadcasting the transaction
        vm.stopBroadcast();
    }
}

