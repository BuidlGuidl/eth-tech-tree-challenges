// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../contracts/DeadMansSwitch.sol";

contract DeadMansSwitchTest is Test {
    DeadMansSwitch public deadMansSwitch;
    address THIS_CONTRACT = address(this);
    address NON_CONTRACT_USER = vm.addr(1);
    address BENEFICIARY_1 = vm.addr(2);
    uint ONE_THOUSAND = 1000 wei;
    uint INTERVAL = 1 weeks;
    uint HONEY_POT = 1 ether;

    // Setup the contract before each test
    function setUp() public {
        // Use a different contract than default if CONTRACT_PATH env var is set
        string memory contractPath = vm.envOr("CONTRACT_PATH", string("none"));
        if (keccak256(abi.encodePacked(contractPath)) != keccak256(abi.encodePacked("none"))) {
            bytes memory bytecode = vm.getCode(contractPath);
            address payable deployed;
            assembly {
                deployed := create(0, add(bytecode, 0x20), mload(bytecode))
            }
            deadMansSwitch = DeadMansSwitch(deployed);
        } else {
            deadMansSwitch = new DeadMansSwitch();
        }
    }

    // Test deposit functionality
    function testDeposit() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        uint balance = deadMansSwitch.balanceOf(THIS_CONTRACT);
        assertEq(balance, ONE_THOUSAND);
    }

    // Test setting the check-in interval
    function testSetCheckInInterval() public {
        deadMansSwitch.setCheckInInterval(INTERVAL);
        uint checkInInterval = deadMansSwitch.checkInInterval(THIS_CONTRACT);
        assertEq(checkInInterval, INTERVAL);
    }

    // Test setting the check-in interval to 0
    function testSetCheckInIntervalWhenZero() public {
        vm.expectRevert();
        deadMansSwitch.setCheckInInterval(0);
    }

    // Test the check-in functionality
    function testCheckIn() public {
        deadMansSwitch.setCheckInInterval(INTERVAL);
        deadMansSwitch.checkIn();
        uint lastCheckIn = deadMansSwitch.lastCheckIn(THIS_CONTRACT);
        assertEq(lastCheckIn, block.timestamp);
    }

    // Test adding a beneficiary
    function testAddBeneficiary() public {
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.BeneficiaryAdded(THIS_CONTRACT, BENEFICIARY_1);
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
    }

    // Test removing a beneficiary
    function testRemoveBeneficiary() public {
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.BeneficiaryAdded(THIS_CONTRACT, BENEFICIARY_1);
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);

        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.BeneficiaryRemoved(THIS_CONTRACT, BENEFICIARY_1);
        deadMansSwitch.removeBeneficiary(BENEFICIARY_1);
    }

    // Test removing a beneficiary
    function testRemoveBeneficiaryWhenBeneficiaryDoesntExist() public {
        vm.expectRevert();
        deadMansSwitch.removeBeneficiary(BENEFICIARY_1);
    }

    // Test withdrawing funds by the user
    function testWithdraw() public {
        vm.deal(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        uint balanceBefore = deadMansSwitch.balanceOf(NON_CONTRACT_USER);
        deadMansSwitch.withdraw(NON_CONTRACT_USER, ONE_THOUSAND);
        uint balanceAfter = deadMansSwitch.balanceOf(NON_CONTRACT_USER);
        assertEq(balanceBefore, ONE_THOUSAND);
        assertEq(balanceAfter, 0);
    }

    // Test withdrawing funds by the user
    function testWithdrawInsufficientBalance() public {
        vm.deal(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        uint balance = deadMansSwitch.balanceOf(NON_CONTRACT_USER);
        assertEq(balance, ONE_THOUSAND);
        vm.expectRevert();
        deadMansSwitch.withdraw(NON_CONTRACT_USER, ONE_THOUSAND + 1);
        uint balance2 = deadMansSwitch.balanceOf(NON_CONTRACT_USER);
        assertEq(balance2, ONE_THOUSAND);
    }

    // Test withdrawing funds by the user
    function testWithdrawTransferFailed() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        uint balance = deadMansSwitch.balanceOf(THIS_CONTRACT);
        assertEq(balance, ONE_THOUSAND);
        vm.expectRevert();
        deadMansSwitch.withdraw(THIS_CONTRACT, ONE_THOUSAND);
        uint balance2 = deadMansSwitch.balanceOf(THIS_CONTRACT);
        assertEq(balance2, ONE_THOUSAND);
    }

    // Test withdrawing funds by a beneficiary after the interval has passed
    function testWithdrawAsBeneficiary() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        vm.warp(block.timestamp + INTERVAL + 1);
        vm.startPrank(BENEFICIARY_1);
        uint initialBalance = address(BENEFICIARY_1).balance;
        deadMansSwitch.withdraw(THIS_CONTRACT, ONE_THOUSAND);
        uint finalBalance = address(BENEFICIARY_1).balance;
        assertEq(finalBalance, initialBalance + ONE_THOUSAND);
        uint balance = deadMansSwitch.balanceOf(THIS_CONTRACT);
        assertEq(balance, 0);
    }

    // Test withdrawing funds by a beneficiary after the interval has passed
    function testWithdrawAsBeneficiaryPartialAmounts() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND * 2}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        vm.warp(block.timestamp + INTERVAL + 1);
        vm.startPrank(BENEFICIARY_1);
        uint initialBalance = address(BENEFICIARY_1).balance;
        // Withdraw half
        deadMansSwitch.withdraw(THIS_CONTRACT, ONE_THOUSAND);
        // Withdraw the rest
        deadMansSwitch.withdraw(THIS_CONTRACT, ONE_THOUSAND);
        uint finalBalance = address(BENEFICIARY_1).balance;
        assertEq(finalBalance, initialBalance + ONE_THOUSAND * 2);
        uint balance = deadMansSwitch.balanceOf(THIS_CONTRACT);
        assertEq(balance, 0);
    }

    // Test withdrawing funds by a beneficiary that cannot receive ether
    function testWithdrawAsBeneficiaryTransferFailed() public {
        vm.deal(BENEFICIARY_1, ONE_THOUSAND);
        vm.startPrank(BENEFICIARY_1);
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        // Adding THIS_CONTRACT as a beneficiary since it can't receive ether
        deadMansSwitch.addBeneficiary(THIS_CONTRACT);
        vm.warp(block.timestamp + INTERVAL + 1);
        vm.startPrank(THIS_CONTRACT);
        uint initialBalance = address(THIS_CONTRACT).balance;
        vm.expectRevert();
        deadMansSwitch.withdraw(BENEFICIARY_1, ONE_THOUSAND);
        uint finalBalance = address(THIS_CONTRACT).balance;
        assertEq(finalBalance, initialBalance);
        uint balance = deadMansSwitch.balanceOf(BENEFICIARY_1);
        assertEq(balance, ONE_THOUSAND);
    }

    // Test that non-beneficiaries cannot withdraw funds
    function testWithdrawAsNonBeneficiary() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        vm.warp(block.timestamp + INTERVAL + 1);
        vm.startPrank(NON_CONTRACT_USER);
        vm.expectRevert();
        deadMansSwitch.withdraw(THIS_CONTRACT, ONE_THOUSAND);
    }

    // Test that non-beneficiaries cannot withdraw funds before the interval has passed
    function testWithdrawAsNonBeneficiaryBeforeInterval() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        vm.warp(block.timestamp + INTERVAL - 1);
        vm.startPrank(NON_CONTRACT_USER);
        vm.expectRevert();
        deadMansSwitch.withdraw(THIS_CONTRACT, ONE_THOUSAND);
    }

    // Test that beneficiaries cannot withdraw funds before the interval has passed
    function testWithdrawAsBeneficiaryBeforeInterval() public {
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        deadMansSwitch.setCheckInInterval(INTERVAL);
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        vm.warp(block.timestamp + INTERVAL - 1);
        vm.startPrank(BENEFICIARY_1);
        vm.expectRevert();
        deadMansSwitch.withdraw(THIS_CONTRACT, ONE_THOUSAND);
    }

    //Test  if user is already a beneficiary
    function testAddBeneficiaryTwice() public {
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        vm.expectRevert();
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
    }

    //Test for zero address
    function testZeroAddress() public {
        vm.expectRevert();
        deadMansSwitch.addBeneficiary(address(0));
    }

    // Test that the Deposit event is emitted correctly
    function testEmitDepositEvent() public {
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.Deposit(THIS_CONTRACT, ONE_THOUSAND);
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
    }

    // Test that the Withdrawal event is emitted correctly
    function testEmitWithdrawalEvent() public {
        vm.deal(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.Withdrawal(NON_CONTRACT_USER, ONE_THOUSAND);
        deadMansSwitch.withdraw(NON_CONTRACT_USER, ONE_THOUSAND);
    }

    function testContractCanHandleReceivedFundsWithoutCallData() public {
        vm.deal(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        payable(deadMansSwitch).call{value: ONE_THOUSAND}("");
        (uint balance, , ) = deadMansSwitch.users(NON_CONTRACT_USER);
        assertEq(balance, ONE_THOUSAND);
    }

    function testContractCanHandleReceivedFundsWithUnknownCallData() public {
        vm.deal(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        payable(deadMansSwitch).call{value: ONE_THOUSAND}("0x1234");
        (uint balance, , ) = deadMansSwitch.users(NON_CONTRACT_USER);
        assertEq(balance, ONE_THOUSAND);
    }

     // Test that the CheckIn event is emitted correctly when checkIn is called
    function testEmitCheckInEventOnCheckIn() public {
        deadMansSwitch.setCheckInInterval(INTERVAL);
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.CheckIn(THIS_CONTRACT, block.timestamp);
        deadMansSwitch.checkIn();
        uint lastCheckIn = deadMansSwitch.lastCheckIn(THIS_CONTRACT);
        assertEq(lastCheckIn, block.timestamp);
    }

    // Test that the CheckIn event is emitted correctly when deposit is called
    function testEmitCheckInEventOnDeposit() public {
        deadMansSwitch.setCheckInInterval(INTERVAL);
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.CheckIn(THIS_CONTRACT, block.timestamp);
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        uint lastCheckIn = deadMansSwitch.lastCheckIn(THIS_CONTRACT);
        assertEq(lastCheckIn, block.timestamp);
    }

    // Test that the CheckIn event is emitted correctly when setCheckInInterval is called
    function testEmitCheckInEventOnSetCheckInInterval() public {
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.CheckIn(THIS_CONTRACT, block.timestamp);
        deadMansSwitch.setCheckInInterval(INTERVAL);
        uint lastCheckIn = deadMansSwitch.lastCheckIn(THIS_CONTRACT);
        assertEq(lastCheckIn, block.timestamp);
    }

    // Test that the CheckIn event is emitted correctly when addBeneficiary is called
    function testEmitCheckInEventOnAddBeneficiary() public {
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.CheckIn(THIS_CONTRACT, block.timestamp);
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        uint lastCheckIn = deadMansSwitch.lastCheckIn(THIS_CONTRACT);
        assertEq(lastCheckIn, block.timestamp);
    }

    // Test that the CheckIn event is emitted correctly when removeBeneficiary is called
    function testEmitCheckInEventOnRemoveBeneficiary() public {
        deadMansSwitch.addBeneficiary(BENEFICIARY_1);
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.CheckIn(THIS_CONTRACT, block.timestamp);
        deadMansSwitch.removeBeneficiary(BENEFICIARY_1);
        uint lastCheckIn = deadMansSwitch.lastCheckIn(THIS_CONTRACT);
        assertEq(lastCheckIn, block.timestamp);
    }

    // Test that the CheckIn event is emitted correctly when withdraw is called
    function testEmitCheckInEventOnWithdraw() public {
        vm.deal(NON_CONTRACT_USER, ONE_THOUSAND);
        vm.startPrank(NON_CONTRACT_USER);
        deadMansSwitch.deposit{value: ONE_THOUSAND}();
        vm.expectEmit(true, true, true, true);
        emit DeadMansSwitch.CheckIn(NON_CONTRACT_USER, block.timestamp);
        deadMansSwitch.withdraw(NON_CONTRACT_USER, ONE_THOUSAND);
        uint lastCheckIn = deadMansSwitch.lastCheckIn(NON_CONTRACT_USER);
        assertEq(lastCheckIn, block.timestamp);
    }

    function testWithdrawIsReentrancySafe() public {
        // Whale deposits to the DeadMansSwitch contract
        vm.deal(NON_CONTRACT_USER, 10 ether);
        vm.prank(NON_CONTRACT_USER);
        deadMansSwitch.deposit{value: 10 ether}();
        // Set up the exploit contract
        ReentrancyTest reentrancyTest = new ReentrancyTest();
        reentrancyTest.setUp{value: 1 ether}(address(deadMansSwitch));
        // Hopefully this reverts, otherwise the contract is vulnerable to reentrancy
        vm.expectRevert();
        reentrancyTest.exploitWithdraw();
    }
}

contract ReentrancyTest {
    DeadMansSwitch public deadMansSwitch;
    function setUp(address wethContract) public payable {
        // Set up contract reference
        deadMansSwitch = DeadMansSwitch(payable(wethContract));
        // Add deposit to contract
        deadMansSwitch.deposit{value: 1 ether }();
    }

    function exploitWithdraw() public {
        deadMansSwitch.withdraw(address(this), 1 ether);
    }

    fallback() external payable {
        // If the user token balance hasn't been updated or is not checked then we get to call over and over until it is drained
        if (address(deadMansSwitch).balance >= 1 ether) {
            deadMansSwitch.withdraw(address(this), 1 ether);
        }
    }
}