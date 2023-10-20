// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library LibDiamondStorageEco {
    struct DiamondStorageEco {
        // eco erc20 token to be initialized with address at deployment
        IERC20 token;
    }

    bytes32 constant DIAMOND_STORAGE_ECO =
        keccak256("scribe.storage.Eco");

    function diamondStorageEco() internal pure returns (DiamondStorageEco storage ds) {
        bytes32 position = DIAMOND_STORAGE_ECO;
        assembly {
            ds.slot := position
        }
    }
}
