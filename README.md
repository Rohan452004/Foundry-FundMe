# Foundry FundMe

This project is a simple smart contract built with Solidity, deployed using Foundry, that allows users to donate ETH to a fund and withdraw the funds later. It also implements a minimum donation amount in USD, which is dynamically calculated using Chainlink's price feeds for ETH/USD conversion.

## Features

- **Funding**: Users can send ETH to the contract as donations.
- **Minimum Donation**: A minimum donation threshold is enforced (set to $5 USD worth of ETH).
- **Fund Withdrawal**: The contract owner can withdraw the total balance of the funds.
- **Price Conversion**: The donation amount is converted from ETH to USD using Chainlink’s price feeds to ensure the minimum donation is met.

- ## Installation & Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Rohan452004/Foundry-FundMe.git
   cd Foundry-FundMe
