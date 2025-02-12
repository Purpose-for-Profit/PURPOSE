// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PurposeRewards.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/console2.sol";

contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, type(uint256).max);
    }
}

contract CrossTierRewardManipulation is Test {
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

    function test_CrossTierRewardManipulation() public {
        // Try to manipulate rewards across tiers
        uint256 amount = 1_000_000 ether;

        // Fill tier 0
        vm.startPrank(users[0]);
        token.approve(address(rewards), amount * 2);
        rewards.stake(amount * 2);
        vm.stopPrank();

        // Stake in tier 1
        vm.startPrank(users[1]);
        token.approve(address(rewards), amount);
        rewards.stake(amount);
        vm.stopPrank();

        // Distribute rewards
        token.approve(address(rewards), amount);
        rewards.distributeRewards(amount);

        // Have tier 0 unstake partially
        vm.startPrank(users[0]);
        rewards.unstake(0, amount);
        vm.stopPrank();

        // Check if rewards are still calculated correctly
        token.approve(address(rewards), amount);
        rewards.distributeRewards(amount);
    }
}
