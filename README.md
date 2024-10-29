# Token Voting Contract - ETH Tech Tree
*This challenge is meant to be used in the context of the [ETH Tech Tree](https://github.com/BuidlGuidl/eth-tech-tree).*

In a dystopian future where mega-corporations have seized control over all aspects of life, a brave group of technologists and activists form an underground movement known as ***The Decentralized Resistance***. Their mission is to create a new society governed by the people, free from the tyranny of corporate overlords. They believe that blockchain technology holds the key to building a fair and transparent governance system. As a key developer in The Decentralized Resistance, you are tasked with creating the smart contracts that will enable this new society to thrive.

@@TOP_CONTENT@@

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

The constructor should receive an address representing the "DRT" token and a uint256 representing the time period for which the vote will be open. Those parameters should set the value of state variables inside the contract for later use.

---

<details markdown='1'>
<summary>🔎 Hint</summary>

```solidity
  contract Voting {
    ...
    constructor(address _tokenAddress, uint256 _votingPeriod) {
        // "token" and "votingDeadline" state variables should be defined somewhere in the contract
        token = _tokenAddress;
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
- The caller's token balance should be counted towards their outcome, "For" or "Against" the proposal. For instance, if same holds 10 tokens and votes against the proposal then the proposal should have 10 votes added to the "Against" outcome.
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

@@BOTTOM_CONTENT@@