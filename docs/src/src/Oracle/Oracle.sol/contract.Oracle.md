# Oracle
[Git Source](https://github.com/KBryan/PFP3eInteractive/blob/9ca4333e3a12a1ceff0ce5cf0bec5d44ba67c678/src/Oracle/Oracle.sol)


## State Variables
### admin

```solidity
address public admin;
```


### reporters

```solidity
mapping(address => bool) public reporters;
```


### data

```solidity
mapping(bytes32 => Data) public data;
```


## Functions
### constructor


```solidity
constructor(address _admin);
```

### updateReporter

*Allows the admin to add or remove reporters.*


```solidity
function updateReporter(address reporter, bool isReporter) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`reporter`|`address`|The address of the reporter to be updated.|
|`isReporter`|`bool`|Boolean indicating whether the reporter is being added or removed.|


### updateData

*Allows an authorized reporter to submit new data.*


```solidity
function updateData(bytes32 key, uint256 payload) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`key`|`bytes32`|The unique identifier for the data entry.|
|`payload`|`uint256`|The data value being recorded.|


### getData

*Retrieves data associated with a specific key.*


```solidity
function getData(bytes32 key) external view returns (bool result, uint256 date, uint256 payload);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`key`|`bytes32`|The unique identifier for the data entry.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`result`|`bool`|Boolean indicating if the data exists.|
|`date`|`uint256`|The timestamp when the data was recorded.|
|`payload`|`uint256`|The recorded data value.|


## Events
### ReporterUpdated

```solidity
event ReporterUpdated(address indexed reporter, bool isReporter);
```

### DataUpdated

```solidity
event DataUpdated(bytes32 indexed key, uint256 date, uint256 payload);
```

## Structs
### Data

```solidity
struct Data {
    uint256 date;
    uint256 payload;
}
```

