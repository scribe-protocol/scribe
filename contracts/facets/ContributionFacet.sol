// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibContributionFacet} from "../libs/LibContributionFacet.sol";
import {ContributionDefs} from "../storage/defs/ContributionDefs.sol";

/**
 * @title Contribution Facet
 * @dev This contract allows users to create contributions towards a proposal.
 * Each contribution comes with an associated ecoAmount, this eco is added to the contribution pool to be rewarded to contributors at completion of the proposal.
 */
contract ContributionFacet {
    /**
     * @dev Create a new contribution for a given proposal
     * @param _proposalId The ID of the proposal to which this contribution belongs
     * @param _cid The content identifier (CID) for the contribution content (stored off-chain)
     * @param _ecoAmount Amount of eco tokens to submit with this contribution
     */
    function createContribution(
        string memory _proposalId,
        string memory _cid,
        uint256 _ecoAmount
    ) external {
        LibContributionFacet.createContribution(_proposalId, _cid, _ecoAmount);
    }

    /**
     * @dev Retrieve details of a specific contribution for a given book proposal
     * @param _proposalId The ID of the proposal
     * @param _contributionId The ID of the contribution within the proposal
     * @return contribution The details of the specified contribution
     */
    function getContribution(
        string memory _proposalId,
        uint256 _contributionId
    )
        external
        view
        returns (ContributionDefs.Contribution memory contribution)
    {
        contribution = LibContributionFacet.getContribution(
            _proposalId,
            _contributionId
        );
    }

    /**
     * @dev Update the character count of a specific contribution within a proposal.
     * Useful for reward calculation of the proposal after its finalized.
     * @param _proposalId The ID of the proposal containing the contribution.
     * @param _contributionId The ID of the contribution to update.
     * @param _characterCount The new character count to set for the contribution.
     */
    function updateCharacterCount(
        string memory _proposalId,
        uint256 _contributionId,
        uint256 _characterCount
    ) external {
        LibContributionFacet.updateCharacterCount(
            _proposalId,
            _contributionId,
            _characterCount
        );
    }
}
