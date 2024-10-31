# Social Recovery Wallet Challenge - ETH Tech Tree
*This challenge is meant to be used in the context of the [ETH Tech Tree](https://github.com/BuidlGuidl/eth-tech-tree).*

Mother's day is coming up and you decide to send your mom some ETH to help her learn more about your world. You set up a new MetaMask wallet and write down the seed phrase on a nice piece of flowered stationary. You briefly consider taking custody of the phrase on her behalf, but ultimately decide against it. To understand your cypherpunk values, she needs to truly own her new gift. She's ecstatic. She immediately hops online, and for the next few days, continues to explore the rich new world that is web3. Then...disaster strikes. Her laptop dies and she's LOST HER SEED PHRASE.

@@TOP_CONTENT@@

## Challenge Description

A year has passed, and after the horrific debacle of last year's Mother's day, you've vowed to come up with a more user-friendly wallet design. You need it to be able to withstand the loss of a seed phrase, while retaining as much autonomy as possible.

But how?? You hearken back to your own upbringing for inspiration. Sure, your mom was a central figure, but ultimately, you realize, **it took a village**. You decide to develop your new wallet with this same strategy. What if you could select a group of trustworthy `guardian` addresses that could come together to recover the wallet after the seed phrase was lost.

With that idea, you begin work on your project in `packages/foundry/contracts/SocialRecoveryWallet.sol`.

### Instructions
The wallet will have a set of guardians who can initiate a "recovery" which means they can switch the owner to another address if enough of them signal the change is needed. When the wallet is in recovery mode

 Start by creating a contract called `SocialRecoveryWallet`. This contract should have an owner set during deployment. Also, the constructor should receive an array of addresses representing "guardians". For this challenge it is assumed that all guardians will need to signal their support for a new owner in order to change the owner. You can imagine setups where it wouldn't require all of the guardians but only the majority, similar to a multisig but we won't worry with that functionality.

 The contract will need the following write functions:
 - `call(address callee, uint256 value, bytes calldata data)` should essentially act as a passthrough, allowing the smart contract wallet to make any call that it is prompted with but only when the owner is the caller. It should be able to move value sent with the transaction or move ETH sitting in the contract. It should be able to use this function to interact with other contracts such as ERC20 tokens.
 - `signalNewOwner(address _proposedOwner)` should only be callable by a guardian. It should set some variables within the contract so that other guardians can call the same function to increase the amount of votes. When all the guardians have signaled their support then this method should automatically set the new owner to the proposed owner. Emit this event when a guardian signals `NewOwnerSignaled(address by, address proposedOwner)` and emit this event when the new owner has been set: `RecoveryExecuted(address newOwner)`.
 - `addGuardian(address _guardian)` should only be allowed to be called by the owner and should add a new guardian to the contract. If the address is already a guardian then revert.
 - `removeGuardian(address _guardian)` should only be allowed to be called by the owner and should remove an existing guardian, reverting if they don't exist.

 Also add view methods, variables or a mapping that allows the following to be queried:

 - `owner()` should return the owner address.
 - `isGuardian(address)` should return a bool that is true if the given address is a guardian, false if not.

@@BOTTOM_CONTENT@@