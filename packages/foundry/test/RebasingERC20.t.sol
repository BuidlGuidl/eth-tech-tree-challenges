// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "../contracts/RebasingERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

/**
 * @title Rebasing Token Challenge Auto-Grading Tests
 * @author BUIDL GUIDL
 * @notice These tests will be used to autograde the challenge within the tech tree. This test file is PURELY EDUCATIONAL, and is not to be used in production code. It is up to the user's discretion to make their own production code, run tests, have audits, etc.
 */
contract RebasingERC20Test is Test {
    RebasingERC20 token;
    // King of the Pirates
    address luffy;
    // World's Greatest Swordsman
    address zoro;
    uint256 luffyBalance1;
    uint256 zoroBalance1;
    uint256 initialBalance;


    /**
     * Total Supply is set up to be 10 million RBT
     * Luffy initial balance is 10 million RBT
     * Luffy transfers 1000 RBT to zoro
     * Records initial balances for Luffy and Zoro after setup
     */
    function setUp() public {
        luffy = address(this);
        zoro = address(0x123);
        initialBalance = 10_000_000e18;
        // Use a different contract than default if CONTRACT_PATH env var is set
        string memory contractPath = vm.envOr("CONTRACT_PATH", string("none"));
        if (keccak256(abi.encodePacked(contractPath)) != keccak256(abi.encodePacked("none"))) {
            bytes memory args = abi.encode(initialBalance);
            bytes memory bytecode = abi.encodePacked(vm.getCode(contractPath), args);
            address payable deployed;
            assembly {
                deployed := create(0, add(bytecode, 0x20), mload(bytecode))
            }
            token = RebasingERC20(deployed);
        } else {
            token = new RebasingERC20(initialBalance);
        }
        token.transfer(zoro, 1000 * 10 ** token.decimals());
        luffyBalance1 = token.balanceOf(luffy);
        zoroBalance1 = token.balanceOf(zoro);
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), initialBalance);
        assertEq(token.balanceOf(luffy), 9999000 * 10 ** token.decimals());
        assertEq(token.balanceOf(zoro), 1000 * 10 ** token.decimals());
    }

    function testTransfer(uint256 transferAmount) public {
        transferAmount = bound(transferAmount, 1e18, 10000e18);
        token.transfer(zoro, transferAmount);
        assertEq(token.balanceOf(luffy), luffyBalance1 - transferAmount);
        assertEq(token.balanceOf(zoro), zoroBalance1 + transferAmount);
    }

    function testApproveAndTransferFrom() public {
        uint256 approveAmount = 500 * 10 ** token.decimals();
        uint256 transferAmount = 300 * 10 ** token.decimals();
        token.approve(zoro, approveAmount);
        assertEq(token.allowance(luffy, zoro), approveAmount);

        // Simulate `transferFrom` by zoro
        vm.prank(zoro);
        token.transferFrom(luffy, zoro, transferAmount);
        assertEq(token.balanceOf(luffy), luffyBalance1 - transferAmount);
        assertEq(token.balanceOf(zoro), zoroBalance1 + transferAmount);
        assertEq(token.allowance(luffy, zoro), approveAmount - transferAmount);
    }

    function testTransferFromAllTokens() public {
        uint256 approveAmount = token.balanceOf(zoro);
        vm.prank(zoro);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Approval(zoro, luffy, approveAmount);
        token.approve(luffy, approveAmount);
        assertEq(token.allowedRBT(zoro, luffy), approveAmount);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(zoro, luffy, approveAmount);
        token.transferFrom(zoro, luffy, approveAmount);
        assertEq(token.balanceOf(zoro), 0);
        assertEq(token.balanceOf(luffy), luffyBalance1 + zoroBalance1);
    }

    function testTransferAllTokens() public {
        uint256 approveAmount = token.balanceOf(zoro);
        vm.startPrank(zoro);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(zoro, luffy, approveAmount);
        token.transfer(luffy, approveAmount);
        assertEq(token.balanceOf(zoro), 0);
        assertEq(token.balanceOf(luffy), luffyBalance1 + zoroBalance1);
    }
    
    function testRebasePositive() public {
        int256 supplyDelta = 10_000_000e18;
        uint256 absSupplyDelta = abs(supplyDelta);
        uint256 oldTotalSupply = token.totalSupply();
        uint256 expectedTotalSupply =  oldTotalSupply + absSupplyDelta;
        vm.expectEmit(true, false, false, true);
        emit RebasingERC20.Rebase(expectedTotalSupply);
        token.rebase(supplyDelta);
        uint256 newTotalSupply = token.totalSupply();

        assertEq(newTotalSupply, oldTotalSupply + absSupplyDelta);
        assertEq(token.balanceOf(luffy), luffyBalance1 * (newTotalSupply) / oldTotalSupply);
        assertEq(token.balanceOf(zoro), (zoroBalance1 * newTotalSupply) / oldTotalSupply);
    }

    function testRebaseNegative() public {
        int256 supplyDelta = -9_000_000e18;
        uint256 absSupplyDelta = abs(supplyDelta);
        uint256 oldTotalSupply = token.totalSupply();
        uint256 expectedTotalSupply =  oldTotalSupply - absSupplyDelta;
        vm.expectEmit(true, false, false, true);
        emit RebasingERC20.Rebase(expectedTotalSupply);
        token.rebase(supplyDelta);
        uint256 newTotalSupply = token.totalSupply();

        assertEq(newTotalSupply, oldTotalSupply - absSupplyDelta);
        assertEq(token.balanceOf(luffy), luffyBalance1 * (newTotalSupply) / oldTotalSupply);
        assertEq(token.balanceOf(zoro), (zoroBalance1 * newTotalSupply) / oldTotalSupply);
    }

    function testAllowanceUnchangedAfterRebase() public {
        int256 supplyDelta = -9_000_000e18;
        uint256 zoroBalance = token.balanceOf(zoro);
        vm.prank(zoro);
        // Zoro allows Luffy to spend all of his tokens
        token.approve(luffy, zoroBalance);
        // Rebase occurs making Zoro's balance 10% of the original
        token.rebase(supplyDelta);
        // Luffy's allowance should remain the same
        assertEq(token.allowance(zoro, luffy), zoroBalance);
    }
    
    /**
     * Rebase
     * Transfer
     * Check balanceOf is updated properly
     */
    function testTransferAfterRebase(uint256 transferAmount) public {
        transferAmount = bound(transferAmount, 1e18, 10000e18);
        int256 supplyDelta = -9_000_000e18;
        uint luffyBalanceBefore1 = token.balanceOf(luffy);
        uint zoroBalanceBefore = token.balanceOf(zoro);
        token.transfer(zoro, transferAmount);
        uint luffyBalanceAfter1 = token.balanceOf(luffy);
        uint zoroBalanceAfter = token.balanceOf(zoro);
        assertEq(luffyBalanceAfter1, luffyBalanceBefore1 - transferAmount);
        assertEq(zoroBalanceAfter, zoroBalanceBefore + transferAmount);

        token.rebase(supplyDelta);

        uint luffyBalanceBefore2 = token.balanceOf(luffy);
        uint zoroBalanceBefore2 = token.balanceOf(zoro);
        token.transfer(zoro, transferAmount);
        uint luffyBalanceAfter2 = token.balanceOf(luffy);
        uint zoroBalanceAfter2 = token.balanceOf(zoro);
        assertEq(luffyBalanceAfter2, luffyBalanceBefore2 - transferAmount);
        assertEq(zoroBalanceAfter2, zoroBalanceBefore2 + transferAmount);
    }

    function testTransferFromAfterRebase(uint256 transferAmount) public {
        transferAmount = bound(transferAmount, 1e18, 10000e18);
        int256 supplyDelta = -9_000_000e18;
        uint luffyBalanceBefore1 = token.balanceOf(luffy);
        uint zoroBalanceBefore = token.balanceOf(zoro);
        token.transfer(zoro, transferAmount);
        uint luffyBalanceAfter1 = token.balanceOf(luffy);
        uint zoroBalanceAfter = token.balanceOf(zoro);
        assertEq(luffyBalanceAfter1, luffyBalanceBefore1 - transferAmount);
        assertEq(zoroBalanceAfter, zoroBalanceBefore + transferAmount);

        token.rebase(supplyDelta);

        uint luffyBalanceBefore2 = token.balanceOf(luffy);
        uint zoroBalanceBefore2 = token.balanceOf(zoro);
        uint256 approveAmount = 10000e18;
        token.approve(zoro, approveAmount);
        assertEq(token.allowance(luffy, zoro), approveAmount);
        vm.prank(zoro);
        token.transferFrom(luffy, zoro, transferAmount);
        
        assertEq(token.balanceOf(luffy), luffyBalanceBefore2 - transferAmount);
        assertEq(token.balanceOf(zoro), zoroBalanceBefore2 + transferAmount);
    }

    function testFailTransferInsufficientBalance() public {
        // User tries to transfer more tokens than they have
        vm.prank(zoro);
        vm.expectRevert();
        token.transfer(luffy, 2000 * 10 ** token.decimals());
    }

    function testRebaseNotOwner() public {
        // Non-owner tries to rebase the contract
        vm.prank(zoro);
        vm.expectRevert();
        token.rebase(1000);
    }

    /// Helper Functions

    function abs(int256 value) public pure returns (uint256) {
        // Check if the value is negative
        if (value < 0) {
            // Return the negated value as unsigned integer
            return uint256(-value);
        } else {
            // Return the value as unsigned integer
            return uint256(value);
        }
    }

    
}