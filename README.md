# Dead Man's Switch - ETH Tech Tree
*This challenge is meant to be used in the context of the [ETH Tech Tree](https://github.com/BuidlGuidl/eth-tech-tree).*

You are an operative of a group known as **_The Decentralized Resistance_**. On a recent mission several operatives went missing after an assault by the **_Authoritarian Regime_**. Part of their mission involved obtaining a wallet address for an intelligence provider in your network for the purpose of paying them for information. The missing operatives had access to wallets with funds intended to complete this payment but in the wake of them being missing, so are the funds. Your role inside the organization is to ensure that in the event of capture or death during a mission, the organization can reclaim any funds that were held by the operative to help continue to fund your just cause.

@@TOP_CONTENT@@

## Challenge Description

In this challenge, you will create a smart contract that implements a "Dead Man's Switch". This contract allows users to deposit funds (ETH or other tokens) and set a time interval for regular "check-ins". If the user fails to check in within the specified time frame, designated beneficiaries can withdraw the funds. 

Complete the logic in `packages/foundry/contracts/DeadMansSwitch.sol` by following the requirements to fulfill your mission. Good luck!

@@BOTTOM_CONTENT@@