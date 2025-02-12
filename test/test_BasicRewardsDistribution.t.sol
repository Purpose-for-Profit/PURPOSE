// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {PurposeRewards} from "src/PurposeRewards.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("MOCK", "Mock Token") {
        _mint(msg.sender, 1_000_000_000 ether);
    }
}

contract BasicRewardsDistribution is Test {
    PurposeRewards public staking;
    MockToken public token;

    address public owner;
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public charlie = address(0x3);
    address public dave = address(0x4);
    address public eve = address(0x5);

    // Test state variables remain the same
    uint256 public constant REWARD_AMOUNT = 100_000 ether;
    uint256 public constant TIER0_STAKE = 2_000_000 ether;
    uint256 public constant TIER1_STAKE = 4_000_000 ether;
    uint256 public constant TIER2_STAKE_CHARLIE = 6_000_000 ether;
    uint256 public constant TIER2_STAKE_DAVE = 2_000_000 ether;
    uint256 public constant TIER3_STAKE = 6_000_000 ether;

    function setUp() public {
        // Setup remains the same
        owner = address(this);
        token = new MockToken();
        staking = new PurposeRewards(address(token));

        // Setup users with tokens
        token.transfer(alice, TIER0_STAKE);
        token.transfer(bob, TIER1_STAKE);
        token.transfer(charlie, TIER2_STAKE_CHARLIE);
        token.transfer(dave, TIER2_STAKE_DAVE);
        token.transfer(eve, TIER3_STAKE);

        // Approvals
        vm.prank(alice);
        token.approve(address(staking), TIER0_STAKE);
        vm.prank(bob);
        token.approve(address(staking), TIER1_STAKE);
        vm.prank(charlie);
        token.approve(address(staking), TIER2_STAKE_CHARLIE);
        vm.prank(dave);
        token.approve(address(staking), TIER2_STAKE_DAVE);
        vm.prank(eve);
        token.approve(address(staking), TIER3_STAKE);

        token.approve(address(staking), REWARD_AMOUNT);
    }

    function testInitialStaking() public {
        _performStaking();

        (, uint256 tier0Staked) = staking.getTierInfo(0);
        (, uint256 tier1Staked) = staking.getTierInfo(1);
        (, uint256 tier2Staked) = staking.getTierInfo(2);

        assertEq(tier0Staked, TIER0_STAKE, "Tier 0 stake incorrect");
        assertEq(tier1Staked, TIER1_STAKE, "Tier 1 stake incorrect");
        assertEq(tier2Staked, TIER2_STAKE_CHARLIE + TIER2_STAKE_DAVE, "Tier 2 stake incorrect");

        uint256 totalStaked = tier0Staked + tier1Staked + tier2Staked + TIER3_STAKE;
        assertEq(totalStaked, 20_000_000 ether, "Total staked should be 20M");

        // Verify caps
        (uint256 cap0,) = staking.getTierInfo(0);
        (uint256 cap1,) = staking.getTierInfo(1);
        (uint256 cap2,) = staking.getTierInfo(2);

        assertEq(cap0, 2_000_000 ether, "Tier 0 cap incorrect");
        assertEq(cap1, 4_000_000 ether, "Tier 1 cap incorrect");
        assertEq(cap2, 8_000_000 ether, "Tier 2 cap incorrect");
    }

    function testRewardDistribution() public {
        _performStaking();
        _distributeRewards();
        _verifyRewards();
    }

    function _performStaking() private {
        vm.prank(alice);
        staking.stake(TIER0_STAKE);

        vm.prank(bob);
        staking.stake(TIER1_STAKE);

        vm.prank(charlie);
        staking.stake(TIER2_STAKE_CHARLIE);

        vm.prank(dave);
        staking.stake(TIER2_STAKE_DAVE);

        vm.prank(eve);
        staking.stake(TIER3_STAKE);
    }

    function _distributeRewards() private {
        staking.distributeRewards(REWARD_AMOUNT);
    }

    function _verifyRewards() private {
        // Get pending rewards for each user in their respective tiers
        uint256 alicePending = staking.getPendingRewards(alice, 0);
        uint256 bobPending = staking.getPendingRewards(bob, 1);
        uint256 charliePending = staking.getPendingRewards(charlie, 2);
        uint256 davePending = staking.getPendingRewards(dave, 2);
        uint256 evePending = staking.getPendingRewards(eve, 3);

        // Base allocations (0.005 rate)
        uint256 tier0Base = 10_000 ether;
        uint256 tier1Base = 20_000 ether;
        uint256 tier2Base = 40_000 ether;
        uint256 tier3Base = 30_000 ether;

        // Tithes
        uint256 tier3Tithe = tier3Base / 10;
        uint256 tier2Tithe = tier2Base / 10;
        uint256 tier1Tithe = tier1Base / 10;

        // Expected final amounts
        uint256 expectedTier0 = tier0Base + tier1Tithe;
        uint256 expectedTier1 = (tier1Base - tier1Tithe) + tier2Tithe;
        uint256 expectedTier2 = (tier2Base - tier2Tithe) + tier3Tithe;
        uint256 expectedTier3 = tier3Base - tier3Tithe;

        // Verify total rewards
        assertApproxEqAbs(alicePending, expectedTier0, 1e17, "Alice's pending rewards incorrect");
        assertApproxEqAbs(bobPending, expectedTier1, 1e17, "Bob's pending rewards incorrect");

        // Charlie and Dave split Tier 2
        uint256 charlieExpected = (expectedTier2 * TIER2_STAKE_CHARLIE) / (TIER2_STAKE_CHARLIE + TIER2_STAKE_DAVE);
        uint256 daveExpected = (expectedTier2 * TIER2_STAKE_DAVE) / (TIER2_STAKE_CHARLIE + TIER2_STAKE_DAVE);

        assertApproxEqAbs(charliePending, charlieExpected, 1e17, "Charlie's pending rewards incorrect");
        assertApproxEqAbs(davePending, daveExpected, 1e17, "Dave's pending rewards incorrect");
        assertApproxEqAbs(evePending, expectedTier3, 1e17, "Eve's pending rewards incorrect");

        // Test reward claiming
        vm.prank(alice);
        staking.claimRewards(0);
        assertEq(token.balanceOf(alice), expectedTier0, "Alice's claimed rewards incorrect");

        vm.prank(bob);
        staking.claimRewards(1);
        assertEq(token.balanceOf(bob), expectedTier1, "Bob's claimed rewards incorrect");

        vm.prank(charlie);
        staking.claimRewards(2);
        assertEq(token.balanceOf(charlie), charlieExpected, "Charlie's claimed rewards incorrect");

        vm.prank(dave);
        staking.claimRewards(2);
        assertEq(token.balanceOf(dave), daveExpected, "Dave's claimed rewards incorrect");

        vm.prank(eve);
        staking.claimRewards(3);
        assertEq(token.balanceOf(eve), expectedTier3, "Eve's claimed rewards incorrect");
    }
}
