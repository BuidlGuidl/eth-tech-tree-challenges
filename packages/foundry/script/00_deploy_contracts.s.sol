//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/DecentralizedResistanceToken.sol";
import "../contracts/Governance.sol";
import "./DeployHelpers.s.sol";

contract DeployContracts is ScaffoldETHDeploy {
  function run() external ScaffoldEthDeployerRunner {
      uint256 votingPeriod = 86400; // 1 day in seconds
      DecentralizedResistanceToken voteToken = new DecentralizedResistanceToken(1000000 * 10**18); // 1,000,000 tokens
      Governance challenge = new Governance(address(voteToken), votingPeriod);
      console.logString(
          string.concat(
              "Challenge deployed at: ",
              vm.toString(address(challenge))
          )
      );
  }
}