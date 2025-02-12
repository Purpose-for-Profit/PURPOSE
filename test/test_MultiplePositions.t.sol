// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PurposeRewards.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Having multiple positions amongst tiers is apart of the Tokenomics;

contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, 1_000_000_000 ether);
    }
}

contract MultiplePositions is Test {
    PurposeRewards public rewards;
    MockToken public token;
    address public bob = address(0x1);
    address public alice = address(0x2);
    address public owner;

    function setUp() public {
        token = new MockToken();
        rewards = new PurposeRewards(address(token));
        owner = address(this);

        // Fund users
        token.transfer(bob, 2_000_000 ether);
        token.transfer(alice, 2_000_000 ether);
    }

    function test_MultiplePositions() public {
        // Fill Tier 0 completely with Alice
        vm.startPrank(alice);
        token.approve(address(rewards), 2_000_000 ether);
        rewards.stake(2_000_000 ether); // Fill Tier 0
        vm.stopPrank();

        // Now Bob has to stake in Tier 1
        vm.startPrank(bob);
        token.approve(address(rewards), 100_000 ether);
        rewards.stake(100_000 ether); // This must go to Tier 1
        vm.stopPrank();

        console.log("\nInitial Stakes:");
        console.log("Alice Tier 0: ", rewards.getUserTierStake(alice, 0));
        console.log("Bob Tier 1: ", rewards.getUserTierStake(bob, 1));

        // Have Alice unstake most tokens
        vm.startPrank(alice);
        rewards.unstake(0, 1_900_000 ether);
        vm.stopPrank();

        console.log("\nAfter Alice Unstakes:");
        console.log("Alice Tier 0: ", rewards.getUserTierStake(alice, 0));
        console.log("Bob Tier 1: ", rewards.getUserTierStake(bob, 1));
        console.log("Tier 0 space available: ", 2_000_000 ether - rewards.getUserTierStake(alice, 0));

        // Now Bob stakes again
        console.log("\nBob Stakes Again...");
        vm.startPrank(bob);
        token.approve(address(rewards), 100_000 ether);
        rewards.stake(100_000 ether);
        vm.stopPrank();

        console.log("\nFinal Stakes:");
        console.log("Bob Tier 0: ", rewards.getUserTierStake(bob, 0));
        console.log("Bob Tier 1: ", rewards.getUserTierStake(bob, 1));

        // Check tier status
        (, uint256 tier0Staked) = rewards.getTierInfo(0);
        console.log("\nTier Status:");
        console.log("Tier 0 total staked: ", tier0Staked);
        console.log("Current tier index: ", rewards.currentTierIndex());
    }
}
