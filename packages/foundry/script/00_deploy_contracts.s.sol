//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/DeadMansSwitch.sol";
import "./DeployHelpers.s.sol";

contract DeployContracts is ScaffoldETHDeploy {
  function run() external ScaffoldEthDeployerRunner {
     DeadMansSwitch deadMansSwitch = new DeadMansSwitch();
        console.logString(
            string.concat(
                "DeadMansSwitch deployed at: ",
                vm.toString(address(deadMansSwitch))
            )
        );
  }
}