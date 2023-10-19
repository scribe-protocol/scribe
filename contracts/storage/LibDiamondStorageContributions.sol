// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ContributionDefs} from "./defs/ContributionDefs.sol";
import {LibCounter} from "../libs/LibCounter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library LibDiamondStorageContributions {
    struct DiamondStorageContributions {
        // eco erc20 token to be initialized with address at deployment
        IERC20 token;
        // address of the owner of the contract
        address owner;
        mapping(string => mapping(uint256 => ContributionDefs.Contribution)) contributions; // bookId => contributionId => Contribution
        mapping(string => LibCounter.Counter) proposalContributionCounts; // proposalId => contributionCount
        mapping(string => uint256) proposalEcoAmounts; // proposalId => accumulatedEco
    }

    bytes32 constant DIAMOND_STORAGE_CONTRIBUTIONS =
        keccak256("scribe.storage.Contributions");

    function diamondStorageContributions()
        internal
        pure
        returns (DiamondStorageContributions storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_CONTRIBUTIONS;
        assembly {
            ds.slot := position
        }
    }
}
