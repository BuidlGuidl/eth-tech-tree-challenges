//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {TokenStreaming} from "../contracts/TokenStreaming.sol";
import "./DeployHelpers.s.sol";

contract DeployContract is ScaffoldETHDeploy {
  function run() external ScaffoldEthDeployerRunner {
    TokenStreaming yourContract = new TokenStreaming();
    console.logString(
      string.concat(
        "Contract deployed at: ", vm.toString(address(yourContract))
      )
    );
  }
}
