    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PurposeRewards.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/console2.sol";

/* In the scenario in which someone unstakes without claiming, the remaining rewards should automatically
be withdrawal to prevent overflows/rewards calculation issues
*/

contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, type(uint256).max);
    }
}

contract MultiUserStressTest is Test {
    PurposeRewards public rewards;
    MockToken public token;
    address[] public users;
    address public owner;

    function setUp() public {
        token = new MockToken();
        rewards = new PurposeRewards(address(token));
        owner = address(this);

        // Create 100 test users
        for (uint256 i = 0; i < 100; i++) {
            users.push(address(uint160(0x1000 + i)));
            token.transfer(users[i], 1_000_000_000 ether);
        }
    }

    function test_MultiUserStressTest() public {
        uint256 amount = 100_000 ether;

        // Just test with one user
        vm.startPrank(users[0]);

        // Initial stake
        token.approve(address(rewards), amount);
        rewards.stake(amount);
        console.log("\nAfter initial stake:");
        (uint256[] memory stakes1,,,) = rewards.getUserStakeInfo(users[0]);
        console.log("Initial stake amount:", stakes1[0]);
        vm.stopPrank();

        // Switch to owner for distributing rewards
        // owner is set to address(this) in setUp()
        token.approve(address(rewards), 1_000_000 ether);
        rewards.distributeRewards(1_000_000 ether);

        // Check state after reward distribution
        vm.startPrank(users[0]);
        (uint256[] memory stakes2, uint256[] memory rewardAmounts,,) = rewards.getUserStakeInfo(users[0]);
        console.log("\nAfter reward distribution:");
        console.log("Stake amount:", stakes2[0]);
        console.log("Rewards amount:", rewardAmounts[0]);

        // Try unstaking a small amount WITHOUT claiming rewards
        uint256 smallUnstake = 1 ether;
        console.log("\nTrying unstake WITHOUT claiming rewards:");
        uint256 balanceBefore = token.balanceOf(users[0]);

        // Store stake info right before unstake
        (uint256[] memory preUnstakeStakes,,,) = rewards.getUserStakeInfo(users[0]);
        console.log("Stake before unstake:", preUnstakeStakes[0]);

        rewards.unstake(0, smallUnstake);
        uint256 balanceAfter = token.balanceOf(users[0]);
        console.log("Tokens received:", balanceAfter - balanceBefore);

        // Check state after unstake
        (uint256[] memory stakes3, uint256[] memory finalRewards,,) = rewards.getUserStakeInfo(users[0]);
        console.log("\nFinal state:");
        console.log("Final stake:", stakes3[0]);
        console.log("Remaining rewards:", finalRewards[0]);

        vm.stopPrank();
    }

    function test_MultiUserStressTest2() public {
        uint256 amount = 100_000 ether;

        // Test User 1: Unstake directly (should work)
        vm.startPrank(users[0]);
        token.approve(address(rewards), amount);
        rewards.stake(amount);
        vm.stopPrank();

        // Test User 2: Claim then unstake
        vm.startPrank(users[1]);
        token.approve(address(rewards), amount);
        rewards.stake(amount);
        vm.stopPrank();

        // Distribute rewards
        token.approve(address(rewards), 2_000_000 ether);
        rewards.distributeRewards(2_000_000 ether);

        // User 1: Direct unstake
        vm.startPrank(users[0]);
        uint256 balanceBefore = token.balanceOf(users[0]);
        rewards.unstake(0, 1 ether);
        uint256 balanceAfter = token.balanceOf(users[0]);
        console.log("\nUser 1 (direct unstake):");
        console.log("Tokens received:", balanceAfter - balanceBefore);
        vm.stopPrank();

        // User 2: Claim then unstake
        vm.startPrank(users[1]);
        balanceBefore = token.balanceOf(users[1]);
        rewards.claimRewards(0);
        console.log("\nUser 2 (claim then unstake):");
        console.log("Rewards claimed:", token.balanceOf(users[1]) - balanceBefore);

        balanceBefore = token.balanceOf(users[1]);
        rewards.unstake(0, 1 ether);
        balanceAfter = token.balanceOf(users[1]);
        console.log("Tokens from unstake:", balanceAfter - balanceBefore);
        vm.stopPrank();
    }
}
