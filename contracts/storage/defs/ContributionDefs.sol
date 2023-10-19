// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library ContributionDefs {
    struct Contribution {
        string proposalId;
        uint256 contributionId;
        address contributor;
        uint256 ecoAmount;
        string cid; // cid of the contribution content (proposalId, contributor, content, ecoAmount, timestamp)
    }
}