# Minimal Account Abstraction Implementation for zkSync Era

⚠️ **WARNING: This is a work in progress and should NOT be used in production** ⚠️

This repository contains a minimal implementation of ERC-4337 Account Abstraction (AA) specifically for zkSync Era. It demonstrates how to create and use smart contract accounts (instead of EOAs) on zkSync Era, enabling programmable account logic and improved UX while leveraging zkSync's L2 scaling benefits.

## Key Components

- `ZkMinimalAccount.sol`: A basic smart contract wallet implementation for zkSync Era that supports:
  - Owner-based access control
  - Transaction execution through EntryPoint
  - UserOperation validation
  - Basic signature verification
  - zkSync-specific account requirements

- `SendPackedOp.s.sol`: Helper script for generating and signing UserOperations
- `HelperConfig.s.sol`: Configuration management for different networks
- `DeployMinimal.s.sol`: Deployment script for the account implementation

## Features

- ERC-4337 compliant account abstraction adapted for zkSync Era
- Basic owner-based access control
- Support for both direct calls and EntryPoint-based execution
- UserOperation validation and signature verification
- Gas payment handling on zkSync Era
- L2-optimized implementation

## Development

This project uses the Foundry framework for development and testing. The test suite demonstrates:
- Owner permissions and access control
- UserOperation validation and processing
- Signature recovery and verification
- EntryPoint integration on zkSync
- Token handling (ERC20)

## Important Notes

- This is an educational implementation and lacks many security features needed for production use
- No formal security audits have been performed
- Missing important features like:
  - Proper gas estimation for L2
  - Batch transaction support
  - Advanced signature schemes
  - Recovery mechanisms
  - Proper paymaster integration
  - Multi-signature support
  - Guardian logic

## Testing

The test suite includes comprehensive tests for:
- Basic account operations
- Owner permissions
- UserOperation handling
- Token interactions
- EntryPoint integration

## License

MIT
