# Reach Builder Challenge Week 3 - Level 3

This project was created based on the Reach Builder Week 3 Challenge.
The specifications of the challenge are:

- Write a program that stores a whitelisted wallet Address. 
- Address must be stored in Map or Set 
- Hardcode this address, or set it to the known Bob address
- Read about Untrustworthy Maps
- Display status messages to the console
- Deploying / attaching notifications
- Display whitelisted wallet address
- Incorporate a non-network token.
- Use launchToken to create a new token
- Distribute your tokens to the whitelisted wallet address
- Display status messages to the console
- Was the wallet address approved?
- Display token properties (name, unit, quantity)
- Did your tokens successfully deliver?
- This should be done in 2 files, index.rsh and index.mjs

The implementation in this example program allows the deployer to specify a number of addresses
that may submit their wallets for whitelisting,
and the number of non-network tokens that are claimable per address.

The application should be run in at least two terminal windows.
Use `./reach run` to execute the program in the first terminal window
and follow the prompts to deploy the contract.
Then copy the contract string and execute the the same command in a second terminal window
to act as an Attacher to the contract by pasting the contract string.
The program will request to whitelist an address and claim the non-network tokens.

The configuration options available to the Deployer are as follows:
1. The number of addresses that may be permitted to be whitelisted in the contract
2. The number of tokens each whitelisted address may claim from the contract

In this sample program, the token will be automatically generated,
however the deployment process may be adjusted to utilize
an existing token in the Deployer's account.