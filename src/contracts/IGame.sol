// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.9;

import {IERC165} from "solid/utils/interfaces/IERC165.sol";

interface IGame is IERC165 {
    function initialize(address payable[] calldata _players, uint256 _stake)
        external;

    function run() external payable;
}
