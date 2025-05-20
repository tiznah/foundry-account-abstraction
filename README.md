# Minimal Account Abstraction Implementation

⚠️ **WARNING: This is a work in progress and should NOT be used in production** ⚠️

This repository contains a minimal implementation of ERC-4337 Account Abstraction (AA) for educational purposes. Account Abstraction allows users to interact with Ethereum using smart contract accounts rather than externally owned accounts (EOAs), enabling programmable account logic and improved UX.

## Key Components

- `MinimalAccount.sol`: A basic smart contract wallet implementation that supports:
  - Owner-based access control
  - Transaction execution through EntryPoint
  - UserOperation validation
  - Basic signature verification

- `SendPackedOp.s.sol`: Helper script for generating and signing UserOperations

## Features

- ERC-4337 compliant account abstraction
- Basic owner-based access control
- Support for both direct calls and EntryPoint-based execution
- UserOperation validation and signature verification
- Gas payment handling

## Development

This project uses the Foundry framework for development and testing. The test suite demonstrates:
- Owner permissions
- UserOperation validation
- Signature recovery
- EntryPoint integration

## Important Notes

- This is an educational implementation and lacks many security features needed for production use
- No formal security audits have been performed
- Missing important features like:
  - Proper gas estimation
  - Batch transaction support
  - Advanced signature schemes
  - Recovery mechanisms
  - Proper paymaster integration

## License

MIT
