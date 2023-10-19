// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {LibDiamondStorageVoting} from "../storage/LibDiamondStorageVoting.sol";
import {VoteDefs} from "../storage/defs/VoteDefs.sol";

library LibVotingFacet {
    function getVotesCount(
        string memory _proposalId,
        uint256 _contributionId
    ) internal view returns (uint256) {
        LibDiamondStorageVoting.DiamondStorageVoting
            storage ds = LibDiamondStorageVoting.diamondStorageVoting();
        return ds.votesCount[_proposalId][_contributionId];
    }

    function determineVoteResult(
        VoteDefs.SessionType sessionType,
        uint256 yesVotes,
        uint256 totalContributors
    ) internal pure returns (VoteDefs.VoteResult) {
        if (sessionType == VoteDefs.SessionType.FINALIZATION) {
            return
                (yesVotes * 100 >= totalContributors * 75)
                    ? VoteDefs.VoteResult.ACCEPTED
                    : VoteDefs.VoteResult.REJECTED;
        }

        if (totalContributors == 1) {
            return
                (yesVotes == 1)
                    ? VoteDefs.VoteResult.ACCEPTED
                    : VoteDefs.VoteResult.REJECTED;
        }

        if (totalContributors == 2) {
            return
                (yesVotes == 2)
                    ? VoteDefs.VoteResult.ACCEPTED
                    : VoteDefs.VoteResult.REJECTED;
        }

        // Default case for totalContributors > 2
        return
            (yesVotes * 2 > totalContributors)
                ? VoteDefs.VoteResult.ACCEPTED
                : VoteDefs.VoteResult.REJECTED;
    }
}
