# DAO governance proposals and Voting - ETH Tech Tree

You can install this challenge using the following command:
```bash
    npx create-eth@1.0.3 -e BuidlGuidl/eth-tech-tree-challenges:dao-governance-proposals-and-voting-extension dao-governance-proposals-and-voting
```

In a dystopian future where mega-corporations have seized control over all aspects of life, a brave group of technologists and activists form an underground movement known as **_The Decentralized Resistance_**. Their mission is to create a new society governed by the people, free from the tyranny of corporate overlords. They believe that blockchain technology holds the key to building a fair and transparent governance system. As a key developer in **_The Decentralized Resistance_**, you are tasked with creating the smart contracts that will enable this new society to thrive.

## Challenge Description

**_The Decentralized Resistance_** has continued to grow and would like to build a system where any member (token holder) can propose new ideas and the community can then vote on that idea.

You will start your task in `packages/foundry/contracts/Governance.sol`. Use your Solidity skills to enable **_The Decentralized Resistance_** to govern itself effectively! 

### Step 1
Notice the `DecentralizedResistanceToken.sol` contract. This contract is the ERC20 token that members hold and use to vote. Their vote weight is determined by the quantity of tokens they hold.

Start by defining a contract with the name `Governance`.

The constructor should receive an address representing the "DRT" token and a uint256 representing the time period for which a proposal vote will be open. Those parameters should set the value of state variables inside the contract for later use.

---

<details markdown='1'>
<summary>🔎 Hint</summary>

```solidity
  contract Governance {
    ...
    constructor(address _tokenAddress, uint256 _votingPeriod) {
        // "token" and "votingPeriod" state variables should be defined somewhere in the contract
        token = _tokenAddress;
        votingPeriod =  _votingPeriod;
    }
    ...
  }
```
</details>

---

### Step 2
Define a function called `propose` that receives a string as a parameter. The string represents the title of the proposal. Create a proposal in whatever way you see fit.

You will likely need to return to this method later when you grapple more constraints. 

***Assumptions***
- Proposals should have a set deadline based on the votingPeriod (set in the constructor).
- Only one proposal can be active at any point in time - no overlapping vote periods.
- However, it is fine to queue the next proposal but no more than one proposal should be in the queue at any time.
- Emits an event called `ProposalCreated(uint proposalId, string title, uint votingDeadline, address creator)` with the proposalId, title, voting deadline and the creator address.
- The function should a unique proposalId that can be used to query the proposal later.

### Step 3
Define a view function called `getProposal` that receives a uint. The uint represents unique id of the proposal.

This function should return that proposals title, deadline and creator address.

---

<details markdown='1'>
<summary>🔎 Hint</summary>
This highly depends on how you are storing your proposal data but just make sure the function returns a tuple like this:

```solidity
    function getProposal(uint id) public view returns (string memory title, uint deadline, address creator) {
        // Set values for title, deadline and creator however you like
    }
```
</details>

---

### Step 4
Define a function called `vote` that receives a uint8 as a parameter. The uint8 represents whether the caller is voting "Against", "For" or "Abstain" on the proposal. The uint8 should match the following:

"Against" = 0
"For" = 1
"Abstain" = 2

"Abstain" is a nice thing to have because members can signal they are active participants in the governance process without having to feel the need to have a strong opinion for or against each proposal.

***Assumptions***
- Revert if caller doesn't have any "DRT" tokens.
- Revert if there is no active proposal.
- Revert if the caller has already voted.
- The caller's token balance should be counted towards their outcome, "For", "Against" or simply "Abstaining" the proposal. For instance, if Sam holds 10 tokens and votes against the proposal then the proposal should have 10 votes added to the "Against" outcome.
- Emits an event called `VoteCasted(uint proposalId, address voter, uint8 vote, uint256 weight)`.

---

<details markdown='1'>
<summary>🔎 Hint</summary>
In light of the idea of an active and queued proposal existing you might find it helpful to check if the active proposal is still within the deadline and if not, set the queued proposal as the new active proposal. This might need to happen from more than one function in your contract...
</details>

---

### Step 5
Back to the `DecentralizedResistanceToken`. It has already been set to call a method that doesn't yet exist on your new contract that is meant to remove votes for a token holder any time they transfer tokens. This guarantees a voter can't use the same tokens to vote from different wallet addresses.

Define a function called `removeVotes(address from)` that receives an address. The function should completely remove that addresses votes from the active proposal so that it is as if they never voted. This should not impact votes they had for past proposals.
***Assumptions***
- This method should revert if it isn't being called by the token contract.
- The address should be able to call the voting contract to vote again with their new balance. 
- It should emit a new event called `VotesRemoved(address voter, uint8 vote, uint256 weight)` for the address, their type of vote that was removed and their token weight.

---

<details markdown='1'>
<summary>🔎 Hint</summary>
You can find the number of votes to remove by checking their token balance as this is called before moving them. You may need to update the `vote` function with a way to track which way the address voted so you know which to remove the votes from.
</details>

---

### Step 6
The last step is we need to be able to call a function to get the result of the vote.

Define a function called `getResult` that receives a uint representing the proposal id for which you want the result.

This function should revert if the vote period is not over yet. It should return true or false depending on whether a simple majority is reached:`votesFor > votesAgainst`. Abstaining votes have no effect on the outcome.

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
