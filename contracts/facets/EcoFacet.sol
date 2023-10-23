// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibEco} from "../libs/LibEco.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Eco Facet Contract
 * @notice Manages the address of the eco token used for contributions within the system.
 * The eco token is an ERC20 token, and its address can be updated through this contract.
 * The contract primarily delegates logic to the `LibEco` library.
 *
 */
contract EcoFacet {
    /**
     * @dev Get the current address of the eco token used for contributions
     * @return The address of the eco token
     */
    function getEcoAddress() external view returns (IERC20) {
        return LibEco.getEcoAddress();
    }

    /**
     * @dev Update the address of the eco token used for contributions
     * @param _newEcoAddress The new address for the eco token
     */
    function changeEcoAddress(address _newEcoAddress) external {
        LibEco.changeEcoAddress(_newEcoAddress);
    }
}
