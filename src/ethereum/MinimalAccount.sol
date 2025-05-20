// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAccount is IAccount, Ownable {
    error MinimalAccount__InvalidSender();
    error MinimalAccount__CallFailed(bytes result);

    IEntryPoint private immutable i_entryPoint;

    // signature is valid if it's the contract owner
    constructor(address entryPoint) Ownable(msg.sender) {
        i_entryPoint = IEntryPoint(entryPoint);
    }

    modifier requireFromEntryPoint() {
        if (msg.sender != address(i_entryPoint)) revert MinimalAccount__InvalidSender();
        _;
    }

    modifier requireFromEntryPointOrOwner() {
        if (msg.sender != address(i_entryPoint) && msg.sender != owner()) revert MinimalAccount__InvalidSender();
        _;
    }

    function execute(address dest, uint256 value, bytes calldata funcData)
        external
        payable
        requireFromEntryPointOrOwner
    {
        (bool success, bytes memory result) = dest.call{value: value}(funcData);
        if (!success) revert MinimalAccount__CallFailed(result);
    }

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        requireFromEntryPoint
        returns (uint256 validationData)
    {
        validationData = _validateSignature(userOp, userOpHash);
        // validate nonce, done by the entrypoint either way but can be a custom implementation
        _payPrefund(missingAccountFunds);
    }

    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature); // who signed this?
        if (signer != owner()) {
            return SIG_VALIDATION_FAILED;
        }
        {
            return SIG_VALIDATION_SUCCESS;
        }
    }

    receive() external payable {}

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds > 0) {
            (bool success,) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}("");
            success;
        }
    }
    /////////////////////////
    //     getters        //
    ////////////////////////

    function getEntryPoint() external view returns (address) {
        return address(i_entryPoint);
    }
}
