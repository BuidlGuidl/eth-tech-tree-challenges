# Dead Man's Switch - ETH Tech Tree
*This challenge is meant to be used in the context of the [ETH Tech Tree](https://github.com/BuidlGuidl/eth-tech-tree).*

You are an operative of a group known as **_The Decentralized Resistance_**. On a recent mission several operatives went missing after an assault by the **_Authoritarian Regime_**. Part of their mission involved obtaining a wallet address for an intelligence provider in your network for the purpose of paying them for information. The missing operatives had access to wallets with funds intended to complete this payment but in the wake of them being missing, so are the funds. Your role inside the organization is to ensure that in the event of capture or death during a mission, the organization can reclaim any funds that were held by the operative to help continue to fund your just cause.

@@TOP_CONTENT@@

## Challenge Description

In this challenge, you will create a smart contract that implements a "Dead Man's Switch". This contract allows users to deposit funds (ETH or other tokens) and set a time interval for regular "check-ins". If the user fails to check in within the specified time frame, designated beneficiaries can withdraw the funds. 

You can find your assignment in `packages/foundry/contracts/DeadMansSwitch.sol`.

### Instructions
Create a contract called `DeadMansSwitch`. 

Add the following write functions:

- `setCheckInInterval(uint interval)` -- Each account should be able to set their own check in interval. If they miss the interval, then any of their added beneficiaries can withdraw the funds. 
- `checkIn()` -- This function should reset the clock on when the accounts funds are able to be withdrawn by a beneficiary. It should be called any time an account interacts with any of these write functions. It should also be able to be called by the EOA (it should be public, not internal). Emit a `CheckIn(address account, uint timestamp)` event.
- `addBeneficiary(address beneficiary)` -- This function should add the given address to the caller's list of beneficiaries. Emit a `BeneficiaryAdded(address user, address beneficiary)` event.
- `removeBeneficiary(address beneficiary)` -- This function should remove a beneficiary from the caller's list of beneficiaries. Emit a `BeneficiaryRemoved(address user, address beneficiary)` event.
- `deposit()` -- Should add any value with which it is called to the callers balance. Emit a `Deposit(address depositor, uint amount)` event.
- `withdraw(address account, uint amount)` -- Should enable an account to withdraw from it's own balance in the contract. Should also allow a beneficiary to withdraw from a delegated account if the time since the accounts last check in is greater than the check in interval set up by the account. Emit a `Withdrawal(address beneficiary, uint amount)` event.

And the following view functions:

- `balanceOf(address account)` -- Return the accounts balance held in the contract.
- `lastCheckIn(address account)` -- Return the last check in time for the given account.
- `checkInInterval(address account)` -- Return the accounts check in interval.

Make sure your contract can handle direct calls with value even when they don't specify the `deposit` function.

@@BOTTOM_CONTENT@@