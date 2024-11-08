//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./DeployHelpers.s.sol";
import { DeployContract } from "./00_deploy_contract.s.sol";

contract DeployScript is ScaffoldETHDeploy {
  function run() external {
    DeployContract deployContract = new DeployContract();
    deployContract.run();
  }
}
