// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* In the scenario in which the current tier is about to be filled and someone stakes
an amount that will exceed the tier cap, the remaining space in the current tier should be filled.
And anything after goes into the subsequent tier
*/

import "forge-std/Test.sol";
import "../src/PurposeRewards.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, type(uint256).max);
    }
}

contract PartialTierFill is Test {
    PurposeRewards public rewards;
    MockToken public token;
    address[] public users;
    address public owner;

    function setUp() public {
        token = new MockToken();
        rewards = new PurposeRewards(address(token));
        owner = address(this);

        // Create test users
        for (uint256 i = 0; i < 100; i++) {
            users.push(address(uint160(0x1000 + i)));
            token.transfer(users[i], 1_000_000_000 ether);
        }
    }

    function test_PartialTierFill() public {
        // First user stakes 1.9M (leaving 100k space in tier 0)
        uint256 firstStake = 1_900_000 ether;
        vm.startPrank(users[0]);
        token.approve(address(rewards), firstStake);
        rewards.stake(firstStake);
        vm.stopPrank();

        // Second user stakes 2M
        uint256 secondStake = 2_000_000 ether;
        vm.startPrank(users[1]);
        token.approve(address(rewards), secondStake);
        rewards.stake(secondStake);
        vm.stopPrank();

        // Check tier 0 distribution
        (, uint256 tier0Staked) = rewards.getTierInfo(0);
        assertEq(tier0Staked, 2_000_000 ether, "Tier 0 should be completely filled");

        // Get user stakes to verify distribution
        (uint256[] memory user1Stakes,, uint256 user1Total,) = rewards.getUserStakeInfo(users[1]);

        // User 1 should have 100k in tier 0 (filling it up)
        assertEq(user1Stakes[0], 100_000 ether, "Wrong amount in tier 0");

        // And 1.9M in tier 1
        assertEq(user1Stakes[1], 1_900_000 ether, "Wrong amount in tier 1");

        // Total stake should be 2M
        assertEq(user1Total, secondStake, "Total stake amount incorrect");
    }
}
