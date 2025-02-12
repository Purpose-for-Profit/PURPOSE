# DataConsumerV3
[Git Source](https://github.com/KBryan/PFP3eInteractive/blob/9ca4333e3a12a1ceff0ce5cf0bec5d44ba67c678/src/ChainlinkOracle/LatestPriceFeedFlattened.sol)

THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED
VALUES FOR CLARITY.
THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
DO NOT USE THIS CODE IN PRODUCTION.
If you are reading data feeds on L2 networks, you must
check the latest answer from the L2 Sequencer Uptime
Feed to ensure that the data is accurate in the event
of an L2 sequencer outage. See the
https://docs.chain.link/data-feeds/l2-sequencer-feeds
page for details.


## State Variables
### dataFeed

```solidity
AggregatorV3Interface internal dataFeed;
```


## Functions
### constructor

Network: Sepolia
Aggregator: ETH/USD
Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306


```solidity
constructor();
```

### getChainlinkDataFeedLatestAnswer

Returns the latest answer.


```solidity
function getChainlinkDataFeedLatestAnswer() public view returns (int256);
```

