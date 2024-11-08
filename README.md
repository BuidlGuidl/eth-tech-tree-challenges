# Moloch DAO Rage Quit Mechanism - ETH Tech Tree
*This challenge is meant to be used in the context of the [ETH Tech Tree](https://github.com/BuidlGuidl/eth-tech-tree).*

You are a main contributor to a well known DAO that distributes ETH to builders in the space. Recently there was a proposal to fund a group of hackers with a splotchy past. You vote against the proposal but the majority of the DAO voted in support. Now you are left feeling somewhat disenfranchised with the DAO but you have no way to formally quit. 

@@TOP_CONTENT@@

## Challenge Description
You decide that when you start your next DAO you will create a Rage Quit function.

Rage Quit simple means that a member can leave the DAO without leaving behind their share of the treasury. By including a Rage Quit mechanism in your DAO contract it lowers the barriers to become a member because people won't feel locked in if the DAO changes direction over time. Each member of the DAO will have a certain amount of shares assigned to them when they become a member. These shares will entitle them to a certain portion of the ETH holdings of the DAO. 

```
(Member Shares / Total Shares) x DAO ETH Balance = Members ETH Portion
```

You challenge starts in `packages/foundry/MolochRageQuit.sol`

### Instructions

Start by creating a contract called `MolochRageQuit`. In the constructor expect ot be given a uint parameter representing how many shares to allocate to the deployer address.

Then define the following functions:
- `propose(address contractToCall, bytes data, uint deadline)` Only members should be able to call this function. Create a proposal that contains a contract address to call, the data with which to call it, and the deadline by which the voting must be completed. Emit an event `ProposalCreated(uint proposalId, address proposer, address contractToCall, bytes dataToCallWith, uint deadline)`.
- `addMember(address newMember, uint shares)` This method can only be called as a result of a proposal so it shouldn't allow any calls unless they are from its own contract. It accepts the new members address and the amount of shares to allocate to them. It should emit an event when the member is added: `MemberAdded(address newMember)`  
- `vote(uint proposalId)` This method takes a proposal id and adds a vote for the caller. It should revert if called by a non-member or if called by an address that has already voted or if the proposal doesn't exist. It should emit `Voted(uint proposalId, address member)`.
- `executeProposal(uint proposalId)` Accepts a proposal id and checks if the proposal deadline has passed and if the votes are a majority of members. Revert if those cases are not true. If those cases are true then it should execute the proposal by calling the proposal's contract address with the proposal's data. Then it should emit `ProposalExecuted(uint proposalId)`.
- `rageQuit()` Should only be allowed to be called by a member. It should take the calling member's shares and divide them by all existing shares. It should send them the portion of ETH that matches their percentage of share ownership and emit `RageQuit(address member, uint returnedETH)`.

And a couple view methods (or mappings if you like):
- `getProposal(uint proposalId)` Should return a tuple with the following properties of a proposal:  
        ```
        (address proposer, address contractAddr, bytes data, uint256 votes, uint256 deadline)
        ```
- `isMember(address)` Should receive a member or non members address and return whether that address is a member with a bool value. 

@@BOTTOM_CONTENT@@