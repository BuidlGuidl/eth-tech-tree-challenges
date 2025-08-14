export const extraContents = `# Multisend Challenge - ETH Tech Tree 

ETH and token transference are used all the time within the web3 space. Anyone can see it when they follow txs with NFTs, DeFi, RWAs, gaming, and more. As we can see in other challenges, this ability to have transparent, immutable transference of value is one aspect that makes blockchain technology so powerful. Therefore it is important to understand how to construct these types of transactions, at their most basic levels. 👨🏻‍🏫

Native assets to a blockchain, such as ETH for Ethereum, and ERC20 tokens follow different sequences when being transferred. This tutorial will challenge you as the student to understand one example of carrying out these basic transactions.

## Challenge Description

This challenge will require you to build a contract that is capable of sending tokens or ETH to multiple provided addresses. Transference of tokens and ETH are basics that you must understand in smart contract development.

Your task starts in \`packages/foundry/contracts/Multisend.sol\`.

Create a contract called \`Multisend\` and define two methods:
1. \`sendETH\` which takes an array of payable addresses that represents the recipients and an array of uint amounts representing the amount to send to each address in the array of recipients. Both of the arrays should have equal lengths. Use the arrays to send the correct amount to each recipient. Emit an event called \`SuccessfulETHTransfer(address _sender, address payable[] _receivers, uint256[]  _amounts)\`. You should revert if any transfer is unsuccessful.
---
<details markdown='1'><summary>🔎 Hint</summary>
The function signature should look like this:

\`\`\`
sendETH(address payable[], uint256[])
\`\`\`
</details>  

---
2. \`sendTokens\` which takes an array of payable addresses that represents the recipients and an array of uint amounts representing the amount to send to each address in the array of recipients. Both of the arrays should have equal lengths. Use the arrays to send the correct amount of tokens to each recipient. Emit an event called \`SuccessfulTokenTransfer(address indexed _sender, address[] indexed _receivers, uint256[] _amounts, address _token)\`. You should revert if any transfer is unsuccessful.
---
<details markdown='1'><summary>🔎 Hint</summary>
The function signature should look like this:

\`\`\`
sendTokens(address[], uint256[], address)
\`\`\`
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
Once you have a working solution and all the tests are passing your next move is to deploy your lovely contract to a supported testnet. See the list of [supported testnets](https://github.com/BuidlGuidl/eth-tech-tree-backend/blob/12799cc95950ee3bd8d523b8d2d2e2f05f131268/packages/server/utils/config.ts#L21).

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
To fund your account on your chosen testnet (e.g., Sepolia), search for a testnet faucet or ask around in onchain developer groups who are usually more than willing to share. Send the funds to your wallet address and run \`yarn account\` again to verify the funds show in your balance on that network.

### Deploying your contract
Sepolia is used below as an example. The ETH Tech Tree supports multiple testnets; see the list of [supported testnets](https://github.com/BuidlGuidl/eth-tech-tree-backend/blob/12799cc95950ee3bd8d523b8d2d2e2f05f131268/packages/server/utils/config.ts#L21). Replace \`sepolia\` with your chosen supported network in the commands.

Once you have confirmed your balance on your chosen network you can run this command to deploy your contract.
\`\`\`bash
  yarn deploy --network sepolia
\`\`\`
Now you need to verify it on the Sepolia Etherscan (or the explorer for your chosen network).
\`\`\`bash
  yarn verify --network sepolia
\`\`\`
Copy your deployed contract address from your console and paste it in at a block explorer for your chosen network. You should see a green checkmark on the "Contract" tab showing that the source code has been verified.

Now you can return to the ETH Tech Tree CLI, navigate to this challenge in the tree and submit your deployed contract address. Congratulations!
`;

export const skipQuickStart = true;
