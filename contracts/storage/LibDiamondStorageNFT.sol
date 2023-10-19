// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {LibCounter} from "../libs/LibCounter.sol";

library LibDiamondStorageNFT {
    struct DiamondStorageNFT {
        mapping(address => uint256) balances;
        mapping(uint256 => address) owners;
        mapping(uint256 => address) tokenApprovals;
        mapping(address => mapping(address => bool)) operatorApprovals;
        mapping(uint256 => string) tokenURIs;
        mapping(string => mapping(address => bool)) hasClaimed; // Maps proposalId -> address -> hasClaimed status
        LibCounter.Counter tokenIdCounter;
        string name;
        string symbol;
    }

    bytes32 constant DIAMOND_STORAGE_NFT = keccak256("scribe.storage.NFT");

    function diamondStorageNFT()
        internal
        pure
        returns (DiamondStorageNFT storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_NFT;
        assembly {
            ds.slot := position
        }
    }
}
