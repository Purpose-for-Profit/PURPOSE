# PurposeRewards
[Git Source](https://github.com/KBryan/PFP3eInteractive/blob/9ca4333e3a12a1ceff0ce5cf0bec5d44ba67c678/src/PurposeRewards.sol)

**Inherits:**
[Ownable](/src/PurposeRewardsFlattened.sol/abstract.Ownable.md), [ReentrancyGuard](/src/PurposeRewardsFlattened.sol/abstract.ReentrancyGuard.md)

*This contract allows users to stake tokens in different tiers and receive rewards
based on their staked amount and the performance of the tiers they are in. The rewards
are distributed across tiers using a tithe system, and users can claim or unstake their
tokens along with any pending rewards.*


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
uint256 private constant PRECISION = 1e18;
```


### totalStakedTokens

```solidity
uint256 public totalStakedTokens;
```


## Functions
### constructor

*Constructor that initializes the contract with the token address.*


```solidity
constructor(address _token) Ownable(msg.sender);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|The address of the ERC20 token used for staking.|


### initializeTiers

*Initializes the staking tiers with their respective caps.*


```solidity
function initializeTiers() private;
```

### getTargetTier

*Returns the target tier for a user based on the amount they want to stake.
If the user already has a stake, they remain in their current tier.*


```solidity
function getTargetTier(uint256 _amount) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|The amount the user wants to stake.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The index of the target tier.|


### stake

*Allows users to stake a specified amount of tokens in the appropriate tier.
This function also calculates and distributes any pending rewards before the staking.*


```solidity
function stake(uint256 amount) external nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|The amount of tokens the user wants to stake.|


### unstake

*Allows users to unstake a specified amount of tokens from a particular tier.
This function also calculates and distributes any pending rewards before the unstaking.*


```solidity
function unstake(uint256 tierId, uint256 amount) external nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tierId`|`uint256`|The index of the tier from which to unstake.|
|`amount`|`uint256`|The amount of tokens to unstake.|


### distributeRewards

*Distributes rewards to all tiers based on their respective staked amounts.
The rewards are distributed in a tithe system where each tier gives a percentage of its reward
to the tier above it.*


```solidity
function distributeRewards(uint256 amount) external onlyOwner nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|The total amount of rewards to distribute.|


### claimRewards

*Allows a user to claim rewards for a specified tier.*


```solidity
function claimRewards(uint256 tierId) external nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tierId`|`uint256`|The tier from which to claim rewards.|


### removeStakerFromTier

*Removes a staker from the list of stakers in a tier.*


```solidity
function removeStakerFromTier(address _staker, uint256 _tierId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_staker`|`address`|The address of the staker to remove.|
|`_tierId`|`uint256`|The tier index from which to remove the staker.|


### getTierInfo

*Returns the cap and current staked amount of a tier.*


```solidity
function getTierInfo(uint256 _tierId) external view returns (uint256 cap, uint256 currentStaked);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tierId`|`uint256`|The tier index.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`cap`|`uint256`|The maximum stake cap for the tier.|
|`currentStaked`|`uint256`|The current total staked amount in the tier.|


### getUserStakeInfo

*Returns a user's staking information for all tiers.*


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
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|The address of the user.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`stakesPerTier`|`uint256[]`|The amount of tokens staked by the user in each tier.|
|`pendingRewardsPerTier`|`uint256[]`|The pending rewards for the user in each tier.|
|`totalStaked`|`uint256`|The total amount of tokens staked by the user.|
|`totalPendingRewards`|`uint256`|The total pending rewards for the user.|


### getTierRewardRate

*Returns the current reward rate for a specific tier.*


```solidity
function getTierRewardRate(uint256 tierId) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tierId`|`uint256`|The index of the tier.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The reward rate for the tier.|


### getPendingRewards

*Calculates the pending rewards for a user in a specific tier.*


```solidity
function getPendingRewards(address user, uint256 tierId) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The address of the user.|
|`tierId`|`uint256`|The index of the tier.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The pending rewards for the user.|


### getUserTierStake

*Returns the stake amount of a user in a specific tier.*


```solidity
function getUserTierStake(address _user, uint256 _tierId) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|The address of the user.|
|`_tierId`|`uint256`|The index of the tier.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The amount staked by the user in the specified tier.|


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

### Unstaked

```solidity
event Unstaked(address indexed user, uint256 amount, uint256 tierId);
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

