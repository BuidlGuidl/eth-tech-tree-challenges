# Token Voting Contract - ETH Tech Tree

You can install this challenge using the following command:
```bash
    npx create-eth@latest -e BuidlGuidl/eth-tech-tree-challenges:token-voting-extension token-voting
```

In a dystopian future where mega-corporations have seized control over all aspects of life, a brave group of technologists and activists form an underground movement known as ***The Decentralized Resistance***. Their mission is to create a new society governed by the people, free from the tyranny of corporate overlords. They believe that blockchain technology holds the key to building a fair and transparent governance system. As a key developer in The Decentralized Resistance, you are tasked with creating the smart contracts that will enable this new society to thrive.

## Challenge Description
<ins>***The Decentralized Resistance***</ins> has grown rapidly, attracting members from all walks of life who are united in their desire for freedom and self-governance. To ensure that every member's voice is heard, the resistance needs a secure and transparent voting system.

Your task is to create a smart contract that allows token holders to vote on a specific proposal. 
The proposal is **Expand the Intelligence Network**: 
``"Should we allocate resources to expand our intelligence network and gather more information about the activities of the mega-corporations?"``

Each token holder can vote either in favor or against the proposal, and their vote weight is determined by the number of tokens they hold.

Your task starts in `packages/foundry/contracts/Voting.sol`. Use your solidity skills to make this smart contract allow <ins>***The Decentralized Resistance***</ins> to govern itself!

### Step 1
Notice the `DecentralizedResistanceToken.sol` contract. This contract is the ERC20 token that members hold and use to vote. Their vote weight is determined by the quantity of tokens they hold.

Start by defining a contract with the name `Voting`.

The constructor should receive an address representing the "DRT" token and a uint256 representing the time period for which the vote will be open. Those parameters should set the value of state variables inside the contract for later use. Don't import the DRT contract directly, instead use OpenZeppelin's IERC20 interface.

---

<details markdown='1'>
<summary>🔎 Hint</summary>

```solidity
  contract Voting {
    ...
    constructor(address _tokenAddress, uint256 _votingPeriod) {
        // "token" and "votingDeadline" state variables should be defined somewhere in the contract
        token = IERC20(_tokenAddress);
        votingDeadline =  _votingPeriod;
    }
    ...
  }
```
</details>

---

### Step 2
Define a function called `vote` that receives a bool as a parameter. The bool represents whether the caller is voting "For" or "Against" the proposal.
***Assumptions***
- Revert if caller doesn't have any "DRT" tokens.
- Revert if the voting period (set in the constructor) has already passed.
- Revert if the caller has already voted.
- The caller's token balance should be counted towards their outcome, "For" or "Against" the proposal. For instance, if Sam holds 10 tokens and votes against the proposal then the proposal should have 10 votes added to the "Against" outcome.
- Emit an event called `VoteCasted(address voter, bool vote, uint256 weight)` with the caller address, the bool representing whether they were "For" or "Against" and their token balance.

### Step 3
Back to the `DecentralizedResistanceToken`. It has already been set to call a method that doesn't yet exist on your new contract that is meant to remove votes for a token holder any time they transfer tokens. This guarantees a voter can't use the same tokens to vote from different wallet addresses.

Define a function called `removeVotes(address from)` that receives an address. The function should completely remove that addresses votes so that it is as if they never voted. 
***Assumptions***
- This method should revert if it isn't being called by the token contract.
- The address should be able to call the voting contract to vote again with their new balance. 
- It should emit a new event called `VotesRemoved(address voter, uint256 weight)`.

---

<details markdown='1'>
<summary>🔎 Hint</summary>
You can find the number of votes to remove by checking their token balance as this is called before moving them. You may need to update the `vote` function with a way to track whether the voter voted "For" or "Against" so you know which to remove the votes from.
</details>

---

### Step 4
The last step is we need to be able to call a function to get the result of the vote.

Define a function called `getResult`.

This function should revert if the vote period is not over yet. It should return true or false depending on whether a simple majority is reached:`votesFor > votesAgainst`.

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
You can optionally give your new account a name be passing it in like so: `yarn generate NAME-FOR-ACCOUNT`. The default is `scaffold-eth-custom`.

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
