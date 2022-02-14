// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.9;

import {ERC165} from "solid/utils/ERC165.sol";

import {IERC165} from "solid/utils/interfaces/IERC165.sol";
import {IGameFactory} from "./IGameFactory.sol";
import {IGame} from "./IGame.sol";

import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

contract Game is ERC165, IGame {
    uint256 public constant ACTIVE_TIME = 14400;

    address private factory;

    uint256 public startTime;

    address payable[] public players;
    uint256 public stake;

    mapping(address => bool) private activePlayers;
    mapping(address => bool) private enteredPlayers;
    uint256 private remainingPlayers;

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    function initialize(address payable[] calldata _players, uint256 _stake)
        external
        override
    {
        require(factory == address(0), "FORBIDDEN");

        factory = msg.sender;
        startTime = block.timestamp;
        players = _players;
        stake = _stake;

        uint256 playerCount = _players.length;
        for (uint256 i = 0; i < playerCount; i = uncheckedInc(i)) {
            address payable player = _players[i];
            require(
                player != payable(0) && player != payable(factory),
                "PLAYER_INVALID"
            );

            activePlayers[_players[i]] = true;
        }
        remainingPlayers = playerCount;

        players.push(payable(factory));
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IGame).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function run() external payable override onlyActivePlayer {
        require(msg.value >= stake, "MISSING_STAKE");
        SafeTransferLib.safeTransferETH(address(this), stake);

        activePlayers[msg.sender] = false;
        enteredPlayers[msg.sender] = true;
        remainingPlayers -= 1;

        if (remainingPlayers == 0) {
            IGameFactory gameFactory = IGameFactory(factory);

            uint256 randomValue = gameFactory.getRandom();
            uint256 playerCount = players.length;

            uint256 balance = address(this).balance;
            address payable winner = players[randomValue % (playerCount + 1)];
            winner.transfer(balance);

            gameFactory.endGame(winner);
        }
    }

    modifier onlyActivePlayer() {
        require(activePlayers[msg.sender], "PLAYER_NOT_ACTIVE");
        require(startTime + ACTIVE_TIME >= block.timestamp, "NOT_ACTIVE");
        _;
    }

    function uncheckedInc(uint256 i) private pure returns (uint256) {
        unchecked {
            return i + 1;
        }
    }
}
