# 🤝💸 Multisend Challenge - ETH Tech Tree 
*This challenge is meant to be used in the context of the [ETH Tech Tree](https://github.com/BuidlGuidl/eth-tech-tree).*

ETH and token transference are used all the time within the web3 space. Anyone can see it when they follow txs with NFTs, DeFi, RWAs, gaming, and more. As we can see in other challenges, this ability to have transparent, immutable transference of value is one aspect that makes blockchain technology so powerful. Therefore it is important to understand how to construct these types of transactions, at their most basic levels. 👨🏻‍🏫

Native assets to a blockchain, such as ETH for Ethereum, and ERC20 tokens follow different sequences when being transferred. This tutorial will challenge you as the student to understand one example of carrying out these basic transactions.

@@TOP_CONTENT@@

## Challenge Description

This challenge will require you to build a contract that is capable of sending tokens or ETH to multiple provided addresses. Transference of tokens and ETH are basics that you must understand in smart contract development.

Your task starts in `packages/foundry/contracts/Multisend.sol`.

### Step 1
Create a contract called `Multisend` and define two methods:
1. `sendETH` which takes an array of payable addresses that represents the recipients and an array of uint amounts representing the amount to send to each address in the array of recipients. Both of the arrays should have equal lengths. Use the arrays to send the correct amount to each recipient. Emit an event called `SuccessfulETHTransfer(address _sender, address payable[] _receivers, uint256[]  _amounts)`. You should revert if any transfer is unsuccessful.
---
<details markdown='1'><summary>🔎 Hint</summary>
The function signature should look like this:

```
sendETH(address payable[], uint256[])
```
</details>  

---
2. `sendTokens` which takes an array of payable addresses that represents the recipients and an array of uint amounts representing the amount to send to each address in the array of recipients. Both of the arrays should have equal lengths. Use the arrays to send the correct amount of tokens to each recipient. Emit an event called `SuccessfulTokenTransfer(address indexed _sender, address[] indexed _receivers, uint256[] _amounts, address _token)`. You should revert if any transfer is unsuccessful.
---
<details markdown='1'><summary>🔎 Hint</summary>
The function signature should look like this:

```
sendTokens(address[], uint256[], address)
```
</details>  

---

@@BOTTOM_CONTENT@@