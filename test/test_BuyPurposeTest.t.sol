// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BuyPurpose.sol";
import "./mocks/MockERC20.sol";
import "./mocks/MockPriceFeed.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract BuyPurposeTest is Test {
    BuyPurpose public buyPurpose;
    MockERC20 public pfpToken;
    MockERC20 public usdcToken;
    MockPriceFeed public priceFeed;

    event TokensBoughtWithETH( // Address of the buyer
        // Number of tokens purchased
        // Amount of ETH spent
    address indexed buyer, uint256 amount, uint256 ethSpent);

    event TokensBoughtWithUSDC( // Address of the buyer
        // Number of tokens purchased
        // Amount of ETH spent
    address indexed buyer, uint256 amount, uint256 ethSpent);

    address public owner;
    address public buyer;

    uint256 constant TOKEN_PRICE_USD = 0.25 * 10 ** 18; // $0.25 scaled to 18 decimals

    function setUp() public {
        owner = address(this);
        buyer = address(0x123);

        // Deploy mock tokens and price feed
        pfpToken = new MockERC20("PFP Token", "PFP", 1_000_000 ether);
        usdcToken = new MockERC20("USD Coin", "USDC", 1_000_000 * 10 ** 6);
        priceFeed = new MockPriceFeed(2000 * 10 ** 8); // $2000 ETH/USD price

        // Deploy the BuyPurpose contract
        buyPurpose = new BuyPurpose(address(pfpToken), address(usdcToken), address(priceFeed));

        // Fund the contract with PFP tokens
        pfpToken.transfer(address(buyPurpose), 500_000 ether);

        // Give USDC to the buyer
        usdcToken.transfer(buyer, 1_000 * 10 ** 6);
    }

    function buyTokensWithETH() external payable {
        require(msg.value > 0, "Must send ETH to buy tokens");

        // Get the current ETH/USD price from Chainlink
        uint256 ethPrice = getLatestETHPrice();

        // Convert ETH to USD (ETH price has 8 decimals, so scale to 18 decimals)
        uint256 ethInUsd = (msg.value * ethPrice) / 1 ether;

        // Calculate the number of PFP tokens to buy (scale to 18 decimals)
        uint256 tokensToBuy = (ethInUsd * 10 ** 18) / TOKEN_PRICE_USD;

        uint256 contractBalance = pfpToken.balanceOf(address(this));
        require(tokensToBuy <= contractBalance, "Not enough tokens in the contract");

        // Transfer tokens to the buyer
        require(pfpToken.transfer(msg.sender, tokensToBuy), "Token transfer failed");

        emit TokensBoughtWithETH(msg.sender, tokensToBuy, msg.value);
    }

    function buyTokensWithUSDC(uint256 usdcAmount) external {
        require(usdcAmount > 0, "Must send USDC to buy tokens");

        // Calculate the number of PFP tokens to buy (scale USDC to 18 decimals)
        uint256 tokensToBuy = (usdcAmount * 10 ** 12) / TOKEN_PRICE_USD;

        uint256 contractBalance = pfpToken.balanceOf(address(this));
        require(tokensToBuy <= contractBalance, "Not enough tokens in the contract");

        // Transfer USDC from the buyer to the contract
        require(usdcToken.transferFrom(msg.sender, address(this), usdcAmount), "USDC transfer failed");

        // Transfer tokens to the buyer
        require(pfpToken.transfer(msg.sender, tokensToBuy), "Token transfer failed");

        // Emit the event
        emit TokensBoughtWithUSDC(msg.sender, tokensToBuy, usdcAmount);
    }

    // Fetch the latest ETH/USD price from Chainlink
    function getLatestETHPrice() public view returns (uint256) {
        (
            , // roundId (not needed)
            int256 answer, // ETH/USD price
            , // startedAt (not needed)
            , // updatedAt (not needed)
        ) = priceFeed.latestRoundData();

        require(answer > 0, "Invalid price from Chainlink");
        return uint256(answer * 10 ** 10); // Convert price to 18 decimals
    }
}
