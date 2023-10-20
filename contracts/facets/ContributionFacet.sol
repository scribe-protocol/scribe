// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibDiamondStorageContributions} from "../storage/LibDiamondStorageContributions.sol";
import {LibDiamondStorageEco} from "../storage/LibDiamondStorageEco.sol";
import {ContributionDefs} from "../storage/defs/ContributionDefs.sol";
import {LibCounter} from "../libs/LibCounter.sol";
import {LibEco} from "../libs/LibEco.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Contribution Facet
 * @dev This contract allows users to create contributions towards a proposal.
 * Each contribution comes with an associated ecoAmount, this eco is added to the contribution pool to be rewarded to contributors at completion of the proposal.
 */
contract ContributionFacet {
    // event to emit when a new contribution is made
    event ContributionCreated(
        string indexed proposalId,
        uint256 indexed contributionId,
        address indexed contributor,
        uint256 ecoAmount,
        string cid
    );

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
        LibDiamondStorageContributions.DiamondStorageContributions
            storage ds = LibDiamondStorageContributions
                .diamondStorageContributions();
        LibDiamondStorageEco.DiamondStorageEco
            storage dsEco = LibDiamondStorageEco.diamondStorageEco();

        require(
            dsEco.token.transferFrom(msg.sender, address(this), _ecoAmount),
            "ContributionFacet.createContribution: Token transfer failed"
        );

        uint256 _contributionId = LibCounter.current(
            ds.proposalContributionCounts[_proposalId]
        );

        ds.contributions[_proposalId][_contributionId] = ContributionDefs
            .Contribution(
                _proposalId,
                _contributionId,
                msg.sender,
                _ecoAmount,
                0,
                _cid
            );

        emit ContributionCreated(
            _proposalId,
            _contributionId,
            msg.sender,
            _ecoAmount,
            _cid
        );

        LibCounter.increment(ds.proposalContributionCounts[_proposalId]);

        ds.proposalEcoAmounts[_proposalId] += _ecoAmount;
    }

    /**
     * @dev Retrieve details of a specific contribution for a given book proposal
     * @param _proposalId The ID of the proposal
     * @param _contributionId The ID of the contribution within the proposal
     * @return The details of the specified contribution
     */
    function getContribution(
        string memory _proposalId,
        uint256 _contributionId
    ) external view returns (ContributionDefs.Contribution memory) {
        LibDiamondStorageContributions.DiamondStorageContributions
            storage ds = LibDiamondStorageContributions
                .diamondStorageContributions();
        return ds.contributions[_proposalId][_contributionId];
    }

    function updateCharacterCount(string memory _proposalId, uint256 _contributionId, uint256 _characterCount) external {
        LibDiamondStorageContributions.DiamondStorageContributions
            storage ds = LibDiamondStorageContributions
                .diamondStorageContributions();
        ds.contributions[_proposalId][_contributionId].characterCount = _characterCount;
    }
}
