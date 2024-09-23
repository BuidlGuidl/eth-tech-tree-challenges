// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../contracts/Governance.sol";
import "../contracts/DecentralizedResistanceToken.sol";

contract GovernanceTest is Test {
    DecentralizedResistanceToken public token;
    uint proposalId;
    Governance public governance;
    address public userOne = address(0x123);
    address public userTwo = address(0x456);
    address public userThree = address(0x782);
    address public userNonMember = address(0x789);

    function setUp() public {
        token = new DecentralizedResistanceToken(1000000 * 10 ** 18); // 1,000,000 tokens
        // Use a different contract than default if CONTRACT_PATH env var is set
        string memory contractPath = vm.envOr("CONTRACT_PATH", string("none"));
        if (keccak256(abi.encodePacked(contractPath)) != keccak256(abi.encodePacked("none"))) {
            bytes memory args = abi.encode(address(token), 86400);
            bytes memory bytecode = abi.encodePacked(vm.getCode(contractPath), args);
            address deployed;
            assembly {
                deployed := create(0, add(bytecode, 0x20), mload(bytecode))
            }
            governance = Governance(deployed);
        } else {
            governance = new Governance(address(token), 86400); // 1 day voting period
        }
        // Distribute tokens
        token.transfer(userOne, 1000 * 10 ** 18); // 1000 tokens to userOne
        token.transfer(userTwo, 2000 * 10 ** 18); // 2000 tokens to userTwo
        token.transfer(userThree, 3000 * 10 ** 18); // 3000 tokens to userThree
        proposalId = governance.propose("Basic Proposal");
    }

    function testProposal() public {
        vm.prank(userOne);
        uint pId = governance.propose("New Proposal");
        (,string memory title,,) = governance.proposals(pId);
        assertEq(title, "New Proposal");
    }

    function testProposalIDsAreUnique() public {
        vm.prank(userOne);
        uint pId = governance.propose("New Proposal");
        (,string memory title,,) = governance.proposals(pId);
        uint pId2 = governance.propose("New Proposal 2");
        (,string memory title2,,) = governance.proposals(pId2);
        assertEq(title, "New Proposal");
        assertEq(title2, "New Proposal 2");
        assertFalse(pId == pId2);
    }

    function testErrorNonMemberProposal() public {
        vm.prank(userNonMember);
        vm.expectRevert(Governance.UnAuthorized_MembersOnly.selector);
        governance.propose("Failing Proposal");
    }

    function testErrorNonMemberVoting() public {
        vm.prank(userNonMember);
        vm.expectRevert(Governance.UnAuthorized_MembersOnly.selector);
        governance.vote(proposalId, Governance.Choice.YEA);
    }

    function testVotingFor() public {
        vm.prank(userOne);
        governance.vote(proposalId, Governance.Choice.YEA);

        assertEq(governance.votesFor(proposalId), token.balanceOf(userOne));
        assertEq(governance.votesAgainst(proposalId), 0);
        assertEq(governance.votesAbstain(proposalId), 0);
        assertTrue(governance.hasVoted(proposalId, userOne));
    }

    function testVotingAgainst() public {
        vm.prank(userTwo);
        governance.vote(proposalId, Governance.Choice.NAY);

        assertEq(governance.votesFor(proposalId), 0);
        assertEq(governance.votesAgainst(proposalId), token.balanceOf(userTwo));
        assertEq(governance.votesAbstain(proposalId), 0);
        assertTrue(governance.hasVoted(proposalId, userTwo));
    }

    function testVotingAbstain() public {
        vm.prank(userThree);
        governance.vote(proposalId, Governance.Choice.ABSTAIN);

        assertEq(governance.votesFor(proposalId), 0);
        assertEq(governance.votesAgainst(proposalId), 0);
        assertEq(governance.votesAbstain(proposalId), token.balanceOf(userThree));
        assertTrue(governance.hasVoted(proposalId, userThree));
    }

    function testErrorDoubleVoting() public {
        vm.startPrank(userOne);
        governance.vote(proposalId, Governance.Choice.NAY);
        assertTrue(governance.hasVoted(proposalId, userOne));
        vm.expectRevert(Governance.DuplicateVoting.selector);
        governance.vote(proposalId, Governance.Choice.YEA);
        vm.stopPrank();
    }

    function testTieVotingResult() public {
        vm.prank(userThree);
        governance.vote(proposalId, Governance.Choice.YEA);
        vm.prank(userOne);
        governance.vote(proposalId, Governance.Choice.NAY);
        vm.prank(userTwo);
        governance.vote(proposalId, Governance.Choice.NAY);
        vm.warp(block.timestamp + 86400 + 1);
        bool result = governance.getResult(proposalId);
        uint vote1 = uint(governance.getVote(proposalId, userThree));
        uint vote2 = uint(governance.getVote(proposalId, userOne));
        uint vote3 = uint(governance.getVote(proposalId, userTwo));
        assertEq(vote1, uint(Governance.Choice.YEA));
        assertEq(vote2, uint(Governance.Choice.NAY));
        assertEq(vote3, uint(Governance.Choice.NAY));
        assertEq(result, false);
    }

    function testVotingResultRejected() public {
        // 1000 for vs 2000 against
        vm.prank(userOne);
        governance.vote(proposalId, Governance.Choice.YEA);
        vm.prank(userTwo);
        governance.vote(proposalId, Governance.Choice.NAY);
        vm.warp(block.timestamp + 86400 + 1);
        bool result = governance.getResult(proposalId);
        (,string memory title,,) = governance.proposals(proposalId);
        assertNotEq(title, "");
        assertEq(result, false);
    }

    function testVotingResultApproved() public {
        // 2000 for vs 1000 against
        vm.prank(userOne);
        governance.vote(proposalId, Governance.Choice.NAY);
        vm.prank(userTwo);
        governance.vote(proposalId, Governance.Choice.YEA);
        vm.warp(block.timestamp + 86400 + 1);
        bool result = governance.getResult(proposalId);
        assertEq(result, true);
    }

    function testErrorVoteAfterDeadline() public {
        // Try to vote after the voting deadline
        vm.warp(block.timestamp + 86400 + 1);
        vm.prank(userOne);
        vm.expectRevert(Governance.VotingPeriodOver.selector);
        governance.vote(proposalId, Governance.Choice.YEA);
    }

    function testErrorVoteInProgress() public {
        // Try to get result when vote is in progress
        vm.expectRevert(Governance.VotingInProgress.selector);
        governance.getResult(proposalId);
    }

}