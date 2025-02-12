# BuyPurpose
[Git Source](https://github.com/KBryan/PFP3eInteractive/blob/9ca4333e3a12a1ceff0ce5cf0bec5d44ba67c678/src/BuyPurpose.sol)

**Inherits:**
[Ownable](/src/PurposeRewardsFlattened.sol/abstract.Ownable.md), [ReentrancyGuard](/src/PurposeRewardsFlattened.sol/abstract.ReentrancyGuard.md)


## State Variables
### pfpToken

```solidity
IERC20 public pfpToken;
```


### priceFeed

```solidity
AggregatorV3Interface public priceFeed;
```


### TOKEN_PRICE_USD

```solidity
uint256 public TOKEN_PRICE_USD = 250000000000000000;
```


## Functions
### constructor


```solidity
constructor(address _pfpToken, address _priceFeed) Ownable(msg.sender);
```

### buyTokens


```solidity
function buyTokens() external payable nonReentrant;
```

### getLatestETHPrice


```solidity
function getLatestETHPrice() public view returns (uint256);
```

### withdrawETH


```solidity
function withdrawETH(uint256 amount) external onlyOwner nonReentrant;
```

### withdrawUnsoldTokens


```solidity
function withdrawUnsoldTokens(uint256 amount) external onlyOwner nonReentrant;
```

## Events
### TokensBought

```solidity
event TokensBought(address indexed buyer, uint256 amount, uint256 ethSpent);
```

