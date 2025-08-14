export const extraContents = `# ETH Streaming Challenge - ETH Tech Tree

In a world where asset allocation mechanisms have grown stale, a visionary group of technologists known as **_The StreamWeavers_** emerges. Their mission is to pioneer novel means of distributing capital that incentivize creativity and coordination. As a core developer for **_The StreamWeavers_**, you are tasked with forging the smart contracts that will allow this new system to flourish and ensure that everyone can manage their digital assets freely.

## Challenge Description

Amidst a backdrop where centralized control over capital resources stifles innovation and freedom, your challenge is to write a smart contract named "EthStreaming". This contract will empower authorized users to manage Ethereum assets in a decentralized manner, ensuring that the flow of resources is as continuous and uninterrupted as the ideals we uphold. Designated accounts will be permitted to withdraw predefined amounts of ETH, dictated by the passage of time since their last withdrawal.

As the architect, you will start this endeavor in \`packages/foundry/contracts/EthStreaming.sol\` where you will craft a new paradigm where freedom and resources flow hand in hand.

### Step 1
Write a contract called "EthStreaming" that receives a uint parameter in the constructor representing the time in seconds that it takes for a stream to be fully unlocked. Define an immutable state variable and set its value with the given uint parameter in the constructor.

---
<details markdown='1'>
<summary>🔎 Hint</summary>
You will need to define the contract and expect to receive a uint parameter in the constructor:

\`\`\`solidity
  contract EthStreaming {
    uint public immutable unlockTime;

    constructor(uint _unlockTime) {
        // Setting the state variable to the value received in the constructor
        unlockTime = _unlockTime;
    }
  }
\`\`\`

</details>

---

### Step 2
This contract will need to have access controls so that only the owner can add and update streams, or else anyone could maliciously give themselves a stream and drain the funds! The owner should be set to the deployer address at the moment of contract deployment. Think through how you want to handle that.

---
<details markdown='1'>
<summary>🔎 Hint</summary>
Two paths that could work for this:

1. Import the OpenZeppelin Ownable contract and inherit it in your contract definition

   or...

2. Simply store the deployer address (\`msg.sender\`) in a new state variable inside the constructor

</details>

---

### Step 3
Anyone should be able to fund the contract with ETH just by sending a transaction with value to the contract address.

---
<details markdown='1'>
<summary>🔎 Hint</summary>
Look at the <a href="https://solidity-by-example.org/fallback/"> \`receive\` handling method</a> that enables a contract to be able to receive ETH.
</details>

---

### Step 4
Create an \`addStream\` method that receives an address and a uint parameter representing the stream recipient and the amount of ETH that is the maximum amount their stream can unlock. Only the owner should be allowed to use this method. They should be able to call it to update recipients unlock amounts in the future in case they want to increase/decrease a stream. Think about how you should store this data so that later you can check
1. if an address has a stream
2. the maximum amount the address can withdraw 
3. how much the address has unlocked if the time to completely fill hasn't elapsed since the last time they withdrew funds

Go ahead and add a new event called \`AddStream(address recipient, uint cap)\`. Emit that event once the stream is added.

---
<details markdown='1'>
<summary>🔎 Hint</summary>
You could create a struct that stores the cap and the last withdraw timestamp and then create a mapping that uses the recipient address to point to an instance of the struct. 

\`\`\`solidity
  struct Stream {
      uint cap;
      uint timeOfLastWithdrawal;
  }

  mapping(address => Stream) public streams;
  
\`\`\`

<details markdown='1'>
<summary>OK, but I am still stuck on how to save the recipient data...</summary>
Simply assign an instance of the struct to that recipient's location in the mapping.

\`\`\`solidity
  streams[recipient] = Stream(cap, 0);
\`\`\`
</details>
</details>

---


### Step 5
Add a \`withdraw\` method that accepts a uint that represents the amount the stream recipient wishes to withdraw.

A stream should be fully unlocked at the time of creation so a recipient should be able to withdraw the full amount.

Assuming their stream is now empty, they should not be able to withdraw anything from it until sufficient time has passed. For instance, if the full unlock time has passed they should be able to withdraw their full stream cap again. 

If only some of the time has passed then they should be able to withdraw the a fraction of their total cap proportional to the amount of time that has elapsed. 

If a user has a fully unlocked stream and they only withdraw a portion, they should be able to withdraw the remaining portion without waiting any time.

Make sure the method reverts in the following cases:
- if the contract doesn't have enough funds to satisfy the amount entered
- if the caller doesn't have a stream
- if the caller is requesting an amount greater than the amount they have unlocked

Once all the logic has finished emit an event called \`Withdraw(address recipient, uint amount)\` so that the owner can monitor withdrawals.

---
<details markdown='1'>
<summary>🔎 Hint</summary>
Try to figure out how much the builder has unlocked by multiplying the time elapsed since their last withdraw by the stream cap, then divide by the unlock time. Don't forget to make sure that you don't allow them to take more than their cap.
<details markdown='1'>
<summary>OK, I got that but something is still not working...</summary>
You will also need to take care when recording their last withdraw time. It is not as simple as setting it to the current block.timestamp 100% of the time. What if they are only withdrawing half of their stream?
</details>
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
