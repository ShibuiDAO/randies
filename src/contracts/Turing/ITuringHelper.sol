// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {IERC165} from "solid/utils/interfaces/IERC165.sol";

interface ITuringHelper is IERC165 {
    event OffchainResponse(uint256 indexed version, bytes indexed responseData);
    event OffchainRandom(uint256 indexed version, uint256 indexed random);
    event Offchain42(uint256 indexed version, uint256 indexed random);

    function TuringTx(string memory _url, bytes memory _payload)
        external
        returns (bytes memory);

    function TuringRandom() external returns (uint256);

    function Turing42() external returns (uint256);
}
