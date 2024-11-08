// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/Challenge.sol";

contract MolochRageQuitTest is Test {
    MolochRageQuit public dao;
    address public member1 = vm.addr(1);
    address public member2 = vm.addr(2);
    address public nonMember1 = vm.addr(3);
    uint256 public ONE_ETH = 1 ether;
    uint256 public DEPLOYER_SHARES = 100;
    address public THIS_ADDR = address(this);
    
    uint256 public DEADLINE = block.timestamp + 1 days;
    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        address contractAddr,
        bytes data,
        uint256 deadline
    );
    event ProposalApproved(uint256 proposalId, address approver);
    event RageQuit(address member, uint256 shareAmount);
    event MemberAdded(address member);
    event Voted(uint256 proposalId, address voter);
    event ProposalExecuted(uint256 proposalId);
    event ProposalValueRefunded(address proposer, uint256 amount);

    function setUp() public {
        // Use a different contract than default if CONTRACT_PATH env var is set
        string memory contractPath = vm.envOr("CONTRACT_PATH", string("none"));
        if (keccak256(abi.encodePacked(contractPath)) != keccak256(abi.encodePacked("none"))) {
            bytes memory args = abi.encode(DEPLOYER_SHARES);
            bytes memory bytecode = abi.encodePacked(vm.getCode(contractPath), args);
            address payable deployed;
            assembly {
                deployed := create(0, add(bytecode, 0x20), mload(bytecode))
            }
            dao = MolochRageQuit(deployed);
        } else {
            dao = new MolochRageQuit(DEPLOYER_SHARES);
        }
        vm.deal(member1, ONE_ETH);
        vm.deal(member2, ONE_ETH);
    }

    function testProposalCreation() public {
        vm.expectEmit(true, true, true, true);
        emit ProposalCreated(
            1,
            THIS_ADDR,
            address(dao),
            addMemberData(member1, 100),
            DEADLINE
        );
        dao.propose(
            address(dao),
            addMemberData(member1, 100),
            DEADLINE
        );

        (address proposer,
        address contractAddr,
        bytes memory data,
        uint256 votes,
        uint256 deadline) = dao.getProposal(1);
        assertEq(proposer, THIS_ADDR);
        assertEq(contractAddr, address(dao));
        assertEq(data, addMemberData(member1, 100));
        assertEq(votes, 0);
        assertEq(deadline, DEADLINE);
    }

    function testCreateProposalNonMember () public {
        vm.startPrank(nonMember1);
        vm.expectRevert();
        dao.propose(
            address(dao),
            addMemberData(nonMember1, 100),
            DEADLINE
        );
    }

    function testProposalAddressZero() public {
        vm.expectRevert();
        dao.propose(
            address(0),
            addMemberData(member1, 100),
            DEADLINE
        );
    }

    function testInvalidProposalDeadline() public {
        vm.expectRevert();
        dao.propose(
            address(dao),
            addMemberData(member1, 100),
            block.timestamp - 1
        );
    }

    function testProposalExists() public {
        vm.expectRevert();
        dao.vote(1);
    }

    function testMemberCanVote() public {
        dao.propose(
            address(dao),
            addMemberData(member1, 100),
            DEADLINE
        );
        dao.vote(1);
        (, , , uint256 votes, ) = dao.getProposal(1);
        assertEq(votes, 1);
    }

    function testMemberCanOnlyVoteOnce() public {
        dao.propose(
            address(dao),
            addMemberData(member1, 100),
            DEADLINE
        );
        dao.vote(1);
        vm.expectRevert();
        dao.vote(1);
    }

    function testNonMembersCannotVote() public {
        dao.propose(
            address(dao),
            addMemberData(member1, 100),
            DEADLINE
        );
        vm.prank(nonMember1);
        vm.expectRevert();
        dao.vote(1);
    }

    function testProposalExecution() public {
        dao.propose(
            address(dao),
            addMemberData(member1, 100),
            DEADLINE
        );

        dao.vote(1);
        vm.warp(block.timestamp + 2 days);
        vm.expectEmit(true, true, true, true);
        emit MemberAdded(member1);
        dao.executeProposal(1);
    }

    function testAddMember() public {
        dao.propose(
            address(dao),
            addMemberData(member1, 100),
            DEADLINE
        );
        dao.vote(1);
        vm.warp(block.timestamp + 2 days);
        vm.expectEmit(true, true, true, true);
        emit MemberAdded(member1);
        dao.executeProposal(1);
        assertTrue(dao.isMember(member1));
    }

    function testDeadlineNotReached() public {
        dao.propose(
            address(dao),
            addMemberData(member1, 100),
            DEADLINE
        );
        vm.expectRevert();
        dao.executeProposal(1);
    }

    function testProposalRejected() public {
        dao.propose(
            address(dao),
            addMemberData(member1, 100),
            DEADLINE
        );
        vm.warp(block.timestamp + 2 days);
        vm.expectRevert();
        dao.executeProposal(1);
    }

    function testProposalAlreadyVotedEvent() public {
        dao.propose(
            address(dao),
            addMemberData(member1, 100),
            DEADLINE
        );
        dao.vote(1);
        vm.expectRevert();
        dao.vote(1);
    }

    function testRageQuit() public {
        // This will add 1 ETH to treasury
        payable(address(dao)).transfer(ONE_ETH);
        dao.propose(
            address(dao),
            addMemberData(member1, 100),
            DEADLINE
        );
        dao.vote(1);
        vm.warp(block.timestamp + 2 days);
        dao.executeProposal(1);
        assertTrue(dao.isMember(member1));
        vm.startPrank(member1);
        uint balanceBefore = address(member1).balance;
        vm.expectEmit(true, true, true, true);
        emit RageQuit(member1, ONE_ETH / 2);
        dao.rageQuit();
        assertFalse(dao.isMember(member1));
        uint balanceAfter = address(member1).balance;
        assertEq(balanceAfter, balanceBefore + ONE_ETH / 2);
        
    }

    function testRageQuitWithDifferentShareAmounts() public {
        // Add three ETH to the treasury
        payable(address(dao)).transfer(ONE_ETH * 3);
        // Propose to add new member
        dao.propose(
            address(dao),
            addMemberData(member1, 100),
            DEADLINE
        );
        // Propose to add a second member
        dao.propose(
            address(dao),
            addMemberData(member2, 100),
            DEADLINE
        );
        // Vote for each proposal
        dao.vote(1);
        dao.vote(2);
        vm.warp(block.timestamp + 2 days);
        dao.executeProposal(1);
        assertTrue(dao.isMember(member1));
        vm.startPrank(member1);
        // Vote for the second proposal
        dao.vote(2);
        dao.executeProposal(2);
        assertTrue(dao.isMember(member2));
        // Now there are three members (including deployer) and three ETH in the treasury
        vm.expectEmit(true, true, true, true);
        emit RageQuit(member1, ONE_ETH);
        dao.rageQuit();
        assertFalse(dao.isMember(member1));
        // Member 2 should be able to rage quit with the same outcome
        vm.startPrank(member2);
        vm.expectEmit(true, true, true, true);
        emit RageQuit(member2, ONE_ETH);
        dao.rageQuit();
        assertFalse(dao.isMember(member2));
    }

    function testRageQuitNonMember() public {
        vm.startPrank(nonMember1);
        vm.expectRevert();
        dao.rageQuit();
    }

    receive() external payable {}

    // Helper functions
    function addMemberData(address member, uint share) public pure returns (bytes memory) {
        return abi.encodeWithSignature(
            "addMember(address,uint256)",
            member,
            share
        );
    }
}