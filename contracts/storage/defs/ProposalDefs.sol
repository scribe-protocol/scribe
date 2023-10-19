// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library ProposalDefs {
    struct Proposal {
        string proposalId;
        address proposer;
        string cid; // cid string pointing to the proposal data (bookId, title, description, proposer, contributors, content, creationTimestamp, lastUpdatedTimestamp)
    }
}