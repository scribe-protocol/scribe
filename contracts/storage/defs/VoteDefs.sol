// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library VoteDefs {
    enum VoteType {
        YES,
        NO,
        ABSTAIN
    }

    enum VoteResult {
        PENDING, // Voting hasn't concluded
        ACCEPTED, // Majority of votes were "YES"
        REJECTED // Majority of votes were "NO" or there was a tie
    }

    enum SessionType {
        CONTRIBUTION,
        FINALIZATION
    }

    struct Vote {
        address voter;
        VoteType voteType;
    }

    struct VotingSession {
        uint256 startTime;
        uint256 endTime;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 abstainVotes;
        SessionType sessionType;
        VoteResult result; // An enum representing the overall result of the vote
    }
}
