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

contract ReentrancyAttack is Test {
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

    function test_ReentrancyAttack() public {
        // Test for reentrancy in stake/unstake/claim cycle
        MockReentrancyAttacker attacker = new MockReentrancyAttacker(address(rewards), address(token));
        token.transfer(address(attacker), 1_000_000 ether);

        vm.startPrank(address(attacker));
        token.approve(address(rewards), type(uint256).max);
        attacker.attack();
        vm.stopPrank();
    }
}

// Mock contract for reentrancy attack
contract MockReentrancyAttacker {
    PurposeRewards public rewards;
    IERC20 public token;
    uint256 public attackCount;

    constructor(address _rewards, address _token) {
        rewards = PurposeRewards(_rewards);
        token = IERC20(_token);
    }

    function attack() external {
        rewards.stake(1000 ether);
    }

    function onERC20Transfer(address, uint256) external {
        if (attackCount < 5) {
            attackCount++;
            rewards.unstake(0, 1000 ether);
            rewards.stake(1000 ether);
        }
    }
}
