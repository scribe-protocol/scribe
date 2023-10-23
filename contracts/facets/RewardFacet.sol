//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {LibRewardFacet} from "../libs/LibRewardFacet.sol";

/**
 * @title RewardFacet
 * @dev Contract for handling rewards for proposals. Utilizes LibRewardFacet for internal operations.
 */
contract RewardFacet {

    /**
     * @dev Public function that calculates rewards for a given proposal.
     * This function is a simple forwarder to the corresponding function in LibRewardFacet.
     * 
     * @param proposalId The ID of the proposal for which rewards need to be calculated.
     */
    function calculateRewards(string memory proposalId) external {
        LibRewardFacet.calculateRewards(proposalId);
    }

    /**
     * @dev Public function that allows a contributor to claim their rewards for a proposal.
     * This function is a simple forwarder to the corresponding function in LibRewardFacet.
     * 
     * @param proposalId The ID of the proposal from which the contributor wants to claim rewards.
     */
    function claimReward(string memory proposalId) external {
        LibRewardFacet.claimReward(proposalId);
    }
}
