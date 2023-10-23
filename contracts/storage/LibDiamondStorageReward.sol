// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library LibDiamondStorageReward {
    struct DiamondStorageReward {
        mapping(string => mapping(address => uint256)) pendingRewards; // proposalId => contributor => pendingReward
        mapping(string => mapping(address => bool)) hasBeenSentReward; // proposalId => contributor => hasBeenSentReward
        mapping(string => uint256) totalCharactersForProposal; // proposalId => totalCharactersForProposal
        mapping(string => mapping(address => uint256)) contributorCharacterCount; // proposalId => contributor => characterCount
    }

    bytes32 constant DIAMOND_STORAGE_REWARD =
        keccak256("scribe.storage.Reward");

    function diamondStorageReward()
        internal
        pure
        returns (DiamondStorageReward storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_REWARD;
        assembly {
            ds.slot := position
        }
    }
}
