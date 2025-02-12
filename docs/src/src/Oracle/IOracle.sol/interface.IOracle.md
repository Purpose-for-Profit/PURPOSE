# IOracle
[Git Source](https://github.com/KBryan/PFP3eInteractive/blob/9ca4333e3a12a1ceff0ce5cf0bec5d44ba67c678/src/Oracle/IOracle.sol)

Provides a standard interface for interacting with an Oracle contract

*Contracts implementing this interface must define the `getData` function*


## Functions
### getData

*Retrieves data associated with a specific key.*


```solidity
function getData(bytes32 key) external view returns (bool result, uint256 data, uint256 payload);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`key`|`bytes32`|The unique identifier for the data entry.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`result`|`bool`|A boolean indicating whether the data exists.|
|`data`|`uint256`|the payload data with the current pricing pair|
|`payload`|`uint256`|The value associated with the key if it exists.|


