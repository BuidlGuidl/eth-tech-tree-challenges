# Wrapped Token Challenge - ETH Tech Tree
*This challenge is meant to be used in the context of the [ETH Tech Tree](https://github.com/BuidlGuidl/eth-tech-tree).*

@@TOP_CONTENT@@

## Challenge Description
This challenge will require you to write an [ERC20](https://eips.ethereum.org/EIPS/eip-20) compliant token wrapper for ETH. Your task starts in `packages/foundry/contracts/WrappedETH.sol`. Use your Solidity skills to make this smart contract receive ETH and give the depositor an equal amount of WETH, an ERC20 version of native ETH. It should also handle a user reclaiming their ETH for their WETH.  An ERC20 form of ETH is useful because DeFi protocols don't have to worry about integrating special functions for handling native ETH, instead they can just write methods that handle any ERC20 token. 

### Step 1
Write a contract called `WrappedETH` and make it a standard ERC20 implementation with all the methods and events.
Here is a helpful reference: [Original Ethereum Improvement Proposal for the ERC-20 token standard](https://eips.ethereum.org/EIPS/eip-20).

---
<details markdown='1'>
<summary>🔎 Hint</summary>
If you have never implemented your own ERC20 token then this is a great opportunity to dig into a plethora of documents on the subject. If that is old hat to you then you can always import the OpenZeppelin ERC20 contract and implement it in your contract.

```solidity
  import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

  contract WrappedETH is ERC20("WrappedEth", "WETH") {
    ...
  }
```

</details>

---
### Step 2
Then add two additional methods:
1. A `deposit()` method should receive ETH and update the senders token balance to include their deposit. It should emit a `Deposit(address depositor, uint amount)` event that records the depositor address and the amount deposited.
2. A `withdraw(uint amount)` method that exchanges the users token balance for ETH. It should emit a `Withdrawal(address withdrawer, uint amount)` event that records the sender and the amount they withdrew.

Check your logic to make sure nobody can withdraw more than the tokens they have allocated.

What happens when someone YOLOs ETH to your contract without targeting the `deposit` method? See if you can handle that elegantly.

---
<details markdown='1'>
<summary>🔎 Hint</summary>
Make sure you have the <a href="https://solidity-by-example.org/fallback/">`fallback` and `receive` default handling methods</a> set up to automatically assume the `deposit` method has been called.
</details>

---

@@BOTTOM_CONTENT@@