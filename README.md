# 🪙👩🏼‍🔬 Rebasing Token - ETH Tech Tree
*This challenge is meant to be used in the context of the [ETH Tech Tree](https://github.com/BuidlGuidl/eth-tech-tree).*

Rebasing tokens have become a fascinating aspect of the web3 space, appearing frequently in projects involving DeFi, algorithmic stablecoins, and more. These tokens adjust their supply automatically, based on specific rules, which can create unique opportunities and challenges within the ecosystem. 

---
<details markdown='1'><summary>👩🏽‍🏫 Fun question: what is an ERC20 that can be easily mistaken as a rebasing token? </summary>
Answer: An example of a token that exhibits traits that rhyme with rebasing, but is not rebasing, is stETH. stETH does not change its supply, instead its price increases as staking rewards accumulate. 
</details>  

---

Understanding how to create a rebasing token can offer valuable insights into more complex smart contract interactions and state management on the blockchain. 🧑‍💻

In this tutorial, we will guide you through the process of constructing a rebasing token using Solidity. By the end of this challenge, you will have a deeper understanding of the mechanisms behind rebasing and how to implement them in your own smart contracts.

@@TOP_CONTENT@@

## Challenge Description

This challenge will require users to write an ERC20 contract that contains rebasing token logic. 

Rebasing tokens automatically adjust its supply typically based on some external reason, for example: to target a specific price. As the token supply is increased or decreased periodically, the effects are applied to all token holders, proportionally. Rebasing can be used as an alternative price stabilization method versus traditional market mechanisms.

An example of a rebasing token is the Ampleforth token, AMPL.

AMPL uses old contracts called `UFragments.sol`, where `Fragments` are the ERC20 and the underlying value of them are denominated in `GONS`. Balances of users, transference of tokens, are all calculated using `GONs` via a mapping and a var called `_gonsPerFragment`. This var changes and thus changes the balance of the Fragments token for a user since the `balanceOf()` function equates to `_gonBalances[who].div(_gonsPerFragment)`. 

> For reference, this can be seen [here](https://etherscan.deth.net/address/0xD46bA6D942050d489DBd938a2C909A5d5039A161).

**Now that you understand the context of rebasing tokens, create a contract named `RebasingERC20` that defines one named `Rebasing Token`, with the symbol `$RBT`, with the following parameters:**

1. Inherits all ERC20 methods, events and errors.
2. The contract has an owner.
3. Constructor will receive the total supply as a parameter and it will be allocated to the owner.
4. There is a method called `rebase` that accepts an `int256` that determines the amount to rebase, plus or minus. It should only be allowed to be called by the contract owner. When called, emit an event called `Rebase(uint256 totalSupply)` with the new total supply of tokens.

**Assumptions:**

- User balances should change after a rebase.
- The rebase mechanism should update the total supply by whatever number it is supplied.
- As an example, if the total token supply is 10mm and it is rebased with negative 9mm (`rebase(-9000000)`) then the total supply is only 1mm and each holder holds 1/10th the amount they held prior to the rebase. A balance of 1000 would become 100. This should work when given a positive number as well. `rebase(9000000)` would return the total supply and user balances to what they were prior to the first rebase. 
- Don't change token allowances when rebases occur.
- For the sake of simplicity and to avoid rounding errors you can assume that the rebase method will only be called with large numbers that are wholly divisible by 10e6.

---
<details markdown='1'>
<summary>🔎 Hint</summary>
You will need to either inherit an OpenZeppelin ERC20 implementation and override several of methods or just implement your own ERC20 implementation from scratch.
<details markdown='1'>
<summary>Another hint please?!</summary>
The balances returned by `balanceOf(address)` will need to be different from the actual internal balances. You may find it helpful to assign the totalSupply constructor parameter to a variable so you can reference it later when determining how much the supply has changed through rebasing.
<details markdown='1'>
<summary>Come again?</summary>
When you return a users balance it should be derived by some logic. You could define a variable that gets adjusted when a rebase occurs and divide/multiply the internally tracked balance by this variable to return the adjusted balance. Each time a rebase occurs this variable would be updated accordingly.
</details>
</details>
</details>

---
Here are some helpful references:
- [AMPL Project Details](https://docs.ampleforth.org/learn/about-the-ampleforth-protocol#:~:text=their%20FORTH%20tokens.-,How%20the%20Ampleforth%20Protocol%20Works,-The%20Ampleforth%20Protocol)
- [AMPL Github](https://github.com/ampleforth/ampleforth-contracts/tree/master)
- [AMPL Rebasing Token Code](https://etherscan.deth.net/address/0xD46bA6D942050d489DBd938a2C909A5d5039A161)

@@BOTTOM_CONTENT@@