//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/Challenge.sol";
import "./DeployHelpers.s.sol";

contract DeployContract is ScaffoldETHDeploy {
  function run() external ScaffoldEthDeployerRunner {
    Contract yourContract = new Contract();
    console.logString(
      string.concat(
        "Contract deployed at: ", vm.toString(address(yourContract))
      )
    );
  }
}
