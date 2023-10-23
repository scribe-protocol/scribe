// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibProposalFacet} from "../libs/LibProposalFacet.sol";
import {ProposalDefs} from "../storage/defs/ProposalDefs.sol";

/**
 * @title Proposal Facet Contract
 * @notice Manages the creation, retrieval, and updating of proposals within the system.
 * Each proposal is uniquely identified by a proposal ID and contains a content identifier (CID)
 * which points to the details of the proposal stored on web3.storage or IPFS.
 * The contract delegates logic to the `LibProposalFacet` library.
 *
 */
contract ProposalFacet {
    /**
     * @dev Create a new proposal.
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
        LibProposalFacet.createProposal(_proposalId, _cid);
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
        return LibProposalFacet.getProposal(_proposalId);
    }

    /**
     * @dev Update the Content Identifier (CID) of a proposal.
     *
     * @param _proposalId - The ID of the proposal to update.
     * @param _cid - The new Content Identifier.
     */
    function updateCid(string memory _proposalId, string memory _cid) external {
        LibProposalFacet.updateCid(_proposalId, _cid);
    }
}
