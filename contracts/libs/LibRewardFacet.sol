//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {LibStorageRetrieval} from "./LibStorageRetrieval.sol";

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
        uint256 totalRewardPool = LibStorageRetrieval
            .proposalStorage()
            .proposalEcoAmounts[proposalId];
        uint256 totalContributors = LibStorageRetrieval
            .proposalStorage()
            .contributorList[proposalId]
            .length;
        _getWeightedRewards(proposalId, totalRewardPool, totalContributors);
    }

    /**
     * @dev Allows a contributor to claim their reward.
     * @param proposalId The ID of the proposal the contributor is claiming rewards for.
     */
    function claimReward(string memory proposalId) internal {
        uint256 reward = LibStorageRetrieval.rewardStorage().pendingRewards[
            proposalId
        ][msg.sender];
        require(reward > 0, "No rewards to claim");
        require(
            LibStorageRetrieval.ecoStorage().token.transfer(msg.sender, reward),
            "Reward transfer failed"
        );
        LibStorageRetrieval.rewardStorage().pendingRewards[proposalId][
            msg.sender
        ] = 0;
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
            address contributor = LibStorageRetrieval
                .proposalStorage()
                .contributorList[proposalId][i];
            uint256 contributorPortion = LibStorageRetrieval
                .rewardStorage()
                .contributorCharacterCount[proposalId][contributor] * 1e18;
            uint256 contributorWeight = contributorPortion /
                LibStorageRetrieval.rewardStorage().totalCharactersForProposal[
                    proposalId
                ];
            uint256 reward = (totalRewardPool * contributorWeight) / 1e18;
            LibStorageRetrieval.rewardStorage().pendingRewards[proposalId][
                    contributor
                ] = reward;
        }
    }
}
