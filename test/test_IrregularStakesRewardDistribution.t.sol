// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PurposeRewards.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, 1_000_000_000 ether);
    }
}

contract PurposeRewardsIrregularStakesTest is Test {
    PurposeRewards public rewards;
    MockToken public token;
    address public owner;
    address[] public stakers;
    uint256 constant NUM_STAKERS = 50;
    uint256 constant REWARD_AMOUNT = 1000 ether;

    uint256[] public stakedAmounts;
    uint256 public totalStaked;

    function setUp() public {
        token = new MockToken();
        rewards = new PurposeRewards(address(token));
        owner = address(this);

        // Initialize stakers with irregular amounts
        for (uint256 i = 0; i < NUM_STAKERS; i++) {
            address staker = address(uint160(0x1000 + i));
            stakers.push(staker);

            // Generate irregular amounts
            uint256 stakeAmount = uint256(keccak256(abi.encodePacked(block.timestamp, i))) % 900 ether;
            stakeAmount = stakeAmount + 100 ether;
            stakeAmount = stakeAmount + (uint256(keccak256(abi.encodePacked(i))) % 1000);

            stakedAmounts.push(stakeAmount);
            totalStaked += stakeAmount;

            token.transfer(staker, stakeAmount);
        }
    }

    function test_IrregularStakesRewardDistribution() public {
        // Log initial state
        console.log("\nTest Configuration:");
        console.log("Number of stakers:", NUM_STAKERS);
        console.log("Total staked:", totalStaked);
        console.log("Reward amount:", REWARD_AMOUNT);

        // Stake all amounts
        for (uint256 i = 0; i < NUM_STAKERS; i++) {
            vm.startPrank(stakers[i]);
            token.approve(address(rewards), stakedAmounts[i]);
            rewards.stake(stakedAmounts[i]);
            vm.stopPrank();
        }

        // Verify total staked amount
        (, uint256 currentStaked) = rewards.getTierInfo(0);
        assertEq(currentStaked, totalStaked, "Total staked amount mismatch");

        // Record balances before distribution
        uint256 contractBalanceBefore = token.balanceOf(address(rewards));

        // Distribute rewards
        token.approve(address(rewards), REWARD_AMOUNT);
        rewards.distributeRewards(REWARD_AMOUNT);

        // Verify contract received rewards
        uint256 contractBalanceAfter = token.balanceOf(address(rewards));
        assertEq(contractBalanceAfter - contractBalanceBefore, REWARD_AMOUNT, "Contract balance increase mismatch");

        // Analyze reward distribution
        console.log("\nReward Distribution Analysis:");
        uint256 totalRewardsClaimed = 0;
        uint256 smallestReward = type(uint256).max;
        uint256 largestReward = 0;

        for (uint256 i = 0; i < NUM_STAKERS; i++) {
            (, uint256[] memory pendingRewardsPerTier,,) = rewards.getUserStakeInfo(stakers[i]);
            uint256 pendingReward = pendingRewardsPerTier[0];
            uint256 expectedReward = (REWARD_AMOUNT * stakedAmounts[i]) / totalStaked;

            // Track stats
            totalRewardsClaimed += pendingReward;
            smallestReward = pendingReward < smallestReward ? pendingReward : smallestReward;
            largestReward = pendingReward > largestReward ? pendingReward : largestReward;

            // Calculate and log significant deviations
            uint256 delta =
                expectedReward > pendingReward ? expectedReward - pendingReward : pendingReward - expectedReward;

            if (delta > REWARD_AMOUNT / 1000) {
                // Log if deviation > 0.1%
                console.log("Large deviation found for staker", i);
                console.log("  Stake amount:", stakedAmounts[i]);
                console.log("  Expected reward:", expectedReward);
                console.log("  Actual reward:", pendingReward);
                console.log("  Deviation:", delta);
            }
        }

        // Log distribution stats
        console.log("\nDistribution Statistics:");
        console.log("Total rewards distributed:", REWARD_AMOUNT);
        console.log("Total rewards claimable:", totalRewardsClaimed);
        console.log("Difference:", REWARD_AMOUNT - totalRewardsClaimed);
        console.log("Smallest individual reward:", smallestReward);
        console.log("Largest individual reward:", largestReward);

        // Calculate acceptable margin based on number of stakers and reward size
        // Allow for 0.1% maximum deviation on total rewards
        uint256 acceptableMargin = REWARD_AMOUNT / 1000;

        assertApproxEqRel(totalRewardsClaimed, REWARD_AMOUNT, acceptableMargin, "Total rewards deviation exceeds 0.1%");

        // Verify all rewards can be claimed
        for (uint256 i = 0; i < NUM_STAKERS; i++) {
            vm.startPrank(stakers[i]);
            uint256 balanceBefore = token.balanceOf(stakers[i]);
            rewards.claimRewards(0);
            uint256 claimed = token.balanceOf(stakers[i]) - balanceBefore;
            assertTrue(claimed > 0, "Staker unable to claim rewards");
            vm.stopPrank();
        }
    }
}
