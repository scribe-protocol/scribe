// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../storage/LibDiamondStorageProposals.sol";

library LibProposalFacet {
    /**
     * @dev Fetch the number of contributors for a given proposal
     * @param _proposalId The ID of the proposal in question
     * @return The number of contributors for the proposal
     */
    function getContributorCount(
        string memory _proposalId
    ) internal view returns (uint256) {
        LibDiamondStorageProposals.DiamondStorageProposals
            storage ds = LibDiamondStorageProposals.diamondStorageProposals();
        return ds.contributorList[_proposalId].length;
    }
}
