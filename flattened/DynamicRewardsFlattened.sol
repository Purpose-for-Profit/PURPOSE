// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 ^0.8.20;

// lib/foundry-chainlink-toolkit/lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// lib/foundry-chainlink-toolkit/lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// lib/foundry-chainlink-toolkit/lib/openzeppelin-contracts/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// src/DynamicRewards.sol

contract StakingRewardsDynamic is Ownable {
    IERC20 public stakingToken;

    uint256 public totalStaked;
    uint256 public rewardsPool;
    uint256 public rewardsPerTokenStored;
    uint256 public lastUpdateTime;
    uint256 public rewardRate;

    // Mapping for user stakes and rewards
    mapping(address => uint256) public userStakes;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsPoolRefilled(uint256 amount);

    // For demonstration purposes
    struct RewardSnapshot {
        uint256 timestamp;
        uint256 rewardsPerToken;
        uint256 totalStaked;
    }

    RewardSnapshot[] public rewardHistory;

    constructor(address _stakingToken) Ownable() {
        stakingToken = IERC20(_stakingToken);
    }

    // Modifier to update reward state
    modifier updateReward(address account) {
        rewardsPerTokenStored = rewardsPerToken();
        lastUpdateTime = block.timestamp;

        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardsPerTokenStored;
        }
        _;
    }

    // Calculate earned rewards for an account
    function earned(address account) public view returns (uint256) {
        return ((userStakes[account] * (rewardsPerToken() - userRewardPerTokenPaid[account])) / 1e18) + rewards[account];
    }

    // Stake tokens
    function stake(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        require(rewardsPool > 0, "Rewards pool is empty");

        totalStaked += amount;
        userStakes[msg.sender] += amount;

        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        emit Staked(msg.sender, amount);
    }

    // Withdraw staked tokens
    function withdraw(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(userStakes[msg.sender] >= amount, "Not enough staked");

        totalStaked -= amount;
        userStakes[msg.sender] -= amount;

        require(stakingToken.transfer(msg.sender, amount), "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    // Claim rewards
    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsPool -= reward;
            require(stakingToken.transfer(msg.sender, reward), "Transfer failed");

            emit RewardPaid(msg.sender, reward);
        }
    }

    // Owner function to refill rewards pool
    function refillRewardsPool(uint256 amount) external onlyOwner updateReward(address(0)) {
        require(amount > 0, "Amount must be greater than 0");
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        rewardsPool = amount;
        rewardRate = amount / (7 days); // Distribute rewards over 7 days

        emit RewardsPoolRefilled(amount);
    }

    // Function to simulate time passing and see how rewards change
    function simulateRewardsAtTime(uint256 futureTimestamp) external view returns (uint256) {
        if (totalStaked == 0) return rewardsPerTokenStored;

        uint256 timeElapsed = futureTimestamp - lastUpdateTime;
        return rewardsPerTokenStored + ((timeElapsed * rewardRate * 1e18) / totalStaked);
    }

    // Function to take a snapshot of current rewards state
    function takeRewardsSnapshot() external {
        rewardHistory.push(
            RewardSnapshot({timestamp: block.timestamp, rewardsPerToken: rewardsPerToken(), totalStaked: totalStaked})
        );
    }

    // Get the last 5 snapshots to see how rewards changed
    function getRewardHistory()
        external
        view
        returns (uint256[] memory timestamps, uint256[] memory rewardsPerTokens, uint256[] memory totalStakes)
    {
        uint256 length = rewardHistory.length;
        uint256 resultLength = length < 5 ? length : 5;

        timestamps = new uint256[](resultLength);
        rewardsPerTokens = new uint256[](resultLength);
        totalStakes = new uint256[](resultLength);

        for (uint256 i = 0; i < resultLength; i++) {
            uint256 index = length - resultLength + i;
            RewardSnapshot memory snapshot = rewardHistory[index];
            timestamps[i] = snapshot.timestamp;
            rewardsPerTokens[i] = snapshot.rewardsPerToken;
            totalStakes[i] = snapshot.totalStaked;
        }

        return (timestamps, rewardsPerTokens, totalStakes);
    }

    function rewardsPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardsPerTokenStored;
        }

        uint256 timeElapsed = block.timestamp - lastUpdateTime;
        return rewardsPerTokenStored + ((timeElapsed * rewardRate * 1e18) / totalStaked);
    }

    // Helper function to see current rewards state
    function getCurrentRewardsState()
        external
        view
        returns (
            uint256 currentRewardsPerToken,
            uint256 storedRewardsPerToken,
            uint256 timeSinceLastUpdate,
            uint256 currentTotalStaked
        )
    {
        return (rewardsPerToken(), rewardsPerTokenStored, block.timestamp - lastUpdateTime, totalStaked);
    }

    // New helper function to get user-specific info
    function getUserInfo(address user)
        external
        view
        returns (uint256 stakedAmount, uint256 earnedRewards, uint256 rewardsPaid)
    {
        return (userStakes[user], earned(user), userRewardPerTokenPaid[user]);
    }
}