// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/PurposeRewardsFlattened.sol";

contract DeployTieredStaking is Script {

  function run() external {

    address PFP = 0x5deB4F836fB660bF4e0A9dc288C66a154967e1D8;

    vm.startBroadcast();

    PurposeRewards dynamic = new PurposeRewards(PFP);
 
    console.log("Deployed to:", address(dynamic));

    vm.stopBroadcast();

  }
}