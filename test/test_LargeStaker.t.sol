// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/PurposeRewards.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("MOCK", "Mock Token") {
        _mint(msg.sender, 1_000_000_000 ether);
    }
}

contract LargeStaker is Test {
    PurposeRewards public staking;
    MockToken public token;

    address public owner;
    address public alice = address(0x1);

    uint256 public constant LARGE_STAKE = 10_000_000 ether;
    uint256 public constant REWARD_AMOUNT = 100_000 ether;

    function setUp() public {
        owner = address(this);
        token = new MockToken();
        staking = new PurposeRewards(address(token));

        // Give Alice enough tokens and approve
        token.transfer(alice, LARGE_STAKE);
        vm.prank(alice);
        token.approve(address(staking), LARGE_STAKE);

        // Approve for rewards distribution
        token.approve(address(staking), REWARD_AMOUNT);
    }

    function test_LargeStaker() public {
        // Have Alice stake 10M tokens
        vm.prank(alice);
        staking.stake(LARGE_STAKE);

        // Get full staking info
        (uint256[] memory stakes, uint256[] memory pendingRewards, uint256 totalStaked, uint256 totalPending) =
            staking.getUserStakeInfo(alice);

        console.log("Stakes per tier:", stakes[0], stakes[1], stakes[2]);

        // Verify tier distribution
        assertEq(stakes[0], 2_000_000 ether, "Tier 0 should have 2M tokens");
        assertEq(stakes[1], 4_000_000 ether, "Tier 1 should have 4M tokens");
        assertEq(stakes[2], 4_000_000 ether, "Tier 2 should have 4M tokens");

        // Verify total staked
        assertEq(totalStaked, LARGE_STAKE, "Total staked should be 10M");

        // Distribute rewards
        staking.distributeRewards(REWARD_AMOUNT);

        // Calculate expected rewards
        uint256 avgTokenRate = (REWARD_AMOUNT * 1e18) / LARGE_STAKE;

        // Expected base rewards per tier (before tithes)
        uint256 tier0Base = (2_000_000 ether * avgTokenRate) / 1e18; // 20,000 tokens
        uint256 tier1Base = (4_000_000 ether * avgTokenRate) / 1e18; // 40,000 tokens
        uint256 tier2Base = (4_000_000 ether * avgTokenRate) / 1e18; // 40,000 tokens

        // Calculate tithes
        uint256 tier2Tithe = tier2Base / 10; // 10% of 40,000 = 4,000 to tier 1
        uint256 tier1Tithe = tier1Base / 10; // 10% of 40,000 = 4,000 to tier 0

        // Final expected amounts after tithes
        uint256 expectedTier0 = tier0Base + tier1Tithe; // 20,000 + 4,000 = 24,000
        uint256 expectedTier1 = (tier1Base - tier1Tithe) + tier2Tithe; // 36,000 + 4,000 = 40,000
        uint256 expectedTier2 = tier2Base - tier2Tithe; // 40,000 - 4,000 = 36,000

        uint256 expectedTotal = expectedTier0 + expectedTier1 + expectedTier2;

        // Get pending rewards for each tier
        uint256 tier0Pending = staking.getPendingRewards(alice, 0);
        uint256 tier1Pending = staking.getPendingRewards(alice, 1);
        uint256 tier2Pending = staking.getPendingRewards(alice, 2);

        console.log("Pending rewards per tier:", tier0Pending, tier1Pending, tier2Pending);
        console.log("Expected rewards per tier:", expectedTier0, expectedTier1, expectedTier2);

        // Verify rewards per tier
        assertApproxEqAbs(tier0Pending, expectedTier0, 1e17, "Tier 0 rewards incorrect");
        assertApproxEqAbs(tier1Pending, expectedTier1, 1e17, "Tier 1 rewards incorrect");
        assertApproxEqAbs(tier2Pending, expectedTier2, 1e17, "Tier 2 rewards incorrect");

        // Claim rewards from each tier
        uint256 initialBalance = token.balanceOf(alice);
        vm.startPrank(alice);
        staking.claimRewards(0);
        staking.claimRewards(1);
        staking.claimRewards(2);
        vm.stopPrank();

        // Verify Alice received the rewards
        uint256 aliceBalance = token.balanceOf(alice) - initialBalance;
        assertApproxEqAbs(aliceBalance, expectedTotal, 1e17, "Claimed rewards incorrect");

        console.log("Alice's claimed rewards:", aliceBalance);

        // Additional tier checks
        (uint256 cap0, uint256 staked0) = staking.getTierInfo(0);
        (uint256 cap1, uint256 staked1) = staking.getTierInfo(1);
        (uint256 cap2, uint256 staked2) = staking.getTierInfo(2);

        assertEq(cap0, 2_000_000 ether, "Tier 0 cap incorrect");
        assertEq(staked0, 2_000_000 ether, "Tier 0 staked amount incorrect");
        assertEq(cap1, 4_000_000 ether, "Tier 1 cap incorrect");
        assertEq(staked1, 4_000_000 ether, "Tier 1 staked amount incorrect");
        assertEq(cap2, 8_000_000 ether, "Tier 2 cap incorrect");
        assertEq(staked2, 4_000_000 ether, "Tier 2 staked amount incorrect");
    }
}
