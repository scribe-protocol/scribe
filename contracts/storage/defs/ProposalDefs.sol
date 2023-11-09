// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library ProposalDefs {
    enum ProposalStatus {
        OPEN,
        CLOSED,
        FINALIZED
    }
    struct Proposal {
        string proposalId;
        address proposer;
        ProposalStatus status; // 0: OPEN, 1: CLOSED, 2: FINALIZED
        string cid; // cid string pointing to the proposal data (bookId, title, description, proposer, contributors, content, creationTimestamp, lastUpdatedTimestamp)
    }
}
