// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from
    "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract MockPriceFeed is AggregatorV3Interface {
    int256 private price;

    constructor(int256 _price) {
        price = _price;
    }

    function latestRoundData() external view override returns (uint80, int256 answer, uint256, uint256, uint80) {
        return (0, price, block.timestamp, block.timestamp, 0);
    }

    function decimals() external pure override returns (uint8) {
        return 8;
    }

    function description() external pure override returns (string memory) {
        return "Mock Price Feed";
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function getRoundData(uint80) external view override returns (uint80, int256, uint256, uint256, uint80) {
        return (0, price, block.timestamp, block.timestamp, 0);
    }
}
