// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {IERC165} from "solid/utils/interfaces/IERC165.sol";

interface ITuringIntercepts is IERC165 {
    function GetResponse(
        uint32 rType,
        string memory _url,
        bytes memory _payload
    ) external returns (bytes memory);

    function GetRandom(uint32 rType, uint256 _random)
        external
        returns (uint256);

    function Get42(uint32 rType, uint256 _random) external returns (uint256);
}
