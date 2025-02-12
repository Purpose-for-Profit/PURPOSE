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

contract RapidStakeUnstake is Test {
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

    function test_RapidStakeUnstake() public {
        // Test rapid stake/unstake cycles
        vm.startPrank(users[0]);
        token.approve(address(rewards), type(uint256).max);

        for (uint256 i = 0; i < 50; i++) {
            rewards.stake(1000 ether);
            rewards.unstake(0, 1000 ether);
        }
        vm.stopPrank();
    }
}
