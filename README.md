# DAO governance proposals and Voting - ETH Tech Tree
*This challenge is meant to be used in the context of the [ETH Tech Tree](https://github.com/BuidlGuidl/eth-tech-tree).*

In a dystopian future where mega-corporations have seized control over all aspects of life, a brave group of technologists and activists form an underground movement known as **_The Decentralized Resistance_**. Their mission is to create a new society governed by the people, free from the tyranny of corporate overlords. They believe that blockchain technology holds the key to building a fair and transparent governance system. As a key developer in **_The Decentralized Resistance_**, you are tasked with creating the smart contracts that will enable this new society to thrive.

@@TOP_CONTENT@@

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

@@BOTTOM_CONTENT@@