# Context
[Git Source](https://github.com/KBryan/PFP3eInteractive/blob/9ca4333e3a12a1ceff0ce5cf0bec5d44ba67c678/src/PurposeRewardsFlattened.sol)

*Provides information about the current execution context, including the
sender of the transaction and its data. While these are generally available
via msg.sender and msg.data, they should not be accessed in such a direct
manner, since when dealing with meta-transactions the account sending and
paying for execution may not be the actual sender (as far as an application
is concerned).
This contract is only required for intermediate, library-like contracts.*


## Functions
### _msgSender


```solidity
function _msgSender() internal view virtual returns (address);
```

### _msgData


```solidity
function _msgData() internal view virtual returns (bytes calldata);
```

