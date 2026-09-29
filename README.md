# NFT Marketplace

A decentralized NFT marketplace built with Solidity and Foundry.

The marketplace allows users to list their NFTs for a fixed price, purchase listed NFTs using a custom ERC-20 payment token, and cancel their own listings.

## Features

- Mint NFTs using an ERC-721 contract
- List NFTs for a fixed price
- Buy listed NFTs using an ERC-20 payment token
- Cancel NFT listings
- Marketplace fee system
- Owner-controlled marketplace fee
- Custom errors for failed transactions
- Events for listings, sales, cancellations, and fee updates
- Comprehensive Foundry tests
- Deployed and verified on Ethereum Sepolia

## Tech Stack

- Solidity
- Foundry
- OpenZeppelin Contracts
- ERC-721
- ERC-20
- Ethereum Sepolia

## Smart Contracts

### MyNFT

An ERC-721 NFT contract that allows users to mint NFTs.

Token name: My NFT

Token symbol: MNFT

### PaymentToken

An ERC-20 token used as the payment currency for NFT purchases on the marketplace.

### Marketplace

The main marketplace contract.

It handles:

- NFT listings
- NFT purchases
- Listing cancellations
- Marketplace fees
- Marketplace events

The default marketplace fee is 2%.

The owner can change the fee, with a maximum fee of 10%.

## How It Works

### 1. Mint an NFT

A user calls the `mint()` function in the MyNFT contract.

The NFT is assigned to the user's wallet.

### 2. List the NFT

The NFT owner approves the Marketplace contract to transfer the NFT.

The owner then calls `listNFT()` with:

- NFT contract address
- Token ID
- Sale price

The NFT is transferred into the Marketplace contract while it is listed.

### 3. Buy the NFT

A buyer approves the Marketplace contract to spend the required amount of PaymentToken.

The buyer calls `buyNFT()`.

The payment is split between:

- Marketplace owner — marketplace fee
- NFT seller — remaining sale amount

The NFT is then transferred to the buyer.

### 4. Cancel the Listing

The seller can call `cancelListing()` to remove their NFT from the marketplace.

The NFT is transferred back to the seller.

## Testing

The project uses Foundry for automated testing.

Current test results:

- 16 tests passed
- 0 tests failed

Coverage:

- Lines: 97.62%
- Statements: 97.30%
- Branches: 85.71%
- Functions: 100%

Run the tests with:

```bash
forge test