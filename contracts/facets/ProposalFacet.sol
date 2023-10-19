// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibDiamondStorageProposals} from "../storage/LibDiamondStorageProposals.sol";
import {ProposalDefs} from "../storage/defs/ProposalDefs.sol";
import {LibDiamond} from "../diamond/libs/LibDiamond.sol";

contract ProposalFacet {
    //Event to emit when a new proposal is created
    event NewProposal(
        string indexed proposalId,
        address indexed proposer,
        string indexed cid
    );

    /**
     * @dev Create a new book proposal.
     *
     * Requirements:
     * - Proposal with the same ID should not exist already.
     *
     * @param _proposalId - Unique identifier for the proposal.
     * @param _cid - Content Identifier linked with web3.storage/IPFS where proposal details are stored.
     */
    function createProposal(
        string memory _proposalId,
        string memory _cid
    ) external {
        LibDiamondStorageProposals.DiamondStorageProposals
            storage ds = LibDiamondStorageProposals.diamondStorageProposals();

        // Ensure that a proposal with the same ID does not already exist
        require(
            ds.proposals[_proposalId].proposer == address(0),
            "Proposal already exists"
        );

        ds.proposals[_proposalId] = ProposalDefs.Proposal(
            _proposalId,
            msg.sender,
            _cid
        );

        // Mark the sender as a contributor to this proposal
        ds.isContributor[_proposalId][msg.sender] = true;

        // Add the sender to the list of contributors for this proposal
        ds.contributorList[_proposalId].push(msg.sender);

        emit NewProposal(_proposalId, msg.sender, _cid);
    }

    /**
     * @dev Fetch the details of a specific proposal using its ID.
     *
     * @param _proposalId - The ID of the proposal to fetch.
     * @return Proposal details, including ID, proposer, and CID.
     */
    function getProposal(
        string memory _proposalId
    ) external view returns (ProposalDefs.Proposal memory) {
        LibDiamondStorageProposals.DiamondStorageProposals
            storage ds = LibDiamondStorageProposals.diamondStorageProposals();
        return ds.proposals[_proposalId];
    }

    function updateCid(string memory _proposalId, string memory _cid) external {
        LibDiamondStorageProposals.DiamondStorageProposals
            storage ds = LibDiamondStorageProposals.diamondStorageProposals();
        LibDiamond.enforceIsContractOwner();
        ds.proposals[_proposalId].cid = _cid;
    }
}
