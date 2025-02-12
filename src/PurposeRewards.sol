// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title PurposeRewards Contract
 * @dev This contract allows users to stake tokens in different tiers and receive rewards
 *      based on their staked amount and the performance of the tiers they are in. The rewards
 *      are distributed across tiers using a tithe system, and users can claim or unstake their
 *      tokens along with any pending rewards.
 */
contract PurposeRewards is Ownable, ReentrancyGuard {
    IERC20 public immutable token;

    struct Tier {
        uint256 cap;
        uint256 currentStaked;
        uint256 accRewardPerShare; // Accumulated rewards per share
        mapping(address => uint256) stakes;
        mapping(address => uint256) rewardDebt; // Track claimed rewards
        mapping(address => uint256) stakerIndices;
        address[] stakers;
    }

    struct Staker {
        uint256 totalStakedAmount;
        uint256 tierIndex;
        mapping(uint256 => uint256) stakesPerTier;
        bool exists;
    }

    struct PendingInfo {
        uint256 tierId;
        uint256 pendingAmount;
        uint256 stakeAmount;
    }

    struct TierData {
        uint256 staked;
        uint256 rewards;
        uint256 newRate;
    }

    mapping(uint256 => Tier) public tiers;
    mapping(address => Staker) public stakers;

    uint256 public currentTierIndex;
    uint256 public immutable maxTiers;
    uint256 public constant TITHE_PERCENTAGE = 10;
    uint256 public constant PERCENTAGE_BASE = 100;
    uint256 private constant PRECISION = 1e18;
    uint256 public totalStakedTokens;

    event TierInitialized(uint256 indexed tierId, uint256 cap);
    event Staked(address indexed user, uint256 amount, uint256 tierId);
    event StakerRemoved(uint256 tierId, address staker);
    event RewardsDistributed(uint256 amount, uint256[] tierRates);
    event RewardsClaimed(address indexed user, uint256 tierId, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 tierId);

    /**
     * @dev Constructor that initializes the contract with the token address.
     * @param _token The address of the ERC20 token used for staking.
     */
    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
        maxTiers = 11;
        currentTierIndex = 0;
        initializeTiers();
    }

    /**
     * @dev Initializes the staking tiers with their respective caps.
     */
    function initializeTiers() private {
        tiers[0].cap = 2_000_000 ether;
        tiers[1].cap = 4_000_000 ether;
        tiers[2].cap = 8_000_000 ether;
        tiers[3].cap = 16_000_000 ether;
        tiers[4].cap = 32_000_000 ether;
        tiers[5].cap = 64_000_000 ether;
        tiers[6].cap = 128_000_000 ether;
        tiers[7].cap = 256_000_000 ether;
        tiers[8].cap = 512_000_000 ether;
        tiers[9].cap = 1_024_000_000 ether;
        tiers[10].cap = 1_954_001_920 ether;

        for (uint256 i = 0; i < maxTiers; i++) {
            emit TierInitialized(i, tiers[i].cap);
        }
    }

    /**
     * @dev Returns the target tier for a user based on the amount they want to stake.
     * If the user already has a stake, they remain in their current tier.
     * @param _amount The amount the user wants to stake.
     * @return The index of the target tier.
     */
    function getTargetTier(uint256 _amount) public view returns (uint256) {
        Staker storage staker = stakers[msg.sender];

        if (staker.totalStakedAmount > 0) {
            return staker.tierIndex;
        }

        for (uint256 i = 0; i <= currentTierIndex; i++) {
            if (tiers[i].currentStaked + _amount <= tiers[i].cap) {
                return i;
            }
        }

        return currentTierIndex + 1;
    }

    /**
     * @dev Allows users to stake a specified amount of tokens in the appropriate tier.
     * This function also calculates and distributes any pending rewards before the staking.
     * @param amount The amount of tokens the user wants to stake.
     */
    function stake(uint256 amount) external nonReentrant {
        uint256 minimumStakeAmount = 1 ether; // Define a minimum stake amount
        require(amount >= minimumStakeAmount, "Amount is below the minimum stake amount");

        // Cache sender information
        address sender = msg.sender;
        Staker storage staker = stakers[sender];

        uint256 remainingAmount = amount;
        uint256 highestTier = staker.tierIndex;

        // Track pending rewards and updates
        uint256 totalPending = 0;
        PendingInfo[] memory pendingInfos = new PendingInfo[](maxTiers);
        uint256 infoCount = 0;

        // Iterate through tiers to calculate stakes and collect pending rewards
        for (uint256 currentTier = 0; remainingAmount > 0 && currentTier < maxTiers; currentTier++) {
            Tier storage tier = tiers[currentTier];

            // Validation checks for tier
            require(tier.cap > 0, "Tier cap must be positive");
            require(tier.currentStaked <= tier.cap, "Current staked exceeds tier cap");

            if (tier.currentStaked >= tier.cap) {
                continue; // Skip full tiers
            }

            uint256 available = tier.cap - tier.currentStaked; // Use native subtraction
            uint256 amountForTier = remainingAmount > available ? available : remainingAmount;

            if (amountForTier > 0) {
                uint256 pending = getPendingRewards(sender, currentTier);

                // Track pending rewards and staking info
                pendingInfos[infoCount++] =
                    PendingInfo({tierId: currentTier, pendingAmount: pending, stakeAmount: amountForTier});

                totalPending += pending; // Use native addition
                remainingAmount -= amountForTier; // Use native subtraction

                if (currentTier > highestTier) {
                    highestTier = currentTier;
                }
            }
        }

        // Ensure remaining amount is fully allocated
        require(remainingAmount == 0, "Amount exceeds available space");

        // Update state for all tiers
        for (uint256 i = 0; i < infoCount; i++) {
            PendingInfo memory info = pendingInfos[i];
            Tier storage tier = tiers[info.tierId];
            uint256 stakeAmount = info.stakeAmount;

            if (tier.stakes[sender] == 0) {
                tier.stakers.push(sender);
            }

            tier.stakes[sender] += stakeAmount; // Use native addition
            tier.currentStaked += stakeAmount; // Use native addition

            staker.stakesPerTier[info.tierId] += stakeAmount; // Use native addition
            staker.totalStakedAmount += stakeAmount; // Use native addition

            tier.rewardDebt[sender] = (tier.stakes[sender] * tier.accRewardPerShare) / PRECISION;

            emit Staked(sender, stakeAmount, info.tierId);
        }

        if (!staker.exists) {
            staker.exists = true;
        }
        staker.tierIndex = highestTier;

        if (highestTier > currentTierIndex) {
            currentTierIndex = highestTier;
        }

        // Transfer tokens from the user to the contract
        require(token.transferFrom(sender, address(this), amount), "Stake transfer failed");

        // Distribute pending rewards
        if (totalPending > 0) {
            require(token.transfer(sender, totalPending), "Reward transfer failed");

            for (uint256 i = 0; i < infoCount; i++) {
                uint256 pendingAmount = pendingInfos[i].pendingAmount;

                if (pendingAmount > 0) {
                    emit RewardsClaimed(sender, pendingInfos[i].tierId, pendingAmount);
                }
            }
        }
    }

    /**
     * @dev Allows users to unstake a specified amount of tokens from a particular tier.
     * This function also calculates and distributes any pending rewards before the unstaking.
     * @param tierId The index of the tier from which to unstake.
     * @param amount The amount of tokens to unstake.
     */
    function unstake(uint256 tierId, uint256 amount) external nonReentrant {
        require(amount > 0, "Zero unstake amount");

        Tier storage tier = tiers[tierId];
        Staker storage staker = stakers[msg.sender];

        uint256 userStake = tier.stakes[msg.sender];

        require(userStake >= amount, "Insufficient stake");
        require(staker.stakesPerTier[tierId] >= amount, "Insufficient tier stake");

        uint256 pending = getPendingRewards(msg.sender, tierId);

        if (pending > 0) {
            tier.rewardDebt[msg.sender] = ((userStake - amount) * tier.accRewardPerShare) / PRECISION;
        }

        tier.stakes[msg.sender] -= amount;
        tier.currentStaked -= amount;

        staker.stakesPerTier[tierId] -= amount;
        staker.totalStakedAmount -= amount;

        if (tier.stakes[msg.sender] == 0) {
            removeStakerFromTier(msg.sender, tierId);
        }

        if (staker.totalStakedAmount == 0) {
            staker.exists = false;
            staker.tierIndex = 0;
        } else if (tierId == staker.tierIndex) {
            uint256 newHighestTier = 0;
            for (uint256 i = 0; i <= currentTierIndex; i++) {
                if (staker.stakesPerTier[i] > 0) {
                    newHighestTier = i;
                }
            }
            staker.tierIndex = newHighestTier;
        }

        if (pending > 0) {
            require(token.transfer(msg.sender, pending), "Reward transfer failed");
            emit RewardsClaimed(msg.sender, tierId, pending);
        }

        require(token.transfer(msg.sender, amount), "Unstake transfer failed");
        emit Unstaked(msg.sender, amount, tierId);
    }

    /**
     * @dev Distributes rewards to all tiers based on their respective staked amounts.
     * The rewards are distributed in a tithe system where each tier gives a percentage of its reward
     * to the tier above it.
     * @param amount The total amount of rewards to distribute.
     */
    function distributeRewards(uint256 amount) external onlyOwner nonReentrant {
        require(amount > 0, "Zero amount");

        // Cache the current index to save gas on multiple reads
        uint256 currentIndex = currentTierIndex;

        // Only allocate memory for active tiers
        TierData[] memory tierData = new TierData[](currentIndex + 1);
        uint256 totalStaked = 0;

        // First pass: Collect staking data and calculate initial rewards
        for (uint256 i = 0; i <= currentIndex; i++) {
            uint256 currentStake = tiers[i].currentStaked;
            if (currentStake > 0) {
                tierData[i].staked = currentStake;
                totalStaked += currentStake;
            }
        }

        require(totalStaked > 0, "No stakes");

        // Second pass: Calculate rewards and tithe in a single loop
        for (uint256 i = 0; i <= currentIndex; i++) {
            if (tierData[i].staked > 0) {
                // Calculate initial rewards
                tierData[i].rewards = (amount * tierData[i].staked) / totalStaked;

                // Apply tithe from current tier to previous tier
                if (i > 0 && tierData[i - 1].staked > 0) {
                    uint256 tithe = (tierData[i].rewards * TITHE_PERCENTAGE) / PERCENTAGE_BASE;
                    tierData[i].rewards -= tithe;
                    tierData[i - 1].rewards += tithe;
                }
            }
        }

        // Final pass: Update reward rates and prepare event data
        uint256[] memory newRates = new uint256[](currentIndex + 1);

        for (uint256 i = 0; i <= currentIndex; i++) {
            if (tierData[i].staked > 0) {
                uint256 newRewardRate = Math.mulDiv(tierData[i].rewards, PRECISION, tierData[i].staked);
                tiers[i].accRewardPerShare = newRewardRate;
                newRates[i] = newRewardRate;
            }
        }

        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        emit RewardsDistributed(amount, newRates);
    }

    /**
     * @dev Allows a user to claim rewards for a specified tier.
     * @param tierId The tier from which to claim rewards.
     */
    function claimRewards(uint256 tierId) external nonReentrant {
        Tier storage tier = tiers[tierId];
        uint256 userStake = tier.stakes[msg.sender];
        require(userStake > 0, "No stake in tier");

        uint256 pending = getPendingRewards(msg.sender, tierId);
        require(pending > 0, "No rewards to claim");

        uint256 newRewardDebt = Math.mulDiv(userStake, tier.accRewardPerShare, PRECISION);
        tier.rewardDebt[msg.sender] = newRewardDebt;

        require(token.transfer(msg.sender, pending), "Transfer failed");
        emit RewardsClaimed(msg.sender, tierId, pending);
    }

    /**
     * @dev Removes a staker from the list of stakers in a tier.
     * @param _staker The address of the staker to remove.
     * @param _tierId The tier index from which to remove the staker.
     */
    function removeStakerFromTier(address _staker, uint256 _tierId) internal {
        Tier storage tier = tiers[_tierId];
        uint256 index = tier.stakerIndices[_staker];
        uint256 lastIndex = tier.stakers.length - 1;

        // If not the last element, swap with last
        if (index != lastIndex) {
            address lastStaker = tier.stakers[lastIndex];
            tier.stakers[index] = lastStaker;
            tier.stakerIndices[lastStaker] = index;
        }

        // Remove last element
        tier.stakers.pop();
        delete tier.stakerIndices[_staker];

        emit StakerRemoved(_tierId, _staker);
    }

    /**
     * @dev Returns the cap and current staked amount of a tier.
     * @param _tierId The tier index.
     * @return cap The maximum stake cap for the tier.
     * @return currentStaked The current total staked amount in the tier.
     */
    function getTierInfo(uint256 _tierId) external view returns (uint256 cap, uint256 currentStaked) {
        require(_tierId <= currentTierIndex, "Invalid tier");
        Tier storage tier = tiers[_tierId];
        return (tier.cap, tier.currentStaked);
    }

    /**
     * @dev Returns a user's staking information for all tiers.
     * @param _user The address of the user.
     * @return stakesPerTier The amount of tokens staked by the user in each tier.
     * @return pendingRewardsPerTier The pending rewards for the user in each tier.
     * @return totalStaked The total amount of tokens staked by the user.
     * @return totalPendingRewards The total pending rewards for the user.
     */
    function getUserStakeInfo(address _user)
        external
        view
        returns (
            uint256[] memory stakesPerTier,
            uint256[] memory pendingRewardsPerTier,
            uint256 totalStaked,
            uint256 totalPendingRewards
        )
    {
        Staker storage staker = stakers[_user];

        stakesPerTier = new uint256[](maxTiers);
        pendingRewardsPerTier = new uint256[](maxTiers);
        totalPendingRewards = 0;

        for (uint256 i = 0; i < maxTiers; i++) {
            stakesPerTier[i] = staker.stakesPerTier[i];
            pendingRewardsPerTier[i] = getPendingRewards(_user, i);
            totalPendingRewards += pendingRewardsPerTier[i];
        }

        return (stakesPerTier, pendingRewardsPerTier, staker.totalStakedAmount, totalPendingRewards);
    }

    /**
     * @dev Returns the current reward rate for a specific tier.
     * @param tierId The index of the tier.
     * @return The reward rate for the tier.
     */
    function getTierRewardRate(uint256 tierId) external view returns (uint256) {
        return tiers[tierId].accRewardPerShare;
    }

    /**
     * @dev Calculates the pending rewards for a user in a specific tier.
     * @param user The address of the user.
     * @param tierId The index of the tier.
     * @return The pending rewards for the user.
     */
    function getPendingRewards(address user, uint256 tierId) public view returns (uint256) {
        Tier storage tier = tiers[tierId];
        uint256 userStake = tier.stakes[user];

        if (userStake == 0) return 0;

        // Use Math.mulDiv for safe multiplication and division with precision
        // First calculate total rewards using the full accumulated rate
        uint256 totalRewards = Math.mulDiv(userStake, tier.accRewardPerShare, PRECISION);

        // Safely subtract the reward debt
        return totalRewards >= tier.rewardDebt[user] ? totalRewards - tier.rewardDebt[user] : 0;
    }

    /**
     * @dev Returns the stake amount of a user in a specific tier.
     * @param _user The address of the user.
     * @param _tierId The index of the tier.
     * @return The amount staked by the user in the specified tier.
     */
    function getUserTierStake(address _user, uint256 _tierId) external view returns (uint256) {
        return stakers[_user].stakesPerTier[_tierId];
    }

    /*
     * @dev Returns total amount of users in live tiers
     * @return The amount of users in live tiers
     */

    function getTotalTierStakers() external view returns (uint256 totalStakers) {
        for (uint256 i = 0; i <= currentTierIndex; i++) {
            totalStakers += tiers[i].stakers.length;
        }
        return totalStakers;
    }
}
