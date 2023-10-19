// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {VoteDefs} from "../storage/defs/VoteDefs.sol";
import {LibDiamondStorageVoting} from "../storage/LibDiamondStorageVoting.sol";
import {LibDiamondStorageProposals} from "../storage/LibDiamondStorageProposals.sol";
import {LibDiamondStorageContributions} from "../storage/LibDiamondStorageContributions.sol";
import { LibProposalFacet } from "../libs/LibProposalFacet.sol";
import { LibVotingFacet } from "../libs/LibVotingFacet.sol";

contract VotingFacet {
    event VotingSessionStarted(
        string indexed proposalId,
        uint256 contributionId,
        uint256 indexed startTime,
        uint256 indexed endTime,
        VoteDefs.SessionType sessionType
    );

    event VoteCast(
        string proposalId,
        uint256 indexed contributionId,
        address indexed voter,
        VoteDefs.VoteType indexed voteType
    );

    event VotingSessionEnded(
        string indexed proposalId,
        uint256 contributionId,
        VoteDefs.SessionType indexed sessionType,
        uint256 yesVotes,
        uint256 noVotes,
        uint256 abstainVotes,
        VoteDefs.VoteResult indexed result
    );

    modifier onlyContributor(string memory _proposalId) {
        LibDiamondStorageProposals.DiamondStorageProposals
            storage dsProposals = LibDiamondStorageProposals
                .diamondStorageProposals();
        require(
            dsProposals.isContributor[_proposalId][msg.sender],
            "Caller is not a contributor"
        );
        _;
    }

    function startVotingSession(
        string memory _proposalId,
        uint256 _contributionId,
        VoteDefs.SessionType _sessionType
    ) external onlyContributor(_proposalId) {
        LibDiamondStorageVoting.DiamondStorageVoting
            storage ds = LibDiamondStorageVoting.diamondStorageVoting();

        VoteDefs.VotingSession storage votingSession = ds.votingSessions[
            _proposalId
        ][_contributionId];

        require(
            votingSession.startTime == 0,
            "VotingFacet.StartVotingSession: voting session already started"
        );

        uint256 _startTime = block.timestamp;
        uint256 _endTime = _startTime + 1 days;
        uint256 _yesVotes = 0;
        uint256 _noVotes = 0;
        uint256 _abstainVotes = 0;
        VoteDefs.VoteResult _result = VoteDefs.VoteResult.PENDING;

        votingSession.startTime = _startTime;
        votingSession.endTime = _endTime;
        votingSession.yesVotes = _yesVotes;
        votingSession.noVotes = _noVotes;
        votingSession.abstainVotes = _abstainVotes;
        votingSession.sessionType = _sessionType;
        votingSession.result = _result;

        emit VotingSessionStarted(
            _proposalId,
            _contributionId,
            _startTime,
            _endTime,
            _sessionType
        );
    }

    function submitVote(
        string memory _proposalId,
        uint256 _contributionId,
        VoteDefs.VoteType _voteType
    ) external onlyContributor(_proposalId) {
        LibDiamondStorageVoting.DiamondStorageVoting
            storage ds = LibDiamondStorageVoting.diamondStorageVoting();

        VoteDefs.VotingSession storage votingSession = ds.votingSessions[
            _proposalId
        ][_contributionId];

        VoteDefs.Vote storage vote = ds.votes[_proposalId][_contributionId][
            msg.sender
        ];

        require(
            votingSession.startTime < block.timestamp &&
                votingSession.endTime > block.timestamp,
            "VotingFacet.SubmitVote: voting session is not active"
        );
        // Check if the user has already voted
        require(
            vote.voter == address(0),
            "VotingFacet.SubmitVote: voter has already voted"
        );

        vote.voter = msg.sender;
        vote.voteType = _voteType;

        if (_voteType == VoteDefs.VoteType.YES) votingSession.yesVotes++;
        else if (_voteType == VoteDefs.VoteType.NO) votingSession.noVotes++;
        else votingSession.abstainVotes++;

        // Increment the vote count
        ds.votesCount[_proposalId][_contributionId]++;

        emit VoteCast(_proposalId, _contributionId, msg.sender, _voteType);
    }

    function endVotingSession(
        string memory _proposalId,
        uint256 _contributionId
    ) external onlyContributor(_proposalId) {
        LibDiamondStorageVoting.DiamondStorageVoting
            storage ds = LibDiamondStorageVoting.diamondStorageVoting();
        LibDiamondStorageProposals.DiamondStorageProposals
            storage dsProposals = LibDiamondStorageProposals
                .diamondStorageProposals();

        VoteDefs.VotingSession storage votingSession = ds.votingSessions[_proposalId][_contributionId];

        // Ensure the proposal exists
        require(
            dsProposals.proposals[_proposalId].proposer != address(0),
            "VotingFacet.endVotingSession: proposal does not exist"
        );

        // Check if everyone has voted
        uint256 totalContributors = LibProposalFacet
            .getContributorCount(_proposalId);

        // Get total votes cast
        uint256 totalVotesCast = LibVotingFacet.getVotesCount(
            _proposalId,
            _contributionId
        );

        // If neither condition is met, revert
        require(
            (block.timestamp > votingSession.endTime) ||
                totalVotesCast == totalContributors,
            "VotingFacet.endVotingSession: Voting session cannot be ended yet because the timer has not expired and not everyone has voted"
        );

        VoteDefs.VoteResult result = LibVotingFacet.determineVoteResult(
            votingSession.sessionType,
            votingSession.yesVotes,
            totalContributors
        );


        if (
            votingSession.sessionType == VoteDefs.SessionType.CONTRIBUTION &&
            result == VoteDefs.VoteResult.ACCEPTED
        ) {
            //TODO: Handle accepted contribution voting session
        }

        if (
            votingSession.sessionType == VoteDefs.SessionType.FINALIZATION &&
            result == VoteDefs.VoteResult.ACCEPTED
        ) {
            //TODO: Handle accepted finalization voting session
        }

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
}
