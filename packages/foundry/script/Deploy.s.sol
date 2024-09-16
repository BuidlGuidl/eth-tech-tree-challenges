//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./DeployHelpers.s.sol";
import { DeployContracts } from "./00_deploy_contracts.s.sol";

contract DeployScript is ScaffoldETHDeploy {
  function run() external {
    DeployContracts deployContracts = new DeployContracts();
    deployContracts.run();
  }
}
