//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/DecentralizedResistanceToken.sol";
import "../contracts/Voting.sol";
import "./DeployHelpers.s.sol";

contract DeployContracts is ScaffoldETHDeploy {
  function run() external ScaffoldEthDeployerRunner {
    DecentralizedResistanceToken drt = new DecentralizedResistanceToken(1000000 * 10**18); // 1,000,000 tokens
    console.logString(
      string.concat(
        "DecentralizedResistanceToken deployed at: ", vm.toString(address(drt))
      )
    );

    Voting challenge = new Voting(address(drt), 86400);

    drt.setVotingContract(address(challenge));
    console.logString(
      string.concat(
        "Voting deployed at: ", vm.toString(address(challenge))
      )
    );
  }
}
