//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/WrappedETH.sol";
import "./DeployHelpers.s.sol";

contract DeployWrappedETH is ScaffoldETHDeploy {
  function run() external ScaffoldEthDeployerRunner {
    WrappedETH yourContract = new WrappedETH();
    console.logString(
      string.concat(
        "WrappedETH deployed at: ", vm.toString(address(yourContract))
      )
    );
  }
}
