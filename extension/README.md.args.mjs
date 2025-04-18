export const extraContents = `# Wrapped Token Challenge - ETH Tech Tree

## Challenge Description
This challenge will require you to write an [ERC20](https://eips.ethereum.org/EIPS/eip-20) compliant token wrapper for ETH. Your task starts in \`packages/foundry/contracts/WrappedETH.sol\`. Use your Solidity skills to make this smart contract receive ETH and give the depositor an equal amount of WETH, an ERC20 version of native ETH. It should also handle a user reclaiming their ETH for their WETH.  An ERC20 form of ETH is useful because DeFi protocols don't have to worry about integrating special functions for handling native ETH, instead they can just write methods that handle any ERC20 token. 

### Step 1
Write a contract called \`WrappedETH\` and make it a standard ERC20 implementation with all the methods and events.
Here is a helpful reference: [Original Ethereum Improvement Proposal for the ERC-20 token standard](https://eips.ethereum.org/EIPS/eip-20).

---
<details markdown='1'>
<summary>🔎 Hint</summary>
If you have never implemented your own ERC20 token then this is a great opportunity to dig into a plethora of documents on the subject. If that is old hat to you then you can always import the OpenZeppelin ERC20 contract and implement it in your contract.

\`\`\`solidity
  import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

  contract WrappedETH is ERC20("WrappedEth", "WETH") {
    ...
  }
\`\`\`

</details>

---
### Step 2
Then add two additional methods:
1. A \`deposit()\` method should receive ETH and update the senders token balance to include their deposit. It should emit a \`Deposit(address depositor, uint amount)\` event that records the depositor address and the amount deposited.
2. A \`withdraw(uint amount)\` method that exchanges the users token balance for ETH. It should emit a \`Withdrawal(address withdrawer, uint amount)\` event that records the sender and the amount they withdrew.

Check your logic to make sure nobody can withdraw more than the tokens they have allocated.

What happens when someone YOLOs ETH to your contract without targeting the \`deposit\` method? See if you can handle that elegantly.

---
<details markdown='1'>
<summary>🔎 Hint</summary>
Make sure you have the <a href="https://solidity-by-example.org/fallback/">\`fallback\` and \`receive\` default handling methods</a> set up to automatically assume the \`deposit\` method has been called.
</details>

---

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