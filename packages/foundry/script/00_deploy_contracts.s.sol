//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/EthStreaming.sol";
import "./DeployHelpers.s.sol";

contract DeployContracts is ScaffoldETHDeploy {
  function run() external ScaffoldEthDeployerRunner {
     EthStreaming ethStreaming = new EthStreaming(2592000);
        console.logString(
            string.concat(
                "Challenge deployed at: ",
                vm.toString(address(ethStreaming))
            )
        );
  }
}