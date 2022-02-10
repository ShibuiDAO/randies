// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.9;

import {ERC165} from "solid/utils/ERC165.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import {ITuringHelper} from "./Turing/TuringHelper.sol";

import {IGameFactory} from "./IGameFactory.sol";
import {IERC165} from "solid/utils/interfaces/IERC165.sol";

contract GameFactory is ERC165, IGameFactory {
    ITuringHelper public immutable turing;
    GameFactory internal immutable self;

    mapping(address => bool) public games;

    constructor(address _turingHelper) public {
        require(
            ERC165Checker.supportsInterface(
                _turingHelper,
                type(ITuringHelper).interfaceId
            ),
            "REGISTY_ADDRESS_NOT_COMPLIANT"
        );

        turing = ITuringHelper(_turingHelper);
        self = GameFactory(address(this));
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        pure
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IGameFactory).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    modifier onlyGame() {
        require(games[msg.sender], "Invalid Caller Address");
        _;
    }

    function createGame(address payable[] calldata players, uint256 stake)
        public
        payable
        override
        returns (address game)
    {
        return address(0);
    }

    function endGame(address winner) external payable onlyGame {
        delete games[msg.sender];
        emit GameEnded(msg.sender, winner);
    }

    function getRandom() external payable onlyGame returns (uint256) {
        return self.abstractTuringRandom();
    }

    function abstractTuringRandom() public returns (uint256) {
        require(msg.sender == address(this), "SELF_CALL");
        return turing.TuringRandom();
    }
}
