// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAccount} from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/IAccount.sol";
import {Transaction} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
 // phase 1 validation
 // user sends txn to API client or light node
 // checks if nonce is unique by querying the NonceHolder system contract
 // Systems contracts in ZkSync aredeployed by default and help with common operations
 // zksync API client calls validateTransaction which must update the nonce
 // msg.sender is the bootloader
 // check that the nonce is update
 // calls payForTransaction or prepareForpaymasterr and validateANdPayForPaymasterTransaction
 // phase 2 eecution
 // the zksync API client passes the validated transaction tothe main node/sequencer
 // main node cals the executeTransaction function
 // if a paymaster was used, the postTransaction is called

contract ZkMinimalAccount is IAccount {
    function validateTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
    external
    payable
    returns (bytes4 magic)
    {

    }

function executeTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
    external
    payable
    {

    }

// lets someone else execute a transaction from the 'outside'
function executeTransactionFromOutside(Transaction memory _transaction) external payable;

function payForTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
    external
    payable
    {

    }

function prepareForPaymaster(bytes32 _txHash, bytes32 _possibleSignedHash, Transaction memory _transaction)
    external
    payable
    {

    }
}
    