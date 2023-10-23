//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {LibDiamondStorageReward} from "../storage/LibDiamondStorageReward.sol";
import {LibDiamondStorageProposals} from "../storage/LibDiamondStorageProposals.sol";
import {LibDiamondStorageContributions} from "../storage/LibDiamondStorageContributions.sol";
import {LibDiamondStorageEco} from "../storage/LibDiamondStorageEco.sol";
import {LibDiamondStorageVoting} from "../storage/LibDiamondStorageVoting.sol";
import {LibDiamondStorageNFT} from "../storage/LibDiamondStorageNFT.sol";
import {LibDiamond} from "../diamond/libs/LibDiamond.sol";

library LibStorageRetrieval {
    /**
     * @dev Retrieves the contribution storage instance.
     * @return An instance of the DiamondStorageContributions.
     */
    function contributionStorage()
        internal
        pure
        returns (
            LibDiamondStorageContributions.DiamondStorageContributions storage
        )
    {
        return LibDiamondStorageContributions.diamondStorageContributions();
    }

    /**
     * @dev Retrieves the reward storage instance.
     * @return An instance of the DiamondStorageReward.
     */
    function rewardStorage()
        internal
        pure
        returns (LibDiamondStorageReward.DiamondStorageReward storage)
    {
        return LibDiamondStorageReward.diamondStorageReward();
    }

    /**
     * @dev Retrieves the proposal storage instance.
     * @return An instance of the DiamondStorageProposals.
     */
    function proposalStorage()
        internal
        pure
        returns (LibDiamondStorageProposals.DiamondStorageProposals storage)
    {
        return LibDiamondStorageProposals.diamondStorageProposals();
    }

    /**
     * @dev Retrieves the eco storage instance.
     * @return An instance of the DiamondStorageEco.
     */
    function ecoStorage()
        internal
        pure
        returns (LibDiamondStorageEco.DiamondStorageEco storage)
    {
        return LibDiamondStorageEco.diamondStorageEco();
    }

    /**
     * @dev Retrieves the voting storage instance.
     * @return An instance of the DiamondStorageVoting.
     */
    function votingStorage()
        internal
        pure
        returns (LibDiamondStorageVoting.DiamondStorageVoting storage)
    {
        return LibDiamondStorageVoting.diamondStorageVoting();
    }

    /**
     * @dev Retrieves the nft storage instance.
     * @return An instance of the DiamondStorageNFT.
     */
    function nftStorage()
        internal
        pure
        returns (LibDiamondStorageNFT.DiamondStorageNFT storage)
    {
        return LibDiamondStorageNFT.diamondStorageNFT();
    }

    /**
     * @dev Retrieves the diamond storage instance.
     * @return An instance of the DiamondStorage.
     */
    function diamondStorage()
        internal
        pure
        returns (LibDiamond.DiamondStorage storage)
    {
        return LibDiamond.diamondStorage();
    }
}
