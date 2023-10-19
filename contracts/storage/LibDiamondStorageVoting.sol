// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {VoteDefs} from "./defs/VoteDefs.sol";

library LibDiamondStorageVoting {
    struct DiamondStorageVoting {
        // Mapping to store voting sessions
        mapping(string => mapping(uint256 => VoteDefs.VotingSession)) votingSessions; // proposalId => contributionId => VotingSession
        // Mapping to store votes
        mapping(string => mapping(uint256 => mapping(address => VoteDefs.Vote))) votes; // proposalId => contributionId => voterAddress => Vote
        // Mapping to store votes count
        mapping(string => mapping(uint256 => uint256)) votesCount; // proposalId => contributionId => number of votes
    }

    bytes32 constant DIAMOND_STORAGE_VOTING =
        keccak256("scribe.storage.Voting");

    function diamondStorageVoting()
        internal
        pure
        returns (DiamondStorageVoting storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_VOTING;
        assembly {
            ds.slot := position
        }
    }
}
