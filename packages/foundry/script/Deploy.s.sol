//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/WrappedETH.sol";
import "./DeployHelpers.s.sol";
import { DeployWrappedETH } from "./00_deploy_wrapped_eth.s.sol";

contract DeployScript is ScaffoldETHDeploy {
  function run() external {
    DeployWrappedETH deployWrappedETH = new DeployWrappedETH();
    deployWrappedETH.run();
  }
}
