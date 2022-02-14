// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.9;

import {IERC165} from "solid/utils/interfaces/IERC165.sol";

interface IGameFactory is IERC165 {
    event GameStarted(address indexed game);
    event GameEnded(address indexed game, address indexed winner);

    function createGameAndRun(
        address payable[] calldata players,
        uint256 stake
    ) external payable returns (address game);

    function createGame(address payable[] calldata players, uint256 stake)
        external
        payable
        returns (address game);

    function endGame(address winner) external payable;

    function getRandom() external payable returns (uint256);
}
