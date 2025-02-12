// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AggregatorV3Interface} from
    "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract BuyPurpose is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable pfpToken; // The PFP token being sold
    IERC20 public immutable usdcToken; // USDC token for payment
    AggregatorV3Interface internal priceFeed; // Chainlink price feed for ETH/USD
    uint256 public immutable TOKEN_PRICE_USD = 250000000000000000; // Price of one PFP token in USD (scaled to 18 decimals)

    uint256 constant USDC_DECIMALS = 6;
    uint256 constant STANDARD_DECIMALS = 18;
    uint256 constant DECIMALS_DIFFERENCE = STANDARD_DECIMALS - USDC_DECIMALS;

    event TokensBoughtWithETH(address indexed buyer, uint256 amount, uint256 ethSpent);
    event TokensBoughtWithUSDC(address indexed buyer, uint256 amount, uint256 usdcSpent);
    event USDCWithdrawn(address indexed owner, uint256 amount);
    event TokensWithdrawn(address indexed owner, uint256 amount);

    constructor(address _pfpToken, address _usdcToken, address _priceFeed) Ownable(msg.sender) {
        pfpToken = IERC20(_pfpToken);
        usdcToken = IERC20(_usdcToken);
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // Buy PFP tokens with ETH
    function buyTokensWithETH() external payable nonReentrant {
        require(msg.value > 0, "Must send ETH to buy tokens");

        // Get the current ETH/USD price from Chainlink
        uint256 ethPrice = getLatestETHPrice();

        // Calculate how much ETH is worth in USD
        uint256 ethInUsd = (msg.value * ethPrice);

        // Calculate how many PFP tokens the buyer can get
        uint256 tokensToBuy = ethInUsd / TOKEN_PRICE_USD;

        uint256 contractBalance = pfpToken.balanceOf(address(this));
        require(tokensToBuy <= contractBalance, "Not enough tokens in the contract");

        // Transfer tokens to the buyer using SafeERC20
        pfpToken.safeTransfer(msg.sender, tokensToBuy);

        emit TokensBoughtWithETH(msg.sender, tokensToBuy, msg.value);
    }

    // Buy PFP tokens with USDC
    function buyTokensWithUSDC(uint256 usdcAmount) external nonReentrant {
        require(usdcAmount > 0, "Must send USDC to buy tokens");

        // Calculate how many PFP tokens the buyer can get
        uint256 tokensToBuy = Math.mulDiv(usdcAmount, 10 ** DECIMALS_DIFFERENCE, TOKEN_PRICE_USD);

        uint256 contractBalance = pfpToken.balanceOf(address(this));
        require(tokensToBuy <= contractBalance, "Not enough tokens in the contract");

        // Transfer USDC from the buyer to the contract using SafeERC20
        usdcToken.safeTransferFrom(msg.sender, address(this), usdcAmount);

        // Transfer tokens to the buyer using SafeERC20
        pfpToken.safeTransfer(msg.sender, tokensToBuy);

        emit TokensBoughtWithUSDC(msg.sender, tokensToBuy, usdcAmount);
    }

    // Fetch the latest ETH/USD price from Chainlink
    function getLatestETHPrice() public view returns (uint256) {
        (, int256 answer,,,) = priceFeed.latestRoundData();
        require(answer > 0, "Invalid price from Chainlink");
        return uint256(answer * 10 ** 10); // Convert price to 18 decimals
    }

    // Owner-only function to withdraw ETH collected from sales
    function withdrawETH(uint256 amount) external onlyOwner nonReentrant {
        require(amount <= address(this).balance, "Not enough ETH in contract");
        payable(owner()).transfer(amount);
    }

    // Owner-only function to withdraw USDC collected from sales
    function withdrawUSDC(uint256 amount) external onlyOwner nonReentrant {
        require(usdcToken.balanceOf(address(this)) >= amount, "Insufficient USDC balance");
        usdcToken.safeTransfer(owner(), amount);
        emit USDCWithdrawn(owner(), amount);
    }

    // Owner-only function to withdraw unsold tokens
    function withdrawUnsoldTokens(uint256 amount) external onlyOwner nonReentrant {
        require(pfpToken.balanceOf(address(this)) >= amount, "Insufficient token balance");
        pfpToken.safeTransfer(owner(), amount);
        emit TokensWithdrawn(owner(), amount);
    }
}
