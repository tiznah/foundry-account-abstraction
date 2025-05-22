// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ZkMinimalAccount} from "src/zksync/ZkMinimalAccount.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {Transaction, MemoryTransactionHelper} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {BOOTLOADER_FORMAL_ADDRESS} from "lib/foundry-era-contracts/src/system-contracts/contracts/Constants.sol";
import {ACCOUNT_VALIDATION_SUCCESS_MAGIC} from "lib/foundry-era-contracts/src/system-contracts/interfaces/IAccount.sol";


contract ZkMinimalAccountTest is Test{
    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    using MessageHashUtils for bytes32;
    ZkMinimalAccount  minimalAccount;
    ERC20Mock public usdc;  
    uint256 constant INITIAL_BALANCE = 100 ether;
    bytes32 constant EMPTY_BYTES32 = bytes32(0);
    address public constant AMOUNT = 1 ether;
    function setUp() public {
        minimalAccount = new ZkMinimalAccount();
        minimalAccount.transferOwnership(ANVIL_DEFAULT_ACCOUNT);
        usdc = new ERC20Mock();
        vm.deal(address(minimalAccount), INITIAL_BALANCE);
    }
    function testZkOwnerCanExecuteCommands() public {
        // arrange
        address dest = address(usdc); // set a mockerc20 usdc as the destination
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        Transaction memory txn = _createUnsignedTransaction(minimalAccount.owner(), 113, dest, value, functionData);
        // act
        vm.prank(minimalAccount.owner());
        minimalAccount.executeTransaction(EMPTY_BYTES32,EMPTY_BYTES32,txn);
        // assert
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }
    function testZkValidateTransaction() public {
        //arrange   
        address dest = address(usdc); // set a mockerc20 usdc as the destination
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        Transaction memory txn = _createUnsignedTransaction(minimalAccount.owner(), 113, dest, value, functionData);
        transaction = _signTransaction(transaction);
        // act 
        vm.prank(BOOTLOADER_FORMAL_ADDRESS);
        bytes4 magic = minimalAccount.validateTransaction(EMPTY_BYTES32, EMPTY_BYTES32, txn);
        // assert
        assertEq(magic, ACCOUNT_VALIDATION_SUCCESS_MAGIC);
    }
    // helpers
    function _signTransaction( Transaction memory txn) internal view returns (Transaction memory) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 ANVIL_DEFAULT_ACCOUNT = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        bytes32 unisgnedTransactionHash = MemoryTransactionHelper.encodeHash(txn);
        ( v,  r,  s) = vm.sign(ANVIL_DEFAULT_ACCOUNT, unisgnedTransactionHash);
        Transaction memory signedTransaction = txn;
        signedTransaction.signature = abi.encodePacked(r, s, v);
        return signedTransaction;
  
    }

    function _createUnsignedTransaction(address from, uint8 txnType, address to, uint256 value, bytes memory data)
     internal view returns (Transaction memory) {
        uint256 nonce = vm.getNonce(address(minimalAccount));
        bytes32[] memory factoryDeps = new bytes32[](0);
        return Transaction({
 
            txType: txnType, //113 for account abstraction type
            from: uint256(uint160(from)),
            to: uint256(uint160(to)),
            gasLimit: 16777216, // 16mb
            gasPerPubDataByteLimit: 16777216, // ammount of gas willing to pay per byte of pubdata
            maxFeePerGas: 16777216,
            maxPriorityFeePerGas: 16777216,
            paymaster: 0,
            nonce: nonce,
            value: value,
            reserved: [uint256(0),uint256(0),uint256(0),uint256(0)],
            data: data,
            signature: hex"",
            factoryDeps: factoryDeps,
            paymasterInput: hex"",
            reservedDynamic: hex""
  
        })
     }
}   