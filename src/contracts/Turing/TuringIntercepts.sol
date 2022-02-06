// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC165} from "solid/utils/ERC165.sol";

import {ITuringIntercepts} from "./ITuringIntercepts.sol";
import {IERC165} from "solid/utils/interfaces/IERC165.sol";

contract TuringIntercepts is ERC165, ITuringIntercepts {
    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        pure
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(ITuringIntercepts).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function GetErrorCode(uint32 rType) internal pure returns (string memory) {
        if (rType == 1) return "TURING: Geth intercept failure";
        if (rType == 10) return "TURING: Incorrect input state";
        if (rType == 11) return "TURING: Calldata too short";
        if (rType == 12) return "TURING: URL >64 bytes";
        if (rType == 13) return "TURING: Server error";
        if (rType == 14) return "TURING: Could not decode server response";
        if (rType == 15) return "TURING: Could not create rpc client";
        if (rType == 16) return "TURING: RNG failure";
        if (rType == 17) return "TURING: API Response >322 chars";
        if (rType == 18) return "TURING: API Response >160 bytes";
        if (rType == 19) return "TURING: Insufficient credit";
        return "";
    }

    function GetResponse(
        uint32 rType,
        string memory _url,
        bytes memory _payload
    ) public override returns (bytes memory) {
        require(
            msg.sender == address(this),
            "Turing:GetResponse:msg.sender != address(this)"
        );
        require(_payload.length > 0, "Turing:GetResponse:no payload");
        require(rType == 2, string(GetErrorCode(rType))); // l2geth can pass values here to provide debug information
        return _payload;
    }

    function GetRandom(uint32 rType, uint256 _random)
        public
        override
        returns (uint256)
    {
        require(
            msg.sender == address(this),
            "Turing:GetResponse:msg.sender != address(this)"
        );
        require(rType == 2, string(GetErrorCode(rType)));
        return _random;
    }

    function Get42(uint32 rType, uint256 _random)
        public
        override
        returns (uint256)
    {
        require(
            msg.sender == address(this),
            "Turing:GetResponse:msg.sender != address(this)"
        );
        require(rType == 2, string(GetErrorCode(rType)));
        return _random;
    }
}
