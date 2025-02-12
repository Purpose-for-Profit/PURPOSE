# PurposeRewards
[Git Source](https://github.com/KBryan/PFP3eInteractive/blob/9ca4333e3a12a1ceff0ce5cf0bec5d44ba67c678/src/PurposeRewardsFlattened.sol)

**Inherits:**
[Ownable](/src/PurposeRewardsFlattened.sol/abstract.Ownable.md), [ReentrancyGuard](/src/PurposeRewardsFlattened.sol/abstract.ReentrancyGuard.md)


## State Variables
### token

```solidity
IERC20 public immutable token;
```


### tiers

```solidity
mapping(uint256 => Tier) public tiers;
```


### stakers

```solidity
mapping(address => Staker) public stakers;
```


### currentTierIndex

```solidity
uint256 public currentTierIndex;
```


### maxTiers

```solidity
uint256 public immutable maxTiers;
```


### TITHE_PERCENTAGE

```solidity
uint256 public constant TITHE_PERCENTAGE = 10;
```


### PERCENTAGE_BASE

```solidity
uint256 public constant PERCENTAGE_BASE = 100;
```


### PRECISION

```solidity
uint256 private constant PRECISION = 1e12;
```


### totalStakedTokens

```solidity
uint256 public totalStakedTokens;
```


## Functions
### constructor


```solidity
constructor(address _token) Ownable();
```

### initializeTiers


```solidity
function initializeTiers() private;
```

### getTargetTier


```solidity
function getTargetTier(uint256 _amount) public view returns (uint256);
```

### stake


```solidity
function stake(uint256 amount) external nonReentrant;
```

### distributeRewards


```solidity
function distributeRewards(uint256 amount) external onlyOwner nonReentrant;
```

### claimRewards


```solidity
function claimRewards(uint256 tierId) external nonReentrant;
```

### removeStakerFromTier


```solidity
function removeStakerFromTier(address _staker, uint256 _tierId) internal;
```

### getTierInfo


```solidity
function getTierInfo(uint256 _tierId) external view returns (uint256 cap, uint256 currentStaked);
```

### getUserStakeInfo


```solidity
function getUserStakeInfo(address _user)
    external
    view
    returns (
        uint256[] memory stakesPerTier,
        uint256[] memory pendingRewardsPerTier,
        uint256 totalStaked,
        uint256 totalPendingRewards
    );
```

### getTierRewardRate


```solidity
function getTierRewardRate(uint256 tierId) external view returns (uint256);
```

### getPendingRewards


```solidity
function getPendingRewards(address user, uint256 tierId) public view returns (uint256);
```

### getUserTierStake


```solidity
function getUserTierStake(address _user, uint256 _tierId) external view returns (uint256);
```

## Events
### TierInitialized

```solidity
event TierInitialized(uint256 indexed tierId, uint256 cap);
```

### TierFilled

```solidity
event TierFilled(uint256 indexed tierId);
```

### Staked

```solidity
event Staked(address indexed user, uint256 amount, uint256 tierId);
```

### StakerAdded

```solidity
event StakerAdded(uint256 tierId, address staker);
```

### StakerRemoved

```solidity
event StakerRemoved(uint256 tierId, address staker);
```

### RewardsDistributed

```solidity
event RewardsDistributed(uint256 amount, uint256[] tierRates);
```

### RewardsClaimed

```solidity
event RewardsClaimed(address indexed user, uint256 tierId, uint256 amount);
```

## Structs
### Tier

```solidity
struct Tier {
    uint256 cap;
    uint256 currentStaked;
    uint256 accRewardPerShare;
    mapping(address => uint256) stakes;
    mapping(address => uint256) rewardDebt;
    address[] stakers;
}
```

### Staker

```solidity
struct Staker {
    uint256 totalStakedAmount;
    uint256 tierIndex;
    mapping(uint256 => uint256) stakesPerTier;
    bool exists;
}
```

### PendingInfo

```solidity
struct PendingInfo {
    uint256 tierId;
    uint256 pendingAmount;
    uint256 stakeAmount;
}
```

### TierRateInfo

```solidity
struct TierRateInfo {
    uint256 tokensStaked;
    uint256 baseRewards;
    uint256 titheGiven;
    uint256 titheReceived;
    uint256 finalRewards;
    uint256 rewardRate;
}
```

