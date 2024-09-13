//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/SocialRecoveryWallet.sol";
import "./DeployHelpers.s.sol";

contract DeployContracts is ScaffoldETHDeploy {
  function run() external ScaffoldEthDeployerRunner {
    address[] memory chosenGuardianList;
    SocialRecoveryWallet socialRecoveryWallet = new SocialRecoveryWallet(chosenGuardianList, 2);
    console.logString(
        string.concat(
            "SocialRecoveryWallet deployed at: ",
            vm.toString(address(socialRecoveryWallet))
        )
    );
  }
}