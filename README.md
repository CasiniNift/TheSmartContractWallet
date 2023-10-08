# The Smart Contract Wallet

## Description
A secure and efficient smart contract wallet with features like multi-signature approval for ownership transfer, allowances for authorized spenders, and unlimited fund reception.

## Features
- **Single Owner Wallet:** Initially controlled by a single owner.
- **Receive Funds:** Capable of receiving unlimited funds.
- **Multi-Signature Approval:** Allows change of ownership with the approval of 3 out of 5 guardians.
- **Allowances:** Owner can set allowances for other addresses to spend a limited amount of funds.

## Setup and Installation
1. Install [Truffle](https://www.trufflesuite.com/): `npm install -g truffle`
2. Clone the repository: `git clone <REPO_URL>`
3. Change to the repo directory: `cd <REPO_DIRECTORY>`
4. Install dependencies: `npm install`
5. Compile the contract: `truffle compile`

## Usage
Interact with the contract using Truffle console or deploy it to a testnet or mainnet using Truffle's deployment tools. 

Functionality:
- `proposeNewOwner(address _newOwner)` - Propose a new owner (Only guardians can call this function).
- `approveNewOwner()` - Approve the proposed new owner. Ownership changes if 3 out of 5 guardians approve.
- `addAllowance(address _who, uint256 _amount)` - Set an allowance for a specific address (Only owner can call this function).
- `withdrawMoney(address payable _to, uint256 _amount)` - Withdraw funds if you're the owner or an address with sufficient allowance.

## Security
The contract uses OpenZeppelin's Ownable contract for secure ownership management and SafeMath library to prevent integer overflow and underflow attacks.

## Testing
Test cases can be added in the `test/` directory and executed using the `truffle test` command.

## Contributing
Open for contributions. Please ensure to test thoroughly before creating a pull request.
