export const extraContents = `# Rebasing Token - ETH Tech Tree

Rebasing tokens have become a fascinating aspect of the web3 space, appearing frequently in projects involving DeFi, algorithmic stablecoins, and more. These tokens adjust their supply automatically, based on specific rules, which can create unique opportunities and challenges within the ecosystem. 

---
<details markdown='1'><summary>👩🏽‍🏫 Fun question: what is an ERC20 that can be easily mistaken as a rebasing token? </summary>
Answer: An example of a token that exhibits traits that rhyme with rebasing, but is not rebasing, is stETH. stETH does not change its supply, instead its price increases as staking rewards accumulate. 
</details>  

---

Understanding how to create a rebasing token can offer valuable insights into more complex smart contract interactions and state management on the blockchain. 🧑‍💻

In this challenge, we will guide you through the process of constructing a rebasing token using Solidity. By the end of this challenge, you will have a deeper understanding of the mechanisms behind rebasing and how to implement them in your own smart contracts.

## Challenge Description

This challenge requires you to implement an ERC20 contract with rebasing token logic.

Rebasing tokens automatically adjust its supply typically based on some external reason, for example: to target a specific price. As the token supply is increased or decreased periodically, the effects are applied to all token holders, proportionally. Rebasing can be used as an alternative price stabilization method versus traditional market mechanisms.

An example of a rebasing token is the Ampleforth token, AMPL.

AMPL uses old contracts called \`UFragments.sol\`, where \`Fragments\` are the ERC20 and the underlying value of them are denominated in \`GONS\`. Balances of users, transference of tokens, are all calculated using \`GONs\` via a mapping and a var called \`_gonsPerFragment\`. This var changes and thus changes the balance of the Fragments token for a user since the \`balanceOf()\` function equates to \`_gonBalances[who].div(_gonsPerFragment)\`. 

> For reference, this can be seen [here](https://etherscan.deth.net/address/0xD46bA6D942050d489DBd938a2C909A5d5039A161).

**Now that you understand the context of rebasing tokens, create a contract named \`RebasingERC20\` that defines one named \`Rebasing Token\`, with the symbol \`$RBT\`, with the following parameters:**

1. Inherits all ERC20 methods, events and errors.
2. The contract has an owner.
3. Constructor will receive the total supply as a parameter and it will be allocated to the owner.
4. There is a method called \`rebase\` that accepts an \`int256\` that determines the amount to rebase, plus or minus. It should only be allowed to be called by the contract owner. When called, emit an event called \`Rebase(uint256 totalSupply)\` with the new total supply of tokens.

**Assumptions:**

- User balances should change after a rebase.
- The rebase mechanism should update the total supply by whatever number it is supplied.
- As an example, if the total token supply is 10 million and it is rebased with negative 9 million (\`rebase(-9000000)\`) then the total supply is only 1 million and each holder holds 1/10th the amount they held prior to the rebase. A balance of 1000 would become 100. This should work when given a positive number as well. \`rebase(9000000)\` would return the total supply and user balances to what they were prior to the first rebase. 
- Don't change token allowances when rebases occur.
- For the sake of simplicity and to avoid rounding errors you can assume that the rebase method will only be called with large numbers that are wholly divisible by 10e6.

---
<details markdown='1'>
<summary>🔎 Hint</summary>
You will need to either inherit an OpenZeppelin ERC20 implementation and override several of methods or just implement your own ERC20 implementation from scratch.
<details markdown='1'>
<summary>Another hint please?!</summary>
The balances returned by \`balanceOf(address)\` will need to be different from the actual internal balances. You may find it helpful to assign the totalSupply constructor parameter to a variable so you can reference it later when determining how much the supply has changed through rebasing.
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

## Testing Your Progress
Use your skills to build out the above requirements in whatever way you choose. You are encouraged to run tests periodically to visualize your progress.

Run tests using \`yarn foundry:test\` to run a set of tests against the contract code. Initially you will see build errors but as you complete the requirements you will start to pass tests. If you struggle to understand why some tests are returning errors then you might find it useful to run the command with the extra logging verbosity flag \`-vvvv\` (\`yarn foundry:test -vvvv\`) as this will show you very detailed information about where tests are failing. Learn how to read the traces [here](https://book.getfoundry.sh/forge/traces). You can also use the \`--match-test "TestName"\` flag to only run a single test. Of course you can chain both to include a higher verbosity and only run a specific test by including both flags \`yarn foundry:test -vvvv --match-test "TestName"\`. You will also see we have included an import of \`console2.sol\` which allows you to use \`console.log()\` type functionality inside your contracts to know what a value is at a specific time of execution. You can read more about how to use that at [FoundryBook](https://book.getfoundry.sh/reference/forge-std/console-log).

For a more "hands on" approach you can try testing your contract with the provided front end interface by running the following:
\`\`\`bash
  yarn chain
\`\`\`
in a second terminal deploy your contract:
\`\`\`bash
  yarn deploy
\`\`\`
in a third terminal start the NextJS front end:
\`\`\`bash
  yarn start
\`\`\`

## Solved! (Final Steps)
Once you have a working solution and all the tests are passing your next move is to deploy your lovely contract to the Sepolia testnet.

### Setting up your wallet (if you haven't already)
First you will need to generate an account. **You can skip this step if you have already created a keystore on your machine. Keystores are located in \`~/.foundry/keystores\`**
\`\`\`bash
  yarn generate
\`\`\`
You can optionally give your new account a name be passing it in like so: \`yarn generate NAME-FOR-ACCOUNT\`. The default is \`scaffold-eth-custom\`.

You will be prompted for a password to encrypt your newly created keystore. Make sure you choose a [good one](https://xkcd.com/936/) if you intend to use your new account for more than testnet funds.

Now you need to update \`packages/foundry/.env\` so that \`ETH_KEYSTORE_ACCOUNT\` = your new account name ("scaffold-eth-custom" if you didn't specify otherwise).

Now you are ready to send some testnet funds to your new account.
Run the following to view your new address and balances across several networks.
\`\`\`bash
  yarn account
\`\`\`
To fund your account with Sepolia ETH simply search for "Sepolia testnet faucet" on Google or ask around in onchain developer groups who are usually more than willing to share. Send the funds to your wallet address and run \`yarn account\` again to verify the funds show in your Sepolia balance.

### Deploying your contract
Once you have confirmed your balance on Sepolia you can run this command to deploy your contract.
\`\`\`bash
  yarn deploy --network sepolia
\`\`\`
Now you need to verify it on Sepolia Etherscan.
\`\`\`bash
  yarn verify --network sepolia
\`\`\`
Copy your deployed contract address from your console and paste it in at [sepolia.etherscan.io](https://sepolia.etherscan.io). You should see a green checkmark on the "Contract" tab showing that the source code has been verified.

Now you can return to the ETH Tech Tree CLI, navigate to this challenge in the tree and submit your deployed contract address. Congratulations!
`;

export const skipQuickStart = true;