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

**Now that you understand the context of rebasing tokens, create one named `Rebasing Token`, with the symbol `$RBT`, with the following parameters:**

1. Inherits ERC20.
2. Rebases RBT, changing the `$RBT` supply proportionally for all token holders.
3. Rebases with a `int` param `SupplyDelta` that dictates how the supply expands or constricts. Rebases can be positive or negative.
4. Rebasing logic: Simply use the initial supply, and the total supply (when rebases occur) to calculate a `_scalingFactor`. The `_scalingFactor` is used to adjust token holder's balances proportionally after rebases.
5. Ensure that the amount transferred when `transfer()` or `transferFrom()` are called are adjusted as per the `_scalingFactor` at the time of the tx.
6. Use the `abs` helper function as needed, and make sure to write the `_update()` implementation. 

**Assumptions:**

1. `$RBT` rebasing is called based on some external events. For this exercise it doesn't really matter, but you could imagine that decentralized oracles are querying the price of `$RBT` and if it deviates from some set price then rebases are called.
2. `$RBT` contract owner could be some treasury contract or something that exists in your imagination 😉.
3. `$RBT` _initialSupply is 1 million tokens.
4. `$RBT` `decimals` is 18.
5. `$RBT` is distributed via some imaginary mechanism, for now it's just assumed as another ERC20 and thus can be transferred as such. Thus this is not in the scope of the challenge. That said, tests to ensure that your challenge submission works will just transfer some `$RBT` to fake users and check that your rebasing calculations work correctly.
6. Minting new tokens is not handled via normal mint() functions, token balances are changed as per the rebasing logic implemented within this contract.
7. Burning is handled via the `_update()` hook instead of the typical `burn()` function seen with other ERC20s.

---
Here are some helpful references:
- [AMPL Project Details](https://docs.ampleforth.org/learn/about-the-ampleforth-protocol#:~:text=their%20FORTH%20tokens.-,How%20the%20Ampleforth%20Protocol%20Works,-The%20Ampleforth%20Protocol)
- [AMPL Github](https://github.com/ampleforth/ampleforth-contracts/tree/master)
- [AMPL Rebasing Token Code](https://etherscan.deth.net/address/0xD46bA6D942050d489DBd938a2C909A5d5039A161)

@@BOTTOM_CONTENT@@