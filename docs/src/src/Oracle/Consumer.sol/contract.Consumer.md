# Consumer
[Git Source](https://github.com/KBryan/PFP3eInteractive/blob/9ca4333e3a12a1ceff0ce5cf0bec5d44ba67c678/src/Oracle/Consumer.sol)

This contract interacts with an Oracle to fetch and validate data.

*The contract uses the IOracle interface to query data from the Oracle contract.*


## State Variables
### oracle

```solidity
IOracle public oracle;
```


## Functions
### constructor

*Constructor to set the Oracle contract address.*


```solidity
constructor(address _oracle);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_oracle`|`address`|The address of the deployed Oracle contract.|


### foo

This function demonstrates how to securely fetch and verify data from an Oracle.

*Fetches and validates data from the Oracle for a specific key.
The function checks if the data exists and ensures the data's timestamp is recent.*


```solidity
function foo() external;
```

