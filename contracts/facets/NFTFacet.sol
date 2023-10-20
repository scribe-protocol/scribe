// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {LibNFTFacet} from "../libs/LibNFTFacet.sol";
import {IERC721Metadata} from "../interfaces/IERC721Metadata.sol";

contract NFTFacet is IERC721Metadata {
    function claimNFT(
        string memory proposalId,
        string memory metadataCid
    ) external {
        LibNFTFacet.claimNFT(proposalId, metadataCid);
    }

    function balanceOf(
        address _owner
    ) external view override returns (uint256) {
        return LibNFTFacet.balanceOf(_owner);
    }

    function ownerOf(
        uint256 _tokenId
    ) external view override returns (address) {
        return LibNFTFacet.ownerOf(_tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        LibNFTFacet.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external override {
        LibNFTFacet.safeTransferFrom(from, to, tokenId, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        LibNFTFacet.safeTransferFrom(from, to, tokenId, "");
    }

    function approve(address to, uint256 tokenId) external override {
        LibNFTFacet.approve(to, tokenId);
    }

    function getApproved(
        uint256 tokenId
    ) external view override returns (address) {
        return LibNFTFacet.getApproved(tokenId);
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) external override {
        LibNFTFacet.setApprovalForAll(operator, approved);
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) external view override returns (bool) {
        return LibNFTFacet.isApprovedForAll(owner, operator);
    }

    function name() external view returns (string memory) {
        return LibNFTFacet.name();
    }

    function symbol() external view returns (string memory) {
        return LibNFTFacet.symbol();
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return LibNFTFacet.tokenURI(tokenId);
    }
}
