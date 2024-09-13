# Wrapped Token Challenge - ETH Tech Tree
*This challenge is meant to be used in the context of the [ETH Tech Tree](https://github.com/BuidlGuidl/eth-tech-tree).*

@@TOP_CONTENT@@

## Challenge Description
This challenge will require you to write an [ERC20](https://eips.ethereum.org/EIPS/eip-20) compliant token wrapper for ETH. An ERC20 form of ETH is useful because DeFi protocols don't have to worry about integrating special functions for handling native ETH, instead they can just write methods that handle any ERC20 token.

Your task starts in `packages/foundry/contracts/WrappedETH.sol`. Use your solidity skills to make this smart contract receive ETH and give the depositor an equal amount of WETH, an ERC20 version of native ETH. The contract already has all the necessary methods to be ERC20 compliant, you will just have to fill in the details on what each method should do. Here is a helpful reference:

- [Original Ethereum Improvement Proposal for the ERC-20 token standard](https://eips.ethereum.org/EIPS/eip-20)

@@BOTTOM_CONTENT@@