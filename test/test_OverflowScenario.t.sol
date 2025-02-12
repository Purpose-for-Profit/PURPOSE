// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PurposeRewards.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockPurposeToken is ERC20 {
    constructor() ERC20("Purpose", "PURPOSE") {
        _mint(msg.sender, 1000000000 ether);
    }
}

contract PurposeRewardsTest is Test {
    PurposeRewards public purposeRewards;
    MockPurposeToken public purposeToken;

    address public owner = address(1);
    address public account1 = address(2);
    address public account2 = address(3);

    function setUp() public {
        vm.startPrank(owner);
        purposeToken = new MockPurposeToken();
        purposeRewards = new PurposeRewards(address(purposeToken));
        vm.stopPrank();
    }

    function logRewardInfo(uint256 tierId) internal view {
        (uint256 tierCap, uint256 currentStaked) = purposeRewards.getTierInfo(tierId);
        uint256 rewardRate = purposeRewards.getTierRewardRate(tierId);

        console.log("\n=== Distribution Info ===");
        console.log("Tier total staked:", currentStaked / 1e18);
        console.log("New reward rate:", rewardRate);

        // Log account1's info
        uint256 account1Stake = purposeRewards.getUserTierStake(account1, tierId);
        uint256 account1Pending = purposeRewards.getPendingRewards(account1, tierId);
        console.log("Account 1 stake:", account1Stake / 1e18);
        console.log("Account 1 pending rewards:", account1Pending / 1e18);
    }

    function testExactOperations() public {
        // Setup initial balances and approvals
        vm.startPrank(owner);
        purposeToken.transfer(account1, 5000 ether);
        purposeToken.transfer(account2, 8000 ether);
        vm.stopPrank();

        vm.startPrank(account1);
        purposeToken.approve(address(purposeRewards), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(account2);
        purposeToken.approve(address(purposeRewards), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(owner);
        purposeToken.approve(address(purposeRewards), type(uint256).max);
        vm.stopPrank();

        // 1. Account 1 stakes 4,567 PURPOSE
        vm.startPrank(account1);
        purposeRewards.stake(4567 ether);
        vm.stopPrank();

        // 2. Account 1 unstakes 228.35 PURPOSE
        vm.startPrank(account1);
        purposeRewards.unstake(0, 228.35 ether);
        vm.stopPrank();

        // 3. Account 2 stakes 7,890 PURPOSE
        vm.startPrank(account2);
        purposeRewards.stake(7890 ether);
        vm.stopPrank();

        //Owner distributes rewards multiple times
        vm.startPrank(owner);
        console.log("\n=== First Distribution Set ===");
        purposeRewards.distributeRewards(5678 ether);
        logRewardInfo(0);

        purposeRewards.distributeRewards(9101 ether);
        logRewardInfo(0);

        purposeRewards.distributeRewards(500 ether);
        logRewardInfo(0);
        vm.stopPrank();

        // Detailed checks:
        vm.startPrank(account1);
        console.log("\n=== Claiming Rewards ===");
        uint256 pendingBeforeClaim = purposeRewards.getPendingRewards(account1, 0);
        console.log("Pending rewards before claim:", pendingBeforeClaim / 1e18);

        // Add token balance check before claim
        uint256 balanceBefore = purposeToken.balanceOf(account1);
        console.log("Token balance before claim:", balanceBefore / 1e18);

        // Record RewardsClaimed event
        vm.recordLogs();
        purposeRewards.claimRewards(0);

        // Check token balance after claim
        uint256 balanceAfter = purposeToken.balanceOf(account1);
        console.log("Token balance after claim:", balanceAfter / 1e18);
        console.log("Balance difference:", (balanceAfter - balanceBefore) / 1e18);

        // Get the RewardsClaimed event
        Vm.Log[] memory entries = vm.getRecordedLogs();
        for (uint256 i = 0; i < entries.length; i++) {
            if (entries[i].topics[0] == keccak256("RewardsClaimed(address,uint256,uint256)")) {
                (uint256 tierId, uint256 amount) = abi.decode(entries[i].data, (uint256, uint256));
                console.log("Amount of rewards claimed from event:", amount / 1e18, "PURPOSE");
            }
        }

        // Check rewards after claim
        uint256 pendingAfterClaim = purposeRewards.getPendingRewards(account1, 0);
        console.log("Pending rewards after claim:", pendingAfterClaim / 1e18);
        vm.stopPrank();

        // Continue distributions
        vm.startPrank(owner);
        purposeRewards.distributeRewards(1234 ether);
        purposeRewards.distributeRewards(5678 ether);
        purposeRewards.distributeRewards(5678 ether);
        purposeRewards.distributeRewards(5678 ether);
        purposeRewards.distributeRewards(500 ether);
        purposeRewards.distributeRewards(456 ether);
        vm.stopPrank();

        // 14. Account 1 unstakes 216.93 PURPOSE
        vm.startPrank(account1);

        // Log current stakes and rewards
        (
            uint256[] memory stakesBeforeUnstake,
            uint256[] memory rewardsBeforeUnstake,
            uint256 totalStakedBefore,
            uint256 totalRewardsBefore
        ) = purposeRewards.getUserStakeInfo(account1);

        console.log("\n=== Debug Info Before Unstake ===");
        console.log("Current stake in tier 0:", stakesBeforeUnstake[0]);
        console.log("Pending rewards in tier 0:", rewardsBeforeUnstake[0]);
        console.log("Total staked:", totalStakedBefore);
        console.log("Total rewards pending:", totalRewardsBefore);

        // Get tier info
        (uint256 tierCap, uint256 tierCurrentStaked) = purposeRewards.getTierInfo(0);
        console.log("Tier 0 total staked:", tierCurrentStaked);
        console.log("Tier 0 cap:", tierCap);

        // Get reward rate
        uint256 currentRewardRate = purposeRewards.getTierRewardRate(0);
        console.log("Current reward rate:", currentRewardRate);

        console.log("\nAttempting to unstake 216.93 PURPOSE...");

        purposeRewards.unstake(0, 216.93 ether);

        console.log("Unstake successful!");
        vm.stopPrank();

        // 15. Account 1 unstakes 50 PURPOSE
        vm.startPrank(account1);
        purposeRewards.unstake(0, 50 ether);
        vm.stopPrank();

        // SHOULD REVERT: (seems to be fixed via the Math.sol library)
        vm.startPrank(account1);
        purposeRewards.stake(50 ether);
        vm.stopPrank();

        vm.startPrank(account1);
        (uint256[] memory stakes, uint256[] memory rewards, uint256 totalStaked, uint256 totalPendingRewards) =
            purposeRewards.getUserStakeInfo(account1);

        console.log("\n=== User Stake Information ===");
        for (uint256 i = 0; i < stakes.length; i++) {
            console.log(string.concat("Tier ", vm.toString(i), " Stake: ", vm.toString(stakes[i] / 1e18), " PURPOSE"));
            console.log(
                string.concat("Tier ", vm.toString(i), " Rewards: ", vm.toString(rewards[i] / 1e18), " PURPOSE")
            );
        }
        console.log(string.concat("Total Staked: ", vm.toString(totalStaked / 1e18), " PURPOSE"));
        console.log(string.concat("Total Rewards: ", vm.toString(totalPendingRewards / 1e18), " PURPOSE"));
        vm.stopPrank();

        for (uint256 i = 0; i <= purposeRewards.currentTierIndex(); i++) {
            uint256 tierRate = purposeRewards.getTierRewardRate(i);
            console.log("Tier", i, "Rate:", tierRate);
        }
    }
}
