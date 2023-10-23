// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {VoteDefs} from "../storage/defs/VoteDefs.sol";
import {ContributionDefs} from "../storage/defs/ContributionDefs.sol";
import {LibDiamond} from "../diamond/libs/LibDiamond.sol";
import {LibStorageRetrieval} from "./LibStorageRetrieval.sol";

library LibVotingFacet {
    /**
     * @notice Emitted when a new voting session starts for a proposal.
     * @param proposalId Unique identifier for the proposal under vote.
     * @param contributionId Identifier for the contribution associated with the proposal.
     * @param startTime Timestamp indicating when the voting session started.
     * @param endTime Timestamp indicating when the voting session will end.
     * @param sessionType The type of voting session - either CONTRIBUTION or FINALIZATION.
     */
    event VotingSessionStarted(
        string indexed proposalId,
        uint256 contributionId,
        uint256 indexed startTime,
        uint256 indexed endTime,
        VoteDefs.SessionType sessionType
    );

    /**
     * @notice Emitted when a vote is cast by a contributor for a proposal.
     * @param proposalId Unique identifier for the proposal under vote.
     * @param contributionId Identifier for the contribution associated with the proposal.
     * @param voter Address of the contributor who cast the vote.
     * @param voteType The type of vote cast - either YES, NO, or ABSTAIN.
     */
    event VoteCast(
        string proposalId,
        uint256 indexed contributionId,
        address indexed voter,
        VoteDefs.VoteType indexed voteType
    );

    /**
     * @notice Emitted when a voting session ends for a proposal.
     * @param proposalId Unique identifier for the proposal under vote.
     * @param contributionId Identifier for the contribution associated with the proposal.
     * @param sessionType The type of voting session that ended.
     * @param yesVotes Total number of YES votes cast during the session.
     * @param noVotes Total number of NO votes cast during the session.
     * @param abstainVotes Total number of ABSTAIN votes cast during the session.
     * @param result The final result of the voting session - either ACCEPTED, REJECTED, or PENDING.
     */
    event VotingSessionEnded(
        string indexed proposalId,
        uint256 contributionId,
        VoteDefs.SessionType indexed sessionType,
        uint256 yesVotes,
        uint256 noVotes,
        uint256 abstainVotes,
        VoteDefs.VoteResult indexed result
    );

    /**
     * @dev Modifier to ensure that the function caller is either a contributor of a specific proposal or the contract owner.
     * @param _proposalId The ID of the proposal to check against.
     *
     * This modifier first retrieves the diamond storage and diamond storage for proposals. It then checks if the caller
     * is a contributor for the given proposal or if the caller is the contract owner. If neither of these conditions is met,
     * it reverts the transaction with a message indicating that the caller does not have the required permissions.
     */
    modifier onlyContributorOrOwner(string memory _proposalId) {
        // Check if the caller is a contributor to the proposal or is the contract owner.
        require(
            LibStorageRetrieval.proposalStorage().isContributor[_proposalId][
                msg.sender
            ] ||
                msg.sender ==
                LibStorageRetrieval.diamondStorage().contractOwner,
            "Caller is neither contributor nor owner"
        );

        // Continue with the execution of the function this modifier is applied to.
        _;
    }

    /**
     * @notice Initiates a new voting session for a given proposal.
     * @dev This function can only be called by the contract owner or a contributor to the proposal.
     *
     * @param _proposalId Unique identifier for the proposal.
     * @param _contributionId Identifier for the contribution associated with the proposal.
     * @param _sessionType The type of voting session being initiated - either CONTRIBUTION or FINALIZATION.
     */
    function startVotingSession(
        string memory _proposalId,
        uint256 _contributionId,
        VoteDefs.SessionType _sessionType
    ) internal onlyContributorOrOwner(_proposalId) {
        // Reference to the current voting session.
        VoteDefs.VotingSession storage votingSession = LibStorageRetrieval
            .votingStorage()
            .votingSessions[_proposalId][_contributionId];

        // Ensure that the voting session hasn't already started.
        require(
            votingSession.startTime == 0,
            "VotingFacet.StartVotingSession: voting session already started"
        );

        // Define the start time, end time, and initial vote counts.
        uint256 _startTime = block.timestamp;
        uint256 _endTime = _startTime + 1 days;
        uint256 _yesVotes = 0;
        uint256 _noVotes = 0;
        uint256 _abstainVotes = 0;
        VoteDefs.VoteResult _result = VoteDefs.VoteResult.PENDING;

        // Update the voting session's data in storage.
        votingSession.startTime = _startTime;
        votingSession.endTime = _endTime;
        votingSession.yesVotes = _yesVotes;
        votingSession.noVotes = _noVotes;
        votingSession.abstainVotes = _abstainVotes;
        votingSession.sessionType = _sessionType;
        votingSession.result = _result;

        // Emit an event to indicate the start of a voting session.
        emit VotingSessionStarted(
            _proposalId,
            _contributionId,
            _startTime,
            _endTime,
            _sessionType
        );
    }

    /**
     * @notice Allows a contributor to cast their vote for a given contribution.
     * @dev This function can only be called by the contract owner or a contributor of the proposal and within the active voting session.
     *
     * @param _proposalId Unique identifier for the proposal being voted on.
     * @param _contributionId Identifier for the contribution associated with the proposal.
     * @param _voteType The type of vote being cast - either YES, NO, or ABSTAIN.
     */
    function submitVote(
        string memory _proposalId,
        uint256 _contributionId,
        VoteDefs.VoteType _voteType
    ) internal onlyContributorOrOwner(_proposalId) {
        // Reference to the current voting session for the given proposal and contribution.
        VoteDefs.VotingSession storage votingSession = LibStorageRetrieval
            .votingStorage()
            .votingSessions[_proposalId][_contributionId];

        // Reference to the vote of the current contributor for the given proposal and contribution.
        VoteDefs.Vote storage vote = LibStorageRetrieval.votingStorage().votes[
            _proposalId
        ][_contributionId][msg.sender];

        // Ensure the voting session is currently active.
        require(
            votingSession.startTime < block.timestamp &&
                votingSession.endTime > block.timestamp,
            "VotingFacet.SubmitVote: voting session is not active"
        );

        // Ensure the contributor hasn't already voted in this session.
        require(
            vote.voter == address(0),
            "VotingFacet.SubmitVote: voter has already voted"
        );

        // Record the vote.
        vote.voter = msg.sender;
        vote.voteType = _voteType;

        // Update the respective vote counts based on the type of vote.
        if (_voteType == VoteDefs.VoteType.YES) votingSession.yesVotes++;
        else if (_voteType == VoteDefs.VoteType.NO) votingSession.noVotes++;
        else votingSession.abstainVotes++;

        // Increment the total number of votes for this proposal and contribution.
        LibStorageRetrieval.votingStorage().votesCount[_proposalId][
            _contributionId
        ]++;

        // Emit an event indicating the vote has been cast.
        emit VoteCast(_proposalId, _contributionId, msg.sender, _voteType);
    }

    /**
     * @notice Ends the voting session for a given proposal and contribution.
     * @dev This function can only be called by the contract owner or a proposal contributor. It will determine the vote result
     * and apply the respective consequences based on the result.
     *
     * @param _proposalId Unique identifier for the proposal being voted on.
     * @param _contributionId Identifier for the contribution associated with the proposal.
     */
    function endVotingSession(
        string memory _proposalId,
        uint256 _contributionId
    ) internal onlyContributorOrOwner(_proposalId) {
        // Reference to the current voting session for the given proposal and contribution.
        VoteDefs.VotingSession storage votingSession = LibStorageRetrieval.votingStorage().votingSessions[
            _proposalId
        ][_contributionId];

        // Ensure that the proposal for which the session is ending exists.
        require(
            LibStorageRetrieval.proposalStorage().proposals[_proposalId].proposer != address(0),
            "VotingFacet.endVotingSession: proposal does not exist"
        );

        // Get total contributors for the proposal.
        uint256 totalContributors = LibStorageRetrieval.proposalStorage()
            .contributorList[_proposalId]
            .length;

        // Get total votes cast for this session.
        uint256 totalVotesCast = LibStorageRetrieval.votingStorage().votesCount[_proposalId][_contributionId];

        // Ensure that either the voting session time has expired or all contributors have voted.
        require(
            (block.timestamp > votingSession.endTime) ||
                totalVotesCast == totalContributors,
            "VotingFacet.endVotingSession: Voting session cannot be ended yet because the timer has not expired and not everyone has voted"
        );

        // Determine the result of the vote.
        VoteDefs.VoteResult result = _determineVoteResult(
            votingSession.sessionType,
            votingSession.yesVotes,
            totalContributors
        );

        // If the vote was for a contribution and it was accepted, apply the consequences.
        if (
            votingSession.sessionType == VoteDefs.SessionType.CONTRIBUTION &&
            result == VoteDefs.VoteResult.ACCEPTED
        ) {
            // Set the vote result to ACCEPTED.
            LibStorageRetrieval.votingStorage().votingSessions[_proposalId][_contributionId].result = VoteDefs
                .VoteResult
                .ACCEPTED;

            // Add the contributor to the list of contributors for the proposal.
            ContributionDefs.Contribution storage contribution = LibStorageRetrieval.contributionStorage()
                .contributions[_proposalId][_contributionId];
            LibStorageRetrieval.proposalStorage().isContributor[_proposalId][
                contribution.contributor
            ] = true;
            LibStorageRetrieval.proposalStorage().contributorList[_proposalId].push(
                contribution.contributor
            );

            // Update the reward counters for this contributor and proposal.
            LibStorageRetrieval.rewardStorage().contributorCharacterCount[_proposalId][
                contribution.contributor
            ] += contribution.characterCount;
            LibStorageRetrieval.rewardStorage().totalCharactersForProposal[_proposalId] += contribution
                .characterCount;
        }

        // If the vote was for finalizing the proposal and it was accepted, finalize the proposal.
        if (
            votingSession.sessionType == VoteDefs.SessionType.FINALIZATION &&
            result == VoteDefs.VoteResult.ACCEPTED
        ) {
            LibStorageRetrieval.votingStorage().votingSessions[_proposalId][_contributionId].result = VoteDefs
                .VoteResult
                .ACCEPTED;
            LibStorageRetrieval.votingStorage().isFinalized[_proposalId] = true;
        }

        // Emit an event to signal the end of the voting session with its outcome.
        emit VotingSessionEnded(
            _proposalId,
            _contributionId,
            votingSession.sessionType,
            votingSession.yesVotes,
            votingSession.noVotes,
            votingSession.abstainVotes,
            result
        );
    }

    /**
     * @notice Checks if a given proposal has been finalized.
     * @dev This function reads the state from the diamond storage specific to the voting facet.
     *
     * @param _proposalId Unique identifier for the proposal being checked.
     * @return bool True if the proposal is finalized, false otherwise.
     */
    function isProposalFinalized(
        string memory _proposalId
    ) internal view returns (bool) {
        // Return the finalized state of the given proposal.
        return LibStorageRetrieval.votingStorage().isFinalized[_proposalId];
    }

    /**
     * @notice Determines the result of a vote based on the session type, the number of yes votes, and total contributors.
     * @dev This function helps in determining whether a proposal or contribution should be accepted or rejected based on the voting mechanism.
     *      For finalization sessions, the acceptance threshold is 75%. Special considerations are in place for scenarios with one or two contributors.
     *
     * @param sessionType The type of voting session being evaluated, i.e., either FINALIZATION or CONTRIBUTION.
     * @param yesVotes The number of affirmative votes received during the voting session.
     * @param totalContributors Total number of eligible voters for the proposal or contribution.
     * @return VoteDefs.VoteResult Enum value indicating if the vote is ACCEPTED or REJECTED.
     */
    function _determineVoteResult(
        VoteDefs.SessionType sessionType,
        uint256 yesVotes,
        uint256 totalContributors
    ) internal pure returns (VoteDefs.VoteResult) {
        // For finalization sessions, a proposal is accepted if it receives at least 75% yes votes.
        if (sessionType == VoteDefs.SessionType.FINALIZATION) {
            return
                (yesVotes * 100 >= totalContributors * 75)
                    ? VoteDefs.VoteResult.ACCEPTED
                    : VoteDefs.VoteResult.REJECTED;
        }

        // If there's only one contributor, a yes vote results in acceptance, otherwise it's rejected.
        if (totalContributors == 1) {
            return
                (yesVotes == 1)
                    ? VoteDefs.VoteResult.ACCEPTED
                    : VoteDefs.VoteResult.REJECTED;
        }

        // If there are two contributors, both need to vote yes for acceptance.
        if (totalContributors == 2) {
            return
                (yesVotes == 2)
                    ? VoteDefs.VoteResult.ACCEPTED
                    : VoteDefs.VoteResult.REJECTED;
        }

        // For scenarios with more than two contributors, acceptance requires over 50% yes votes.
        // Default case for totalContributors > 2
        return
            (yesVotes * 2 > totalContributors)
                ? VoteDefs.VoteResult.ACCEPTED
                : VoteDefs.VoteResult.REJECTED;
    }
}
