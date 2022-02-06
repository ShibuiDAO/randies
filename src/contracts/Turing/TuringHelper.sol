// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC165} from "solid/utils/ERC165.sol";
import {TuringIntercepts} from "./TuringIntercepts.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {ITuringHelper} from "./ITuringHelper.sol";
import {IERC165} from "solid/utils/interfaces/IERC165.sol";

contract TuringHelper is ERC165, TuringIntercepts, Ownable, ITuringHelper {
    TuringHelper immutable self;

    mapping(address => bool) public permittedCaller;

    event AddPermittedCaller(address indexed _callerAddress);
    event RemovePermittedCaller(address indexed _callerAddress);

    constructor() public {
        self = TuringHelper(address(this));
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        pure
        virtual
        override(ERC165, IERC165, TuringIntercepts)
        returns (bool)
    {
        return
            interfaceId == type(ITuringHelper).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    modifier onlyPermittedCaller() {
        require(permittedCaller[msg.sender], "Invalid Caller Address");
        _;
    }

    function addPermittedCaller(address _callerAddress) public onlyOwner {
        permittedCaller[_callerAddress] = true;
        emit AddPermittedCaller(_callerAddress);
    }

    function removePermittedCaller(address _callerAddress) public onlyOwner {
        permittedCaller[_callerAddress] = false;
        emit RemovePermittedCaller(_callerAddress);
    }

    function checkPermittedCaller(address _callerAddress)
        public
        view
        returns (bool)
    {
        bool permitted = permittedCaller[_callerAddress];
        return permitted;
    }

    function TuringTx(string memory _url, bytes memory _payload)
        public
        override
        onlyPermittedCaller
        returns (bytes memory)
    {
        require(_payload.length > 0, "Turing:TuringTx:no payload");

        bytes memory response = self.GetResponse(1, _url, _payload);
        emit OffchainResponse(0x01, response);
        return response;
    }

    function TuringRandom() public onlyPermittedCaller returns (uint256) {
        uint256 response = self.GetRandom(1, 0);
        emit OffchainRandom(0x01, response);
        return response;
    }

    function Turing42() public onlyPermittedCaller returns (uint256) {
        uint256 response = self.Get42(2, 42);
        emit Offchain42(0x01, response);
        return response;
    }
}
