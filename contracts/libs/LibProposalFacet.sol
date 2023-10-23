// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibDiamondStorageProposals} from "../storage/LibDiamondStorageProposals.sol";
import {ProposalDefs} from "../storage/defs/ProposalDefs.sol";
import {LibDiamond} from "../diamond/libs/LibDiamond.sol";

library LibProposalFacet {

    // Event emitted when a new proposal is created.
    event NewProposal(
        string indexed proposalId,
        address indexed proposer,
        string indexed cid
    );

    /**
     * @dev Create a new proposal.
     * This function sets up a new proposal with a given ID and content identifier.
     * It also marks the sender as a contributor to the proposal and emits a NewProposal event.
     *
     * @param _proposalId - Unique identifier for the proposal.
     * @param _cid - Content Identifier linked with web3.storage/IPFS where proposal details are stored.
     */
    function createProposal(
        string memory _proposalId,
        string memory _cid
    ) internal {
        // Access the diamond storage for proposals
        LibDiamondStorageProposals.DiamondStorageProposals
            storage ds = LibDiamondStorageProposals.diamondStorageProposals();

        // Check if the proposal already exists
        require(
            ds.proposals[_proposalId].proposer == address(0),
            "Proposal already exists"
        );

        // Create and store the new proposal
        ds.proposals[_proposalId] = ProposalDefs.Proposal(
            _proposalId,
            msg.sender,
            _cid
        );

        // Mark the sender as a contributor to this proposal
        ds.isContributor[_proposalId][msg.sender] = true;

        // Add the sender to the list of contributors for this proposal
        ds.contributorList[_proposalId].push(msg.sender);

        // Emit an event to signal the creation of the new proposal
        emit NewProposal(_proposalId, msg.sender, _cid);
    }

    /**
     * @dev Retrieve the details of a specific proposal using its ID.
     * This function fetches the details of a proposal from storage.
     *
     * @param _proposalId - The ID of the proposal to fetch.
     * @return Proposal details, including ID, proposer, and CID.
     */
    function getProposal(
        string memory _proposalId
    ) internal view returns (ProposalDefs.Proposal memory) {
        // Access the diamond storage for proposals
        LibDiamondStorageProposals.DiamondStorageProposals
            storage ds = LibDiamondStorageProposals.diamondStorageProposals();
        
        // Return the proposal details
        return ds.proposals[_proposalId];
    }

    /**
     * @dev Update the Content Identifier (CID) of a proposal.
     * This function allows the contract owner to update the CID of a proposal.
     *
     * @param _proposalId - The ID of the proposal to update.
     * @param _cid - The new Content Identifier.
     */
    function updateCid(string memory _proposalId, string memory _cid) internal {
        // Access the diamond storage for proposals
        LibDiamondStorageProposals.DiamondStorageProposals
            storage ds = LibDiamondStorageProposals.diamondStorageProposals();

        // Ensure only the contract owner can update the CID
        LibDiamond.enforceIsContractOwner();

        // Update the CID in storage
        ds.proposals[_proposalId].cid = _cid;
    }
}
