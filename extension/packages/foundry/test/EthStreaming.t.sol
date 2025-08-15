// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Test, console2 } from "../lib/forge-std/src/Test.sol";
import { EthStreaming } from "../contracts/EthStreaming.sol";

contract EthStreamingTest is Test {
    EthStreaming ethStreaming;
    address public ALICE = makeAddr("alice");
    address public BOB = makeAddr("bob");
    uint256 public STREAM_CAP = 0.5 ether;
    uint256 public FREQUENCY = 2592000; // 30 days
    uint256 public STARTING_TIMESTAMP = 42000000069;
    uint256 public STARTING_BALANCE = 3 ether;

    /**
     * Setup function is invoked before each test case is run to reduce redundancy
     * @notice Alice is given a stream, but Bob has no stream to start
     */
    function setUp() public {
        // Deploy the contract
        // Use a different contract than default if CONTRACT_PATH env var is set
        string memory contractPath = vm.envOr("CONTRACT_PATH", string("none"));
        if (keccak256(abi.encodePacked(contractPath)) != keccak256(abi.encodePacked("none"))) {
            bytes memory args = abi.encode(FREQUENCY);
            bytes memory bytecode = abi.encodePacked(vm.getCode(contractPath), args);
            address payable deployed;
            assembly {
                deployed := create(0, add(bytecode, 0x20), mload(bytecode))
            }
            ethStreaming = EthStreaming(deployed);
        } else {
            ethStreaming = new EthStreaming(FREQUENCY);
        }
        // Fund the contract
        (bool success,) = payable(ethStreaming).call{ value: STARTING_BALANCE }("");
        require(success, "Failed to send ether to ethStreaming contract");
        // Pass time to simulate what its like to deploy on network that is not brand new
        vm.warp(STARTING_TIMESTAMP);
        // Add a stream for ALICE
        ethStreaming.addStream(ALICE, STREAM_CAP);
    }

    /**
     * Stream contract should be able to receive ether
     */
    function testContractCanReceiveEther() public {
        uint256 amount = 1 ether;
        (bool success,) = payable(ethStreaming).call{ value: amount }("");
        assert(success);
        assertEq(address(ethStreaming).balance, STARTING_BALANCE + amount);
    }

    /**
     * Only the owner of stream contract is allowed to add a stream
     */
    function testOnlyOwnerCanAddStream() public {
        // Bob tries to add a stream
        vm.prank(BOB);
        // But it should revert since he is not the owner
        vm.expectRevert();
        ethStreaming.addStream(ALICE, 333);
    }

    /**
     * Ensure stream can be added
     */
    function testOwnerCanAddStream() public {
        ethStreaming.addStream(ALICE, STREAM_CAP);
    }

    /**
     * Ensure error thrown when trying to withdraw more than contract balance
     */
    function testWithdrawCannotExceedBalance() public {
        uint256 amount = STARTING_BALANCE + 1 ether;
        ethStreaming.addStream(BOB, amount);
        vm.expectRevert();
        vm.prank(BOB);
        ethStreaming.withdraw(amount);
    }

    /**
     * Test that accounts without a stream in the registry cannot withdraw
     */
    function testInvalidAccountCannotWithdraw() public {
        vm.prank(BOB);
        vm.expectRevert();
        ethStreaming.withdraw(STREAM_CAP);
    }

    /**
     * Test that accounts with a stream in the registry can withdraw
     */
    function testValidAccountCanWithdraw() public {
        vm.prank(ALICE);
        ethStreaming.withdraw(STREAM_CAP);
        uint256 aliceBalance = address(ALICE).balance;
        assertEq(aliceBalance, STREAM_CAP);
    }

    /**
     * An account that withdraws a partial amount should have the remaining amount available for withdrawal immediately
     */
    function testValidAccountCanWithdrawPartialAmountsOfUnlocked() public {
        vm.prank(ALICE);
        ethStreaming.withdraw(STREAM_CAP / 2);
        vm.prank(ALICE);
        ethStreaming.withdraw(STREAM_CAP / 2);
        uint256 aliceBalanceAfter = address(ALICE).balance;
        assertEq(aliceBalanceAfter, STREAM_CAP);
    }

    /**
     * An account that has recently withdrawn from stream should be able to withdraw partial cap before waiting the full frequency
     */
    function testValidAccountPartialWithdrawals() public {
        vm.prank(ALICE);
        // Empty Stream
        ethStreaming.withdraw(STREAM_CAP);
        vm.roll(10);
        // Stream should fill half way
        uint256 timePassed = FREQUENCY / 2;
        vm.warp(STARTING_TIMESTAMP + timePassed);
        vm.prank(ALICE);
        ethStreaming.withdraw(STREAM_CAP / 2);
        uint256 aliceBalanceAfter = address(ALICE).balance;
        assertEq(aliceBalanceAfter, STREAM_CAP + STREAM_CAP / 2);
    }

    /**
     * An account that has withdrawn the full cap should not be be able to withdraw until some time has passed
     */
    function testValidAccountCannotWithdrawFromDepletedStream() public {
        vm.startPrank(ALICE);
        // Empty Stream
        ethStreaming.withdraw(STREAM_CAP);
        vm.expectRevert();
        ethStreaming.withdraw(1);
    }

    /**
     * An account should not be be able to withdraw more than the cap
     */
    function testValidAccountCannotWithdrawMoreThanCap() public {
        vm.startPrank(ALICE);
        vm.expectRevert();
        ethStreaming.withdraw(STREAM_CAP * 2);
        vm.stopPrank();

        // Test edge case with second withdrawal
        ethStreaming.addStream(BOB, STREAM_CAP);
        vm.startPrank(BOB);
        ethStreaming.withdraw(STREAM_CAP);

        vm.warp(STARTING_TIMESTAMP + FREQUENCY * 2);

        vm.expectRevert();
        ethStreaming.withdraw(STREAM_CAP + 1);
    }

    /**
     * Test that the owner can update a stream to a new cap and stream owner can withdraw new cap
     */
    function testOwnerCanUpdateStream() public {
        uint256 newCap = 1 ether;
        ethStreaming.addStream(ALICE, newCap);
        vm.prank(ALICE);
        ethStreaming.withdraw(newCap);
    }

    /**
     * Ensure reentrancy attack is not possible
     */
    function testReentrancyAttackFails() public {
        // Whale deposits to the DeadMansSwitch contract
        vm.deal(address(ethStreaming), 10 ether);
        // Set up the exploit contract
        ReentrancyTest reentrancyTest = new ReentrancyTest();
        // The stream contract owner adds a stream, not realizing that the address is a malicious contract
        ethStreaming.addStream(address(reentrancyTest), STREAM_CAP);
        // The malicious contract is set up with the right params
        reentrancyTest.setUp(address(ethStreaming), STREAM_CAP);
        // It is okay if the exploit fails
        try reentrancyTest.exploitWithdraw() { } catch { }
        // If the exploit worked then we should have more than we put in
        assertLe(address(reentrancyTest).balance, 1 ether);
    }
}

contract ReentrancyTest {
    EthStreaming public ethStreaming;
    uint256 public STREAM_CAP;

    function setUp(address ethStreamingContract, uint256 _streamCap) public payable {
        // Set up contract reference
        ethStreaming = EthStreaming(payable(ethStreamingContract));
        STREAM_CAP = _streamCap;
    }

    function exploitWithdraw() public {
        ethStreaming.withdraw(STREAM_CAP);
    }

    receive() external payable {
        // Attempt to call withdraw over and over until no more funds are left
        if (address(ethStreaming).balance >= STREAM_CAP) {
            ethStreaming.withdraw(STREAM_CAP);
        }
    }
}
