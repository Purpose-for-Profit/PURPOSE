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

contract RewardPrecisionLoss is Test {
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

    function test_RewardPrecisionLoss() public {
        // Test for precision loss in reward calculations
        // Stake tiny and huge amounts in different tiers
        vm.startPrank(users[0]);
        token.approve(address(rewards), 1 ether);
        rewards.stake(1 ether);
        vm.stopPrank();

        vm.startPrank(users[1]);
        token.approve(address(rewards), 2_000_000 ether);
        rewards.stake(2_000_000 ether);
        vm.stopPrank();

        // Distribute small rewards
        token.approve(address(rewards), 1 ether);
        rewards.distributeRewards(1 ether);

        // Check rewards distribution
        (, uint256[] memory smallStakerRewards,,) = rewards.getUserStakeInfo(users[0]);
        (, uint256[] memory largeStakerRewards,,) = rewards.getUserStakeInfo(users[1]);

        console.log("Small staker rewards:", smallStakerRewards[0]);
        console.log("Large staker rewards:", largeStakerRewards[0]);
    }
}
