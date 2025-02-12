# IERC20
[Git Source](https://github.com/KBryan/PFP3eInteractive/blob/9ca4333e3a12a1ceff0ce5cf0bec5d44ba67c678/src/PFPTokenFlattened.sol)

*Interface of the ERC-20 standard as defined in the ERC.*


## Functions
### totalSupply

*Returns the value of tokens in existence.*


```solidity
function totalSupply() external view returns (uint256);
```

### balanceOf

*Returns the value of tokens owned by `account`.*


```solidity
function balanceOf(address account) external view returns (uint256);
```

### transfer

*Moves a `value` amount of tokens from the caller's account to `to`.
Returns a boolean value indicating whether the operation succeeded.
Emits a [Transfer](/src/PFPTokenFlattened.sol/interface.IERC20.md#transfer) event.*


```solidity
function transfer(address to, uint256 value) external returns (bool);
```

### allowance

*Returns the remaining number of tokens that `spender` will be
allowed to spend on behalf of `owner` through [transferFrom](/src/PFPTokenFlattened.sol/interface.IERC20.md#transferfrom). This is
zero by default.
This value changes when {approve} or {transferFrom} are called.*


```solidity
function allowance(address owner, address spender) external view returns (uint256);
```

### approve

*Sets a `value` amount of tokens as the allowance of `spender` over the
caller's tokens.
Returns a boolean value indicating whether the operation succeeded.
IMPORTANT: Beware that changing an allowance with this method brings the risk
that someone may use both the old and the new allowance by unfortunate
transaction ordering. One possible solution to mitigate this race
condition is to first reduce the spender's allowance to 0 and set the
desired value afterwards:
https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
Emits an [Approval](/src/PFPTokenFlattened.sol/interface.IERC20.md#approval) event.*


```solidity
function approve(address spender, uint256 value) external returns (bool);
```

### transferFrom

*Moves a `value` amount of tokens from `from` to `to` using the
allowance mechanism. `value` is then deducted from the caller's
allowance.
Returns a boolean value indicating whether the operation succeeded.
Emits a [Transfer](/src/PFPTokenFlattened.sol/interface.IERC20.md#transfer) event.*


```solidity
function transferFrom(address from, address to, uint256 value) external returns (bool);
```

## Events
### Transfer
*Emitted when `value` tokens are moved from one account (`from`) to
another (`to`).
Note that `value` may be zero.*


```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
```

### Approval
*Emitted when the allowance of a `spender` for an `owner` is set by
a call to [approve](/src/PFPTokenFlattened.sol/interface.IERC20.md#approve). `value` is the new allowance.*


```solidity
event Approval(address indexed owner, address indexed spender, uint256 value);
```

