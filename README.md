# 🤝💸 Multisend Challenge - ETH Tech Tree 
*This challenge is meant to be used in the context of the [ETH Tech Tree](https://github.com/BuidlGuidl/eth-tech-tree).*

ETH and token transference are used all the time within the web3 space. Anyone can see it when they follow txs with NFTs, DeFi, RWAs, gaming, and more. As we can see in other challenges, this ability to have transparent, immutable transference of value is one aspect that makes blockchain technology so powerful. Therefore it is important to understand how to construct these types of transactions, at their most basic levels. 👨🏻‍🏫

Native assets to a blockchain, such as ETH for Ethereum, and ERC20 tokens follow different sequences when being transferred. This tutorial will challenge you as the student to understand one example of carrying out these basic transactions.

@@TOP_CONTENT@@

## Challenge Description

This challenge will require the user to build a contract that is capable of sending tokens or ETH to multiple provided addresses. Transference of tokens and ETH are basics that a student must understand in smart contract development.

Your task starts in `packages/foundry/contracts/Multisend.sol`. Use your solidity skills to make this smart contract whilst meeting the following criteria:

- The contract design uses two separate methods, one for sending ETH and one for sending any ERC20 token. 
- Each method will be provided an array of addresses and an array of amounts. 
- The ERC20 method will also receive the token address.

Further `requirements` are outlined within the Nat Spec inside `Multisend.sol` similar to all other tech tree challenges. Use the Nat Spec comments combined with troubleshooting using the unit tests for this challenge by following the foundry instructions below.

@@BOTTOM_CONTENT@@