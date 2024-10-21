// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../contracts/WrappedETH.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WrappedETHTest is Test {
    WrappedETH public wrappedETH;
    address THIS_CONTRACT = address(this);
    address NON_CONTRACT_USER = vm.addr(1);

    function setUp() public {
        // Use a different contract than default if CONTRACT_PATH env var is set
        string memory contractPath = vm.envOr("CONTRACT_PATH", string("none"));
        if (keccak256(abi.encodePacked(contractPath)) != keccak256(abi.encodePacked("none"))) {
            bytes memory bytecode = vm.getCode(contractPath);
            address payable deployed;
            assembly {
                deployed := create(0, add(bytecode, 0x20), mload(bytecode))
            }
            wrappedETH = WrappedETH(deployed);
        } else {
            wrappedETH = new WrappedETH();
        }
    }

    function testDeposit() public {
        wrappedETH.deposit{value: 1 ether}();
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 1 ether);
    }

    function testFallback() public {
        address(wrappedETH).call{value: 1 ether}("");
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 1 ether);
    }

    function testWithdraw() public {
        vm.startPrank(NON_CONTRACT_USER);
        vm.deal(NON_CONTRACT_USER, 1 ether);
        wrappedETH.deposit{value: 1 ether}();
        wrappedETH.withdraw(1 ether);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 0);
        assertEq(address(wrappedETH).balance, 0);
        assertEq(NON_CONTRACT_USER.balance, 1 ether);
    }

    function testWithdrawInsufficientBalance() public {
        vm.startPrank(NON_CONTRACT_USER);
        vm.deal(NON_CONTRACT_USER, 1 ether);
        wrappedETH.deposit{value: 1 ether}();
        vm.expectRevert();
        wrappedETH.withdraw(1 ether + 1);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 1 ether);
        assertEq(address(wrappedETH).balance, 1 ether);
        assertEq(NON_CONTRACT_USER.balance, 0);
    }

    function testWithdrawFailedToSendEther() public {
        address CONTRACT_NOT_PAYABLE = vm.addr(3);
        vm.etch(CONTRACT_NOT_PAYABLE, "By adding any arbitrary bytecode to the address, it will no longer be payable");
        vm.startPrank(CONTRACT_NOT_PAYABLE);
        vm.deal(CONTRACT_NOT_PAYABLE, 1 ether);
        wrappedETH.deposit{value: 1 ether}();
        vm.expectRevert();
        wrappedETH.withdraw(1 ether);
        assertEq(wrappedETH.balanceOf(CONTRACT_NOT_PAYABLE), 1 ether);
        assertEq(address(wrappedETH).balance, 1 ether);
        assertEq(CONTRACT_NOT_PAYABLE.balance, 0);
    }

    function testTotalSupply() public {
        wrappedETH.deposit{value: 1 ether}();
        assertEq(wrappedETH.totalSupply(), 1 ether);
    }

    function testApprove() public {
        wrappedETH.approve(NON_CONTRACT_USER, 1 ether);
        assertEq(wrappedETH.allowance(THIS_CONTRACT, NON_CONTRACT_USER), 1 ether);
    }

    function testTransfer() public {
        wrappedETH.deposit{value: 1 ether}();
        wrappedETH.transfer(NON_CONTRACT_USER, 1 ether);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 0);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 1 ether);
    }

    function testTransferWithInsufficientBalance() public {
        wrappedETH.deposit{value: 999}();
        vm.expectRevert();
        wrappedETH.transfer(NON_CONTRACT_USER, 1 ether);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 999);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 0);
    }

    function testTransferFrom() public {
        wrappedETH.deposit{value: 1 ether}();
        wrappedETH.approve(NON_CONTRACT_USER, 1 ether);
        vm.startPrank(NON_CONTRACT_USER);
        wrappedETH.transferFrom(THIS_CONTRACT, NON_CONTRACT_USER, 1 ether);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 0);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 1 ether);
    }

    function testTransferFromAllowanceIsAdjusted() public {
        wrappedETH.deposit{value: 1 ether}();
        wrappedETH.approve(NON_CONTRACT_USER, 1 ether);
        vm.startPrank(NON_CONTRACT_USER);
        wrappedETH.transferFrom(THIS_CONTRACT, NON_CONTRACT_USER, 1 ether);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 0);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 1 ether);
        assertEq(wrappedETH.allowance(THIS_CONTRACT, NON_CONTRACT_USER), 0);
    }

    function testTransferFromWithoutAllowance() public {
        wrappedETH.deposit{value: 1 ether}();
        vm.startPrank(NON_CONTRACT_USER);
        vm.expectRevert();
        wrappedETH.transferFrom(THIS_CONTRACT, NON_CONTRACT_USER, 1 ether);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 1 ether);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 0);
    }

    function testTransferFromWithInsufficientAllowance() public {
        wrappedETH.deposit{value: 1 ether}();
        wrappedETH.approve(NON_CONTRACT_USER, 500);
        vm.startPrank(NON_CONTRACT_USER);
        vm.expectRevert();
        wrappedETH.transferFrom(THIS_CONTRACT, NON_CONTRACT_USER, 1 ether);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 1 ether);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 0);
    }

    function testTransferFromWithInsufficientBalance() public {
        wrappedETH.deposit{value: 500}();
        wrappedETH.approve(NON_CONTRACT_USER, 1 ether);
        vm.startPrank(NON_CONTRACT_USER);
        vm.expectRevert();
        wrappedETH.transferFrom(THIS_CONTRACT, NON_CONTRACT_USER, 1 ether);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 500);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 0);
    }

    function testTransferFromWithMaxAllowance() public {
        wrappedETH.deposit{value: 1 ether}();
        wrappedETH.approve(NON_CONTRACT_USER, type(uint256).max);
        vm.startPrank(NON_CONTRACT_USER);
        wrappedETH.transferFrom(THIS_CONTRACT, NON_CONTRACT_USER, 1 ether);
        assertEq(wrappedETH.balanceOf(THIS_CONTRACT), 0);
        assertEq(wrappedETH.balanceOf(NON_CONTRACT_USER), 1 ether);
    }

    function testEmitDepositEvent() public {
        vm.expectEmit(address(wrappedETH));
        emit WrappedETH.Deposit(THIS_CONTRACT, 1 ether);
        wrappedETH.deposit{value: 1 ether}();
    }

    function testEmitWithdrawalEvent() public {
        vm.deal(NON_CONTRACT_USER, 1 ether);
        vm.startPrank(NON_CONTRACT_USER);
        wrappedETH.deposit{value: 1 ether}();
        vm.expectEmit(address(wrappedETH));
        emit WrappedETH.Withdrawal(NON_CONTRACT_USER, 1 ether);
        wrappedETH.withdraw(1 ether);
    }

    function testEmitTransferEvent() public {
        wrappedETH.deposit{value: 1 ether}();
        vm.expectEmit(address(wrappedETH));
        emit IERC20.Transfer(THIS_CONTRACT, NON_CONTRACT_USER, 1 ether);
        wrappedETH.transfer(NON_CONTRACT_USER, 1 ether);
    }

    function testEmitApprovalEvent() public {
        vm.expectEmit(address(wrappedETH));
        emit IERC20.Approval(THIS_CONTRACT, NON_CONTRACT_USER, 1 ether);
        wrappedETH.approve(NON_CONTRACT_USER, 1 ether);
    }

    function testEmitTransferEventOnTransferFrom() public {
        wrappedETH.deposit{value: 1 ether}();
        wrappedETH.approve(NON_CONTRACT_USER, 1 ether);
        vm.expectEmit(address(wrappedETH));
        emit IERC20.Transfer(THIS_CONTRACT, NON_CONTRACT_USER, 1 ether);
        vm.startPrank(NON_CONTRACT_USER);
        wrappedETH.transferFrom(THIS_CONTRACT,NON_CONTRACT_USER, 1 ether);
    }

    function testWithdrawIsReentrancySafe() public {
        // Whale deposits to the WrappedETH contract
        vm.deal(NON_CONTRACT_USER, 10 ether);
        vm.prank(NON_CONTRACT_USER);
        wrappedETH.deposit{value: 10 ether}();
        // Set up the exploit contract
        ReentrancyTest reentrancyTest = new ReentrancyTest();
        reentrancyTest.setUp{value: 1 ether}(address(wrappedETH));
        // Hopefully this reverts, otherwise the contract is vulnerable to reentrancy
        vm.expectRevert();
        reentrancyTest.exploitWithdraw();
    }
}

contract ReentrancyTest {
    WrappedETH public wrappedETH;
    function setUp(address wethContract) public payable {
        // Set up contract reference
        wrappedETH = WrappedETH(payable(wethContract));
        // Add deposit to contract
        wrappedETH.deposit{value: 1 ether }();
    }

    function exploitWithdraw() public {
        wrappedETH.withdraw(1 ether);
    }

    fallback() external payable {
        // If the user token balance hasn't been updated or is not checked then we get to call over and over until it is drained
        if (address(wrappedETH).balance >= 1 ether && wrappedETH.balanceOf(address(this)) >= 1 ether) {
            wrappedETH.withdraw(1 ether);
        }
    }
}