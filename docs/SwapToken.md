# SwapToken Smart Contract Documentation

## Introduction
The TokenSwap contract is a fundamental component in decentralized finance, enabling users to exchange one type of token for another. This contract is crucial for liquidity and trading within the ecosystem, facilitating seamless token swaps with predefined exchange rates.


## Design Choices
Token Interfaces: Utilizes the IERC20 interface for standard token interactions.
Reentrancy Protection: Inherits ReentrancyGuard from OpenZeppelin to safeguard against reentrancy attacks.
Two-Token System: Designed for swapping between two specific tokens (tokenA
and tokenB), allowing for controlled and predictable swap operations.

Exchange Rate Control: Implements a fixed exchange rate for conversions, simplifying the swap process and providing transparency.
Swap Direction Flexibility: Supports bidirectional swaps (A to B, and B to A) with an easy-to-use enum SwapDirection.
Event Logging: Uses events to log swap operations, enhancing transparency and traceability in transactions.


## Usage Guide
swapTokens: Allows users to exchange tokens. The user specifies the amount and direction (A to B or B to A). The contract calculates the output amount based on the predefined exchange rate.
Deployment: Requires the addresses of the two tokens (tokenA and tokenB), and the set exchange rate.


### Key functionalities include:
swapTokens: This function allows users to perform token swaps. Users specify the amount and direction of the swap (A to B or B to A). The contract calculates the output amount based on a predefined exchange rate.
handleTransfer: An internal function that manages the transfer of tokens. It checks the balance and allowance of the user and executes the transfer. This function ensures that the user has sufficient tokens and permission for the swap, and it handles both direct transfers and transfers from the user to the contract.


## Security Considerations
Non-Reentrancy: The nonReentrant modifier ensures protection against reentrancy attacks, a common vulnerability in smart contracts involving external calls.
Balance and Allowance Checks: Before executing swaps, the contract verifies the user's balance and allowance to ensure they have sufficient tokens for the swap.
Transfer Validations: The contract includes safeguards against transfer failures, a critical aspect in token transactions.
