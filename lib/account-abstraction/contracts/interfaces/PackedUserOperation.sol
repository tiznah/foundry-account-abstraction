// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * User Operation struct
 * @param sender                - The sender account of this request.
 * @param nonce                 - Unique value the sender uses to verify it is not a replay.
 * @param initCode              - If set, the account contract will be created by this constructor
 * @param callData              - The method call to execute on this account.
 * @param accountGasLimits      - Packed gas limits for validateUserOp and gas limit passed to the callData method call.
 * @param preVerificationGas    - Gas not calculated by the handleOps method, but added to the gas paid.
 *                                Covers batch overhead.
 * @param gasFees               - packed gas fields maxPriorityFeePerGas and maxFeePerGas - Same as EIP-1559 gas parameters.
 * @param paymasterAndData      - If set, this field holds the paymaster address, verification gas limit, postOp gas limit and paymaster-specific extra data
 *                                The paymaster will pay for the transaction instead of the sender.
 * @param signature             - Sender-verified signature over the entire request, the EntryPoint address and the chain ID.
 */
struct PackedUserOperation {
    address sender;         // out account address
    uint256 nonce;          // number only used once
    bytes initCode;         // constructor to create account contract
    bytes callData;         // where we put the txn data
    bytes32 accountGasLimits; // gas limit
    uint256 preVerificationGas; // covers batch overhead
    bytes32 gasFees;        // EIP-1559 gas parameters
    bytes paymasterAndData;  // if set, this field holds the paymaster address, verification gas limit, postOp gas limit and paymaster-specific extra data
    bytes signature;        // signature of the account address
}
