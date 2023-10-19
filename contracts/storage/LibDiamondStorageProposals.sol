// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ProposalDefs} from "./defs/ProposalDefs.sol";

library LibDiamondStorageProposals {
    struct DiamondStorageProposals {
        //Mapping to store proposals with an identifier
        mapping(string => ProposalDefs.Proposal) proposals; // bookId => Proposal
        // Mapping to keep track of if a contributor is valid for a proposal for 0(1) lookup
        mapping(string => mapping(address => bool)) isContributor; // proposalId => (contributorAddress => hasContributed)
        // Mapping to store a list of contributors for a proposal
        mapping(string => address[]) contributorList; // proposalId => array of contributor addresses
    }

    bytes32 constant DIAMOND_STORAGE_PROPOSALS =
        keccak256("scribe.storage.Proposals");

    function diamondStorageProposals()
        internal
        pure
        returns (DiamondStorageProposals storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_PROPOSALS;
        assembly {
            ds.slot := position
        }
    }
}
