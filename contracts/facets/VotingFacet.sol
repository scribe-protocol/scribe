// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {VoteDefs} from "../storage/defs/VoteDefs.sol";
import {ContributionDefs} from "../storage/defs/ContributionDefs.sol";
import {LibDiamondStorageVoting} from "../storage/LibDiamondStorageVoting.sol";
import {LibDiamondStorageProposals} from "../storage/LibDiamondStorageProposals.sol";
import {LibDiamondStorageContributions} from "../storage/LibDiamondStorageContributions.sol";
import {LibDiamondStorageReward} from "../storage/LibDiamondStorageReward.sol";
import {LibProposalFacet} from "../libs/LibProposalFacet.sol";
import {LibVotingFacet} from "../libs/LibVotingFacet.sol";

/**
 * @title Voting Facet Contract
 * @notice This contract facilitates voting operations on contributions.
 * @dev This contract delegates most of its logic 
 * to the `LibVotingFacet` library. Each function corresponds to an operation 
 * within the voting process such as starting a session, casting votes, or ending a session.
 */
contract VotingFacet {

    /**
     * @notice Begins a voting session for a specific proposal and contribution.
     * @dev Initiates a voting session based on the provided proposal ID, contribution ID, 
     * and the type of voting session.
     *
     * @param _proposalId The unique ID of the proposal.
     * @param _contributionId The ID of the contribution associated with the proposal.
     * @param _sessionType The type of voting session, i.e., CONTRIBUTION or FINALIZATION.
     */
    function startVotingSession(
        string memory _proposalId,
        uint256 _contributionId,
        VoteDefs.SessionType _sessionType
    ) external {
        LibVotingFacet.startVotingSession(_proposalId, _contributionId, _sessionType);
    }

    /**
     * @notice Allows an eligible contributor to cast their vote on a proposal.
     * @dev Records a contributor's vote based on the given proposal ID, contribution ID, 
     * and the type of vote (YES, NO, ABSTAIN).
     *
     * @param _proposalId The unique ID of the proposal.
     * @param _contributionId The ID of the contribution associated with the proposal.
     * @param _voteType The type of vote cast by the contributor.
     */
    function submitVote(
        string memory _proposalId,
        uint256 _contributionId,
        VoteDefs.VoteType _voteType
    ) external {
        LibVotingFacet.submitVote(_proposalId, _contributionId, _voteType);
    }

    /**
     * @notice Concludes a voting session for a specific proposal and contribution.
     * @dev Ends a voting session and determines the result based on votes collected.
     *
     * @param _proposalId The unique ID of the proposal.
     * @param _contributionId The ID of the contribution associated with the proposal.
     */
    function endVotingSession(
        string memory _proposalId,
        uint256 _contributionId
    ) external {
        LibVotingFacet.endVotingSession(_proposalId, _contributionId);
    }

    /**
     * @notice Checks if a given proposal has been finalized.
     * @dev Returns the finalized status of a proposal based on its ID.
     *
     * @param _proposalId The unique ID of the proposal.
     * @return bool True if the proposal is finalized, otherwise False.
     */
    function isProposalFinalized(
        string memory _proposalId
    ) external view returns (bool) {
        return LibVotingFacet.isProposalFinalized(_proposalId);
    }
}

