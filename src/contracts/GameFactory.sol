// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.9;

import {ERC165} from "solid/utils/ERC165.sol";

import {IERC165} from "solid/utils/interfaces/IERC165.sol";
import {ITuringHelper} from "./Turing/TuringHelper.sol";
import {IGameFactory} from "./IGameFactory.sol";
import {IGame} from "./IGame.sol";

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

contract GameFactory is ERC165, IGameFactory {
    ITuringHelper private immutable turing;
    GameFactory private immutable self;
    address private immutable gameImplementation;

    mapping(address => bool) public games;

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    constructor(address _turingHelper, address _gameImplementation) {
        require(
            ERC165Checker.supportsInterface(
                _turingHelper,
                type(ITuringHelper).interfaceId
            ),
            "HELPER_ADDRESS_NOT_COMPLIANT"
        );

        turing = ITuringHelper(_turingHelper);
        self = GameFactory(payable(address(this)));
        gameImplementation = _gameImplementation;
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IGameFactory).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    modifier onlyGame() {
        require(games[msg.sender], "NOT_GAME");
        _;
    }

    function createGameAndRun(
        address payable[] calldata players,
        uint256 stake
    ) public payable override returns (address game) {
        require(msg.value >= stake, "MISSING_STAKE");

        game = createGame(players, stake);
        IGame(game).run();

        return game;
    }

    function createGame(address payable[] calldata players, uint256 stake)
        public
        payable
        override
        returns (address game)
    {
        game = Clones.clone(gameImplementation);

        IGame(game).initialize(players, stake);
        games[game] = true;

        return game;
    }

    function endGame(address winner) external payable onlyGame {
        emit GameEnded(msg.sender, winner);
        delete games[msg.sender];
    }

    function getRandom() external payable onlyGame returns (uint256) {
        return self.abstractTuringRandom();
    }

    function abstractTuringRandom() public returns (uint256) {
        require(msg.sender == address(this), "FOREIGN_CALL");
        return turing.TuringRandom();
    }
}
