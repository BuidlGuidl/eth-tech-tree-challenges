//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/Multisend.sol";
import "../contracts/MockToken.sol";
import "./DeployHelpers.s.sol";

contract DeployContracts is ScaffoldETHDeploy {
  function run() external ScaffoldEthDeployerRunner {
     (address mockToken1, address mockToken2) = deployMockTokens();

        Multisend multisend = new Multisend();
        console.logString(
            string.concat(
                "Multisend Challenge deployed at: ",
                vm.toString(address(multisend))
            )
        );
  }

    /**
    * @notice Creates mock tokens for the pool and mints 1000 of each to the deployer wallet
    */
    function deployMockTokens() internal returns (address, address) {
        MockToken scUSD = new MockToken("Scaffold USD", "scUSD");
        MockToken scDAI = new MockToken("Scaffold DAI", "scDAI");
        console.logString(
            string.concat(
                "Deployed mock tokens to:",
                vm.toString(address(scUSD)),
                " and ",
                vm.toString(address(scDAI))
            )
        );
        return (address(scDAI), address(scUSD));
    }
}