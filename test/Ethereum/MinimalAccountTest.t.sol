// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ZkMinimalAccount} from "src/zksync/ZkMinimalAccount.sol";
import {DeployMinimal} from "script/DeployMinimal.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {SendPackedUserOp, PackedUserOperation, IEntryPoint} from "script/SendPackedOp.s.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract MinimalAccountTest is Test {
    using MessageHashUtils for bytes32;

    ZkMinimalAccount public minimalAccount;
    HelperConfig public helperConfig;
    ERC20Mock public usdc;
    SendPackedUserOp sendPackedUserOp;

    address randomUser = makeAddr("random");

    uint256 constant AMOUNT = 1e18;

    function setUp() public {
        DeployMinimal deployer = new DeployMinimal();
        (helperConfig, minimalAccount) = deployer.deployMinimalAccount();
        usdc = new ERC20Mock();
        sendPackedUserOp = new SendPackedUserOp();
    }

    function testOwnerCanExecuteCommands() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT); // function selector
        // Act
        vm.prank(minimalAccount.owner());
        minimalAccount.execute(dest, value, functionData);
        // Assert
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }

    function testNonOwnerCannotExecuteCommands() public {
        // Arrange
        address nonOwner = makeAddr("nonOwner");
        // Act
        vm.prank(nonOwner);
        vm.expectRevert();
        minimalAccount.execute(
            address(usdc), 0, abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT)
        );
        // Assert
        assertEq(
            usdc.balanceOf(address(minimalAccount)), 0, "Account balance should remain unchanged after failed execution"
        );
    }

    function testRecoverSignedOp() public {
        // arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT); // function selector
        bytes memory executeCallData =
            abi.encodeWithSelector(ZkMinimalAccount.execute.selector, dest, value, functionData);
        PackedUserOperation memory packedUserOp = sendPackedUserOp.generatedSignedUserOperation(
            executeCallData, helperConfig.getConfig(), address(minimalAccount)
        );
        bytes32 userOperationHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);
        //act
        address recoveredAddress = ECDSA.recover(userOperationHash.toEthSignedMessageHash(), packedUserOp.signature);
        //assert
        assertEq(recoveredAddress, minimalAccount.owner());
    }

    function testValidationOfUserOps() public {
        // arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT); // function selector
        bytes memory executeCallData =
            abi.encodeWithSelector(ZkMinimalAccount.execute.selector, dest, value, functionData);
        PackedUserOperation memory packedUserOp = sendPackedUserOp.generatedSignedUserOperation(
            executeCallData, helperConfig.getConfig(), address(minimalAccount)
        );
        bytes32 userOperationHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);
        uint256 missingAccountFunds = 1e18;
        // act
        vm.prank(helperConfig.getConfig().entryPoint);
        uint256 validationData = minimalAccount.validateUserOp(packedUserOp, userOperationHash, missingAccountFunds);
        assertEq(validationData, 0);
    }

    function testEntryPointCanExecuteCommands() public {
        // arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        bytes memory executeCallData =
            abi.encodeWithSelector(ZkMinimalAccount.execute.selector, dest, value, functionData);

        // Fund both the account and entry point
        vm.deal(address(minimalAccount), 1e18);
        vm.deal(helperConfig.getConfig().entryPoint, 1e18);

        // Create and sign the user operation
        PackedUserOperation memory packedUserOp = sendPackedUserOp.generatedSignedUserOperation(
            executeCallData, helperConfig.getConfig(), address(minimalAccount)
        );

        // Set up the operation array
        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = packedUserOp;

        // Execute the operation
        vm.prank(randomUser);
        IEntryPoint(helperConfig.getConfig().entryPoint).handleOps(ops, payable(randomUser));

        // Assert
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }
}
