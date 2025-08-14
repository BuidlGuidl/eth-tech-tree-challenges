# Moloch DAO Rage Quit Mechanism - ETH Tech Tree

You can install this challenge using the following command:
```bash
    npx create-eth@1.0.3 -e BuidlGuidl/eth-tech-tree-challenges:moloch-rage-quit-extension moloch-rage-quit
```

You are a main contributor to a well known DAO that distributes ETH to builders in the space. Recently there was a proposal to fund a group of hackers with a splotchy past. You vote against the proposal but the majority of the DAO voted in support. Now you are left feeling somewhat disenfranchised with the DAO but you have no way to formally quit. 

## Challenge Description
You decide that when you start your next DAO you will create a Rage Quit function.

Rage Quit simple means that a member can leave the DAO without leaving behind their share of the treasury. By including a Rage Quit mechanism in your DAO contract it lowers the barriers to become a member because people won't feel locked in if the DAO changes direction over time. Each member of the DAO will have a certain amount of shares assigned to them when they become a member. These shares will entitle them to a certain portion of the ETH holdings of the DAO. 

```
(Member Shares / Total Shares) x DAO ETH Balance = Members ETH Portion
```

You challenge starts in `packages/foundry/MolochRageQuit.sol`

### Instructions

Start by creating a contract called `MolochRageQuit`. In the constructor expect to be given a uint parameter representing how many shares to allocate to the deployer address.

Then define the following functions:
- `propose(address contractToCall, bytes data, uint deadline)` Only members should be able to call this function. Create a proposal that contains a contract address to call, the data with which to call it, and the deadline by which the voting must be completed. Emit an event `ProposalCreated(uint proposalId, address proposer, address contractToCall, bytes dataToCallWith, uint deadline)`.
- `addMember(address newMember, uint shares)` This method can only be called as a result of a proposal so it shouldn't allow any calls unless they are from its own contract. It accepts the new members address and the amount of shares to allocate to them. It should emit an event when the member is added: `MemberAdded(address newMember)`  
- `vote(uint proposalId)` This method takes a proposal id and adds votes (based on the amount of shares owned) for the caller. It should revert if called by a non-member, when called by an address that has already voted or if the proposal doesn't exist. It should emit `Voted(uint proposalId, address member)`.
- `executeProposal(uint proposalId)` Accepts a proposal id and checks if the proposal deadline has passed and if the votes are a majority of members. Revert if those cases are not true. If those cases are true then it should execute the proposal by calling the proposal's contract address with the proposal's data. Then it should emit `ProposalExecuted(uint proposalId)`.
- `rageQuit()` Should only be allowed to be called by a member. It should take the calling member's shares and divide them by all existing shares. It should send them the portion of ETH that matches their percentage of share ownership and emit `RageQuit(address member, uint returnedETH)`.

And a couple view methods (or mappings if you like):
- `getProposal(uint proposalId)` Should return a tuple with the following properties of a proposal:  
        ```
        (address proposer, address contractAddr, bytes data, uint256 votes, uint256 deadline)
        ```
- `isMember(address)` Should receive a member or non members address and return whether that address is a member with a bool value. 

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
