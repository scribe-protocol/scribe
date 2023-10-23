// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {LibDiamond} from "../diamond/libs/LibDiamond.sol";
import {LibStorageRetrieval} from "./LibStorageRetrieval.sol";

library LibEco {
    /**
     * @dev Get the current address of the eco token used for contributions
     * @return The address of the eco token
     */
    function getEcoAddress() internal view returns (IERC20) {
        return LibStorageRetrieval.ecoStorage().token;
    }

    /**
     * @dev Update the address of the eco token used for contributions
     * @param _newEcoAddress The new address for the eco token
     */
    function changeEcoAddress(address _newEcoAddress) internal {
        LibDiamond.enforceIsContractOwner();
        LibStorageRetrieval.ecoStorage().token = IERC20(_newEcoAddress);
    }
}
