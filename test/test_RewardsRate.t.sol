// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/PurposeRewards.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("Mock", "MCK") {
        _mint(msg.sender, 1_000_000_000 ether);
    }
}

contract PurposeRewardsTest is Test {
    PurposeRewards public staking;
    MockToken public token;

    address public owner;
    address[] public stakers;

    uint256 public constant REWARD_AMOUNT = 10_000_000 ether;
    uint256 public constant TOTAL_STAKED = 20_000_000 ether;

    // Staking distribution
    uint256 public constant TIER0_STAKE = 2_000_000 ether; // 2M tokens
    uint256 public constant TIER1_STAKE = 4_000_000 ether; // 4M tokens
    uint256 public constant TIER2_STAKE = 8_000_000 ether; // 8M tokens
    uint256 public constant TIER3_STAKE = 6_000_000 ether; // 6M tokens

    function setUp() public {
        owner = address(this);
        token = new MockToken();
        staking = new PurposeRewards(address(token));

        // Create staker addresses
        for (uint256 i = 0; i < 4; i++) {
            stakers.push(address(uint160(i + 1)));
            token.transfer(stakers[i], TOTAL_STAKED);
            vm.prank(stakers[i]);
            token.approve(address(staking), TOTAL_STAKED);
        }

        // Set up staking distribution
        vm.prank(stakers[0]);
        staking.stake(TIER0_STAKE);

        vm.prank(stakers[1]);
        staking.stake(TIER1_STAKE);

        vm.prank(stakers[2]);
        staking.stake(TIER2_STAKE);

        vm.prank(stakers[3]);
        staking.stake(TIER3_STAKE);

        // Approve rewards distribution
        token.approve(address(staking), REWARD_AMOUNT);
    }

    function testRewardsRate() public {
        // Distribute rewards
        staking.distributeRewards(REWARD_AMOUNT);

        // Get reward rates for each tier
        uint256 tier0Rate = staking.getTierRewardRate(0);
        uint256 tier1Rate = staking.getTierRewardRate(1);
        uint256 tier2Rate = staking.getTierRewardRate(2);
        uint256 tier3Rate = staking.getTierRewardRate(3);

        // Calculate expected average rate (0.50 per token)
        uint256 expectedAverageRate = (REWARD_AMOUNT * 1e18) / TOTAL_STAKED;
        assertEq(expectedAverageRate, 0.5 ether, "Average token rate should be 0.5");

        // Expected rates after tithes
        assertApproxEqAbs(tier0Rate / 1e6, 0.6 ether / 1e6, 0.001 ether, "Tier 0 rate should be 0.6");
        assertApproxEqAbs(tier1Rate / 1e6, 0.55 ether / 1e6, 0.001 ether, "Tier 1 rate should be 0.55");
        assertApproxEqAbs(tier2Rate / 1e6, 0.4875 ether / 1e6, 0.001 ether, "Tier 2 rate should be 0.4875");
        assertApproxEqAbs(tier3Rate / 1e6, 0.45 ether / 1e6, 0.001 ether, "Tier 3 rate should be 0.45");

        // Verify rate ordering
        assertTrue(tier0Rate > tier1Rate, "Tier 0 should have highest rate");
        assertTrue(tier1Rate > tier2Rate, "Tier 1 should have higher rate than Tier 2");
        assertTrue(tier2Rate > tier3Rate, "Tier 2 should have higher rate than Tier 3");
    }

    function testDetailedRates() public {
        // Distribute rewards first
        staking.distributeRewards(REWARD_AMOUNT);

        console.log("\nDetailed Tier Information:");

        for (uint256 i = 0; i < 4; i++) {
            console.log("\nTier", i);
            (uint256 cap, uint256 staked) = staking.getTierInfo(i);
            uint256 rate = staking.getTierRewardRate(i);
            uint256 pending = staking.getPendingRewards(stakers[i], i);

            console.log("Cap:", formatEther(cap));
            console.log("Staked:", formatEther(staked));
            console.log("Reward Rate:", formatEther(rate));
            console.log("Pending Rewards:", formatEther(pending));
        }

        // Verify final reward rates
        uint256 tier0Rate = staking.getTierRewardRate(0);
        uint256 tier1Rate = staking.getTierRewardRate(1);
        uint256 tier2Rate = staking.getTierRewardRate(2);
        uint256 tier3Rate = staking.getTierRewardRate(3);

        assertApproxEqAbs(tier0Rate / 1e6, 0.6 ether / 1e6, 0.001 ether, "Tier 0 rate should be 0.6");
        assertApproxEqAbs(tier1Rate / 1e6, 0.55 ether / 1e6, 0.001 ether, "Tier 1 rate should be 0.55");
        assertApproxEqAbs(tier2Rate / 1e6, 0.4875 ether / 1e6, 0.001 ether, "Tier 2 rate should be 0.4875");
        assertApproxEqAbs(tier3Rate / 1e6, 0.45 ether / 1e6, 0.001 ether, "Tier 3 rate should be 0.45");
    }

    // Helper functions remain the same
    function formatEther(uint256 value) internal pure returns (string memory) {
        uint256 decimal = value / 1e15;
        uint256 integer = decimal / 1000;
        uint256 fraction = decimal % 1000;

        return string(
            abi.encodePacked(
                toString(integer), ".", fraction < 100 ? "0" : "", fraction < 10 ? "0" : "", toString(fraction)
            )
        );
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
