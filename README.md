# Dead Man's Switch - ETH Tech Tree

You can install this challenge using the following command:
```bash
    npx create-eth@1.0.2 -e BuidlGuidl/eth-tech-tree-challenges:dead-mans-switch-extension dead-mans-switch
```

You are an operative of a group known as **_The Decentralized Resistance_**. On a recent mission several operatives went missing after an assault by the **_Authoritarian Regime_**. Part of their mission involved obtaining a wallet address for an intelligence provider in your network for the purpose of paying them for information. The missing operatives had access to wallets with funds intended to complete this payment but in the wake of them being missing, so are the funds. Your role inside the organization is to ensure that in the event of capture or death during a mission, the organization can reclaim any funds that were held by the operative to help continue to fund your just cause.

## Challenge Description

In this challenge, you will create a smart contract that implements a "Dead Man's Switch". This contract allows users to deposit funds (ETH or other tokens) and set a time interval for regular "check-ins". If the user fails to check in within the specified time frame, designated beneficiaries can withdraw the funds. 

You can find your assignment in `packages/foundry/contracts/DeadMansSwitch.sol`.

### Instructions
Create a contract called `DeadMansSwitch`. 

Add the following write functions:

- `setCheckInInterval(uint interval)` -- Each account should be able to set their own check in interval. If they miss the interval, then any of their added beneficiaries can withdraw the funds. 
- `checkIn()` -- This function should reset the clock on when the account's funds are able to be withdrawn by a beneficiary. It should be called any time an account interacts with any of these write functions. It should also be able to be called by the EOA (it should be public, not internal). Emit a `CheckIn(address account, uint timestamp)` event.
- `addBeneficiary(address beneficiary)` -- This function should add the given address to the caller's list of beneficiaries. Emit a `BeneficiaryAdded(address user, address beneficiary)` event.
- `removeBeneficiary(address beneficiary)` -- This function should remove a beneficiary from the caller's list of beneficiaries. Emit a `BeneficiaryRemoved(address user, address beneficiary)` event.
- `deposit()` -- Should add any value with which it is called to the callers balance. Emit a `Deposit(address depositor, uint amount)` event.
- `withdraw(address account, uint amount)` -- Should enable an account to withdraw from its own balance in the contract. Should also allow a beneficiary to withdraw from a delegated account if the time since the accounts last check in is greater than the check in interval set up by the account. Emit a `Withdrawal(address beneficiary, uint amount)` event.

And the following view functions:

- `balanceOf(address account)` -- Return the accounts balance held in the contract.
- `lastCheckIn(address account)` -- Return the last check in time for the given account.
- `checkInInterval(address account)` -- Return the accounts check in interval.

Make sure your contract can handle direct calls with value even when they don't specify the `deposit` function.

## Testing Your Progress
Use your skills to build out the above requirements in whatever way you choose. You are encouraged to run tests periodically to visualize your progress.

Run tests using `yarn foundry:test` to run a set of tests against the contract code. Initially you will see build errors but as you complete the requirements you will start to pass tests. If you struggle to understand why some tests are returning errors then you might find it useful to run the command with the extra logging verbosity flag `-vvvv` (`yarn foundry:test -vvvv`) as this will show you very detailed information about where tests are failing. Learn how to read the traces [here](https://book.getfoundry.sh/forge/traces). You can also use the `--match-test "TestName"` flag to only run a single test. Of course you can chain both to include a higher verbosity and only run a specific test by including both flags `yarn foundry:test -vvvv --match-test "TestName"`. You will also see we have included an import of `console2.sol` which allows you to use `console.log()` type functionality inside your contracts to know what a value is at a specific time of execution. You can read more about how to use that at [FoundryBook](https://book.getfoundry.sh/reference/forge-std/console-log).

For a more "hands on" approach you can try testing your contract with the provided front end interface by running the following:
```bash
  yarn chain
```
in a second terminal deploy your contract:
```bash
  yarn deploy
```
in a third terminal start the NextJS front end:
```bash
  yarn start
```

## Solved! (Final Steps)
Once you have a working solution and all the tests are passing your next move is to deploy your lovely contract to the Sepolia testnet.

### Setting up your wallet (if you haven't already)
First you will need to generate an account. **You can skip this step if you have already created a keystore on your machine. Keystores are located in `~/.foundry/keystores`**
```bash
  yarn generate
```
You can optionally give your new account a name by passing it in like so: `yarn generate NAME-FOR-ACCOUNT`. The default is `scaffold-eth-custom`.

You will be prompted for a password to encrypt your newly created keystore. Make sure you choose a [good one](https://xkcd.com/936/) if you intend to use your new account for more than testnet funds.

Now you need to update `packages/foundry/.env` so that `ETH_KEYSTORE_ACCOUNT` = your new account name ("scaffold-eth-custom" if you didn't specify otherwise).

Now you are ready to send some testnet funds to your new account.
Run the following to view your new address and balances across several networks.
```bash
  yarn account
```
To fund your account with Sepolia ETH simply search for "Sepolia testnet faucet" on Google or ask around in onchain developer groups who are usually more than willing to share. Send the funds to your wallet address and run `yarn account` again to verify the funds show in your Sepolia balance.

### Deploying your contract
Once you have confirmed your balance on Sepolia you can run this command to deploy your contract.
```bash
  yarn deploy --network sepolia
```
Now you need to verify it on Sepolia Etherscan.
```bash
  yarn verify --network sepolia
```
Copy your deployed contract address from your console and paste it in at [sepolia.etherscan.io](https://sepolia.etherscan.io). You should see a green checkmark on the "Contract" tab showing that the source code has been verified.

Now you can return to the ETH Tech Tree CLI, navigate to this challenge in the tree and submit your deployed contract address. Congratulations!
