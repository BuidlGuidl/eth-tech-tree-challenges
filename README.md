# Social Recovery Wallet Challenge - ETH Tech Tree

You can install this challenge using the following command:
```bash
    npx create-eth@1.0.3 -e BuidlGuidl/eth-tech-tree-challenges:social-recovery-extension social-recovery
```

Mother's day is coming up and you decide to send your mom some ETH to help her learn more about your world. You set up a new MetaMask wallet and write down the seed phrase on a nice piece of flowered stationery. You briefly consider taking custody of the phrase on her behalf, but ultimately decide against it. To understand your cypherpunk values, she needs to truly own her new gift. She's ecstatic. She immediately hops online, and for the next few days, continues to explore the rich new world that is web3. Then...disaster strikes. Her laptop dies and she's LOST HER SEED PHRASE.
## Challenge Description

A year has passed, and after the horrific debacle of last year's Mother's day, you've vowed to come up with a more user-friendly wallet design. You need it to be able to withstand the loss of a seed phrase, while retaining as much autonomy as possible.

But how?? You hearken back to your own upbringing for inspiration. Sure, your mom was a central figure, but ultimately, you realize, **it took a village**. You decide to develop your new wallet with this same strategy. What if you could select a group of trustworthy `guardian` addresses that could come together to recover the wallet after the seed phrase was lost.

With that idea, you begin work on your project in `packages/foundry/contracts/SocialRecoveryWallet.sol`.

### Instructions
The wallet will have a set of guardians who can initiate a "recovery" which means they can switch the owner to another address if enough of them signal the change is needed. When the wallet is in recovery mode

 Start by creating a contract called `SocialRecoveryWallet`. The contract should be owned by the deploying address (use `msg.sender` in the constructor). The constructor's only parameter should be an array of addresses representing "guardians". For this challenge it is assumed that all guardians will need to signal their support for a new owner in order to change the owner. You can imagine setups where it wouldn't require all of the guardians but only the majority, similar to a multisig but we won't worry with that functionality.

 The contract will need the following write functions:
 - `call(address callee, uint256 value, bytes calldata data)` should essentially act as a passthrough, allowing the smart contract wallet to make any call that it is prompted with but only when the owner is the caller. It should be able to move value sent with the transaction or move ETH sitting in the contract. It should be able to use this function to interact with other contracts such as ERC20 tokens.
 - `signalNewOwner(address _proposedOwner)` should only be callable by a guardian. It should set some variables within the contract so that other guardians can call the same function to increase the amount of votes. When all the guardians have signaled their support then this method should automatically set the new owner to the proposed owner. Emit this event when a guardian signals `NewOwnerSignaled(address by, address proposedOwner)` and emit this event when the new owner has been set: `RecoveryExecuted(address newOwner)`.
 - `addGuardian(address _guardian)` should only be allowed to be called by the owner and should add a new guardian to the contract. If the address is already a guardian then revert.
 - `removeGuardian(address _guardian)` should only be allowed to be called by the owner and should remove an existing guardian, reverting if they don't exist.

 Also add view methods, variables or a mapping that allows the following to be queried:

 - `owner()` should return the owner address.
 - `isGuardian(address)` should return a bool that is true if the given address is a guardian, false if not.


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
Once you have a working solution and all the tests are passing your next move is to deploy your lovely contract to a supported testnet. See the list of [supported testnets](https://github.com/BuidlGuidl/eth-tech-tree-backend/blob/12799cc95950ee3bd8d523b8d2d2e2f05f131268/packages/server/utils/config.ts#L21).

### Setting up your wallet (if you haven't already)
First you will need to generate an account. **You can skip this step if you have already created a keystore on your machine. Keystores are located in `~/.foundry/keystores`**
```bash
  yarn generate
```
You can optionally give your new account a name be passing it in like so: `yarn generate NAME-FOR-ACCOUNT`. The default is `scaffold-eth-custom`.

You will be prompted for a password to encrypt your newly created keystore. Make sure you choose a [good one](https://xkcd.com/936/) if you intend to use your new account for more than testnet funds.

Now you need to update `packages/foundry/.env` so that `ETH_KEYSTORE_ACCOUNT` = your new account name ("scaffold-eth-custom" if you didn't specify otherwise).

Now you are ready to send some testnet funds to your new account.
Run the following to view your new address and balances across several networks.
```bash
  yarn account
```
To fund your account on your chosen testnet (e.g., Sepolia), search for a testnet faucet or ask around in onchain developer groups who are usually more than willing to share. Send the funds to your wallet address and run `yarn account` again to verify the funds show in your balance on that network.

### Deploying your contract
Sepolia is used below as an example. The ETH Tech Tree supports multiple testnets; see the list of [supported testnets](https://github.com/BuidlGuidl/eth-tech-tree-backend/blob/12799cc95950ee3bd8d523b8d2d2e2f05f131268/packages/server/utils/config.ts#L21). Replace `sepolia` with your chosen supported network in the commands.

Once you have confirmed your balance on your chosen network you can run this command to deploy your contract.
```bash
  yarn deploy --network sepolia
```
Now you need to verify it on the Sepolia Etherscan (or the explorer for your chosen network).
```bash
  yarn verify --network sepolia
```
Copy your deployed contract address from your console and paste it in at a block explorer for your chosen network. You should see a green checkmark on the "Contract" tab showing that the source code has been verified.

Now you can return to the ETH Tech Tree CLI, navigate to this challenge in the tree and submit your deployed contract address. Congratulations!
