//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {LibDiamondStorageReward} from "../storage/LibDiamondStorageReward.sol";
import {LibDiamondStorageProposals} from "../storage/LibDiamondStorageProposals.sol";
import {LibDiamondStorageEco} from "../storage/LibDiamondStorageEco.sol";

library LibRewardFacet {

    /**
     * @dev Event emitted when a reward is claimed by a contributor.
     */
    event RewardClaimed(
        string indexed proposalId,
        address indexed contributor,
        uint256 reward
    );

    /**
     * @dev Calculates the rewards for contributors based on the proposal.
     * @param proposalId The ID of the proposal to calculate rewards for.
     */
    function calculateRewards(string memory proposalId) internal {
        uint256 totalRewardPool = proposalStorage().proposalEcoAmounts[proposalId];
        uint256 totalContributors = proposalStorage().contributorList[proposalId].length;
        _getWeightedRewards(proposalId, totalRewardPool, totalContributors);
    }

    /**
     * @dev Allows a contributor to claim their reward.
     * @param proposalId The ID of the proposal the contributor is claiming rewards for.
     */
    function claimReward(string memory proposalId) internal {
        uint256 reward = rewardStorage().pendingRewards[proposalId][msg.sender];
        require(reward > 0, "No rewards to claim");
        require(ecoStorage().token.transfer(msg.sender, reward), "Reward transfer failed");
        rewardStorage().pendingRewards[proposalId][msg.sender] = 0;
        emit RewardClaimed(proposalId, msg.sender, reward);
    }

    /**
     * @dev Computes the weighted rewards for each contributor of a proposal.
     * @param proposalId The ID of the proposal.
     * @param totalRewardPool Total amount of eco contributed for the proposal.
     * @param totalContributors Total number of contributors for the proposal.
     */
    function _getWeightedRewards(
        string memory proposalId,
        uint256 totalRewardPool,
        uint256 totalContributors
    ) private {
        for (uint256 i = 0; i < totalContributors; i++) {
            address contributor = proposalStorage().contributorList[proposalId][i];
            uint256 contributorPortion = rewardStorage().contributorCharacterCount[proposalId][contributor] * 1e18;
            uint256 contributorWeight = contributorPortion / rewardStorage().totalCharactersForProposal[proposalId];
            uint256 reward = (totalRewardPool * contributorWeight) / 1e18;
            rewardStorage().pendingRewards[proposalId][contributor] = reward;
        }
    }

    /**
     * @dev Retrieves the reward storage instance.
     * @return An instance of the DiamondStorageReward.
     */
    function rewardStorage() private pure returns (LibDiamondStorageReward.DiamondStorageReward storage) {
        return LibDiamondStorageReward.diamondStorageReward();
    }

    /**
     * @dev Retrieves the proposal storage instance.
     * @return An instance of the DiamondStorageProposals.
     */
    function proposalStorage() private pure returns (LibDiamondStorageProposals.DiamondStorageProposals storage) {
        return LibDiamondStorageProposals.diamondStorageProposals();
    }

    /**
     * @dev Retrieves the eco storage instance.
     * @return An instance of the DiamondStorageEco.
     */
    function ecoStorage() private pure returns (LibDiamondStorageEco.DiamondStorageEco storage) {
        return LibDiamondStorageEco.diamondStorageEco();
    }
}
