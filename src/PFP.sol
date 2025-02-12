// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// was on main import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PFPToken is ERC20 {
    uint256 public constant TOTAL_SUPPLY = 4_000_000_000 * 10 ** 18; // 4 billion tokens with 18 decimals

    constructor() ERC20("Purpose Token", "PURPOSE") {
        // Mint the total supply to the contract deployer (typically transferred to the PFPVault contract after)
        _mint(msg.sender, TOTAL_SUPPLY);
    }
}
