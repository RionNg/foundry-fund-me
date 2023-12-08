# FundMe Smart Contract

## Overview
Welcome to the FundMe smart contract! This Ethereum-based smart contract allows users to contribute funds in Ether (ETH) to a fundraising campaign. The contract ensures that contributors meet a minimum funding requirement in USD before accepting their contribution. The USD value is determined through an external Chainlink price feed.

## Features
1. **Minimum Funding Requirement**: Contributors must meet a minimum funding requirement in USD (5 ETH by default) to participate in the campaign.
2. **Chainlink Integration**: The contract integrates with Chainlink's price feed (AggregatorV3Interface) to obtain real-time USD conversion rates for Ether.
3. **Owner Management**: The contract includes a secure ownership mechanism, allowing only the owner to execute certain privileged functions.
4. **Withdrawal Mechanism**: The owner can initiate a withdrawal of the funds contributed, redistributing the Ether to the original funders.
5. **Fallback and Receive Functions**: The contract supports the fallback and receive functions to handle incoming Ether transactions.

## Getting Started
To deploy the FundMe smart contract, follow these steps:
1. Deploy the contract to the Ethereum blockchain.
2. Pass the address of a Chainlink price feed as a parameter during deployment.
3. Set the minimum funding requirement as needed.
   
## Smart Contract Functions
#### `fund()`
- Allows users to contribute funds to the campaign.
- Requires the contributed amount to meet the specified minimum funding requirement in USD.

#### `getVersion()`
- Returns the version of the Chainlink price feed.

#### `onlyOwner`
- A modifier ensuring that only the owner can execute certain functions.

#### `cheaperWithdraw()`
- Initiates a withdrawal of all contributed funds, redistributing Ether to the original funders.

#### `withdraw()`
- Initiates a withdrawal of all contributed funds, redistributing Ether to the original funders.

#### `fallback()`
- Fallback function to handle incoming Ether transactions and automatically call the **fund()** function.

#### `receive()`
- Receive function to handle incoming Ether transactions and automatically call the **fund()** function.

#### `getAddressToAmountFunded(address fundingAddress)`
- Returns the amount of Ether funded by a specific address.

#### `getFunder(uint256 index)`
- Returns the address of a funder at the specified index in the funders array.

#### `getOwner()`
- Returns the address of the contract owner.

## Note
Make sure to properly test and verify the contract on a testnet before deploying it on the Ethereum mainnet. Also, consider customizing the contract according to your specific requirements.

## License
This smart contract is licensed under the MIT License.

## Disclaimer
Use this smart contract at your own risk!