// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../contracts/Governance.sol";
import "../contracts/DecentralizedResistanceToken.sol";

contract GovernanceTest is Test {
    DecentralizedResistanceToken public token;
    uint proposalId;
    Governance public governance;
    uint votingPeriod = votingPeriod; // 1 day
    address public userOne = address(0x123);
    address public userTwo = address(0x456);
    address public userThree = address(0x782);
    address public userNonMember = address(0x789);

    function setUp() public {
        token = new DecentralizedResistanceToken(1000000 * 10 ** 18); // 1,000,000 tokens
        // Use a different contract than default if CONTRACT_PATH env var is set
        string memory contractPath = vm.envOr("CONTRACT_PATH", string("none"));
        if (keccak256(abi.encodePacked(contractPath)) != keccak256(abi.encodePacked("none"))) {
            bytes memory args = abi.encode(address(token), votingPeriod);
            bytes memory bytecode = abi.encodePacked(vm.getCode(contractPath), args);
            address payable deployed;
            assembly {
                deployed := create(0, add(bytecode, 0x20), mload(bytecode))
            }
            governance = Governance(deployed);
        } else {
            governance = new Governance(address(token), votingPeriod); // 1 day voting period
        }
        // Distribute tokens
        token.transfer(userOne, 1000 * 10 ** 18); // 1000 tokens to userOne
        token.transfer(userTwo, 2000 * 10 ** 18); // 2000 tokens to userTwo
        token.transfer(userThree, 3000 * 10 ** 18); // 3000 tokens to userThree
        token.setVotingContract(address(governance));
        proposalId = governance.propose("Basic Proposal");
    }

    function testProposal() public {
        vm.startPrank(userOne);
        vm.expectEmit(true, true, false, false);
        emit Governance.ProposalCreated(proposalId, "New Proposal", 0, userOne);
        uint pId = governance.propose("New Proposal");
        (string memory title,,) = governance.getProposal(pId);
        assertEq(title, "New Proposal");
    }

    function testProposalIDsAreUnique() public {
        vm.prank(userOne);
        uint pId = governance.propose("New Proposal");
        (string memory title, uint deadline,) = governance.getProposal(pId);
        vm.warp(deadline + 1);
        uint pId2 = governance.propose("New Proposal 2");
        (string memory title2,,) = governance.getProposal(pId2);
        assertEq(title, "New Proposal");
        assertEq(title2, "New Proposal 2");
        assertFalse(pId == pId2);
    }

    

    function testErrorSubmitProposalWhenOneAlreadyQueued() public {
        vm.prank(userOne);
        uint pId = governance.propose("New Proposal");
        governance.getProposal(pId);
        vm.expectRevert();
        governance.propose("New Proposal 2");
    }

    function testErrorNonMemberProposal() public {
        vm.prank(userNonMember);
        vm.expectRevert();
        governance.propose("Failing Proposal");
    }

    function testErrorNonMemberVoting() public {
        vm.prank(userNonMember);
        vm.expectRevert();
        governance.vote(1);
    }

    function testVotingFor() public {
        vm.startPrank(userOne);
        vm.expectEmit(false, true, true, true);
        emit Governance.VoteCasted(proposalId, userOne, 1, token.balanceOf(userOne));
        governance.vote(1);
        (,uint deadline,) = governance.getProposal(proposalId);
        vm.warp(deadline + 1);
        bool result = governance.getResult(proposalId);
        assertEq(result, true);
    }

    function testVotingAgainst() public {
        vm.startPrank(userTwo);
        vm.expectEmit(false, true, true, true);
        emit Governance.VoteCasted(proposalId, userTwo, 0, token.balanceOf(userTwo));
        governance.vote(0);
        (,uint deadline,) = governance.getProposal(proposalId);
        vm.warp(deadline + 1);
        bool result = governance.getResult(proposalId);
        assertEq(result, false);
    }

    function testVotingAbstain() public {
        // Test that an abstain vote doesn't stop a proposal from failing
        vm.startPrank(userThree);
        vm.expectEmit(false, true, true, true);
        emit Governance.VoteCasted(proposalId, userThree, 2, token.balanceOf(userThree));
        governance.vote(2);
        vm.stopPrank();
        (,uint deadline,) = governance.getProposal(proposalId);
        vm.warp(deadline + 1);
        bool result = governance.getResult(proposalId);
        assertEq(result, false);

        // Test that the abstain vote doesn't stop a vote from passing
        uint newProposalId = governance.propose("New Proposal");
        governance.vote(1);
        vm.startPrank(userThree);
        vm.expectEmit(false, true, true, true);
        emit Governance.VoteCasted(newProposalId, userThree, 2, token.balanceOf(userThree));
        governance.vote(2);

        (,uint nextDeadline,) = governance.getProposal(newProposalId);
        vm.warp(nextDeadline + 1);
        bool nextResult = governance.getResult(newProposalId);
        assertEq(nextResult, true);
    }

    function testErrorDoubleVoting() public {
        vm.startPrank(userOne);
        governance.vote(0);
        vm.expectRevert();
        governance.vote(1);
        vm.stopPrank();
    }

    function testTieVotingResult() public {
        // Tie vote should result in a failed proposal
        vm.prank(userThree);
        governance.vote(1);
        vm.prank(userOne);
        governance.vote(0);
        vm.prank(userTwo);
        governance.vote(0);
        vm.warp(block.timestamp + votingPeriod + 1);
        bool result = governance.getResult(proposalId);
        assertEq(result, false);
    }

    function testVotingResultRejected() public {
        // 1000 for vs 2000 against
        vm.prank(userOne);
        governance.vote(1);
        vm.prank(userTwo);
        governance.vote(0);
        vm.warp(block.timestamp + votingPeriod + 1);
        bool result = governance.getResult(proposalId);
        (string memory title,,) = governance.getProposal(proposalId);
        assertNotEq(title, "");
        assertEq(result, false);
    }

    function testVotingResultApproved() public {
        // 2000 for vs 1000 against
        vm.prank(userOne);
        governance.vote(0);
        vm.prank(userTwo);
        governance.vote(1);
        vm.warp(block.timestamp + votingPeriod + 1);
        bool result = governance.getResult(proposalId);
        assertEq(result, true);
    }

    function testErrorVoteAfterDeadline() public {
        // Try to vote after the voting deadline
        vm.warp(block.timestamp + votingPeriod + 1);
        vm.prank(userOne);
        vm.expectRevert();
        governance.vote(1);
    }

    function testErrorVoteInProgress() public {
        // Try to get result when vote is in progress
        vm.expectRevert();
        governance.getResult(proposalId);
    }

    function testVotesRemovedOnTokenTransfer() public {
        vm.startPrank(userOne);
        governance.vote(1);
        vm.expectEmit(false, true, true, true);
        emit Governance.VotesRemoved(userOne, 1, token.balanceOf(userOne));
        token.transfer(userTwo, 100 * 10 ** 18);
        // Now all their votes for the proposal should be removed
        vm.warp(block.timestamp + votingPeriod + 1);
        bool result = governance.getResult(proposalId);
        assertEq(result, false);
    }

    function testVoterCanReVoteAfterTokenTransfer() public {
        vm.startPrank(userOne);
        governance.vote(1);

        token.transfer(userTwo, 100 * 10 ** 18);
        // Should be able to vote again
        governance.vote(1);
        vm.warp(block.timestamp + votingPeriod + 1);
        bool result = governance.getResult(proposalId);
        assertEq(result, true);
    }
}