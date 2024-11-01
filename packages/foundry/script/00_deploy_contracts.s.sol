//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/RebasingERC20.sol";
import "./DeployHelpers.s.sol";

contract DeployContracts is ScaffoldETHDeploy {
  function run() external ScaffoldEthDeployerRunner {
    RebasingERC20 rebasingERC20 = new RebasingERC20(10_000_000e18);
        console.logString(
            string.concat(
                "RebasingERC20 deployed at: ",
                vm.toString(address(rebasingERC20))
            )
        );
  }
}