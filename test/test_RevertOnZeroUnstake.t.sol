// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PurposeRewards.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Mock token for testing
contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, 10_000_000_000 ether);
    }
}

contract RevertOnZeroUnstake is Test {
    PurposeRewards public rewards;
    MockToken public token;
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public owner;

    // Events to test
    event Staked(address indexed user, uint256 amount, uint256 tierId);
    event Unstaked(address indexed user, uint256 amount, uint256 tierId);

    function setUp() public {
        // Deploy contracts
        token = new MockToken();
        rewards = new PurposeRewards(address(token));
        owner = address(this);

        // Setup test accounts
        vm.startPrank(owner);
        token.transfer(alice, 1_000_000 ether);
        token.transfer(bob, 1_000_000 ether);
        vm.stopPrank();
    }

    // Additional test for zero amount unstake
    function test_RevertOnZeroUnstake() public {
        uint256 stakeAmount = 100_000 ether;
        uint256 tierId = 0;

        // Stake as Alice
        vm.startPrank(alice);
        token.approve(address(rewards), stakeAmount);
        rewards.stake(stakeAmount);

        // Try to unstake zero amount
        vm.expectRevert("Zero unstake amount");
        rewards.unstake(tierId, 0);
        vm.stopPrank();
    }
}
