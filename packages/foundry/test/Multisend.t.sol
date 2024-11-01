// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../contracts/Multisend.sol";
import "../contracts/MockToken.sol";

/**
 * @title Multisend Challenge Auto-Grading Tests
 * @author BUIDL GUIDL
 * @notice These tests will be used to autograde the challenge within the tech tree. This test file is PURELY EDUCATIONAL, and is not to be used in production code. It is up to the user's discretion to make their own production code, run tests, have audits, etc.
 */
contract MultisendTest is Test {

    /// Vars

    Multisend multisend;
    // King of the Pirates
    address payable luffy;
    // Best Navigator
    address payable nami;
    // World's Greatest Swordsman
    address payable zoro;

    // ERC20 tokens used for tests.
    MockToken internal dai;
    MockToken internal weth;

    // List of all ERC20 tokens
    IERC20[] internal tokens;

    // Default balance for accounts
    uint256 internal defaultBalance = 1e6 * 1e18;

    // array params for happy path tests
    address payable[] recipients;
    address[] tokenRecipients;

    uint256[] amounts = [1e18, 2e18];
    uint256[] tooHighAmounts = [defaultBalance + 1, defaultBalance + 1];
    uint256[] biggerAmountsArray = [1e18, 2e18, 1e18];

    // balances expected when Nami sends amounts
    uint256 namiExpectedBalance1 = defaultBalance - amounts[0] - amounts[1];
    uint256 luffyExpectedBalance1 = defaultBalance + amounts[0];
    uint256 zoroExpectedBalance1 = defaultBalance + amounts[1];

    // balances expected when Zoro sends amounts
    uint256 namiExpectedBalance2 = defaultBalance - amounts[0];
    uint256 luffyExpectedBalance2 = defaultBalance + amounts[0] + amounts[0];
    uint256 zoroExpectedBalance2 = defaultBalance + amounts[1] - amounts[0] - amounts[1];

    function setUp() external {
        // Deploy the base test contracts.
        dai = createERC20("DAI");
        weth = createERC20("WETH");

        // Fill the token list.
        tokens.push(dai);
        tokens.push(weth);

        // Create users for testing.
        nami = createUser("nami");
        zoro = createUser("zoro");
        luffy = createUser("luffy");

        recipients = [luffy, zoro];
        tokenRecipients = [luffy, zoro];

        // Use a different contract than default if CONTRACT_PATH env var is set
        string memory contractPath = vm.envOr("CONTRACT_PATH", string("none"));
        if (keccak256(abi.encodePacked(contractPath)) != keccak256(abi.encodePacked("none"))) {
            bytes memory bytecode = vm.getCode(contractPath);
            address payable deployed;
            assembly {
                deployed := create(0, add(bytecode, 0x20), mload(bytecode))
            }
            multisend = Multisend(deployed);
        } else {
            multisend = new Multisend();
        }
    }

    function testSendETH() external {
        // nami sends luffy ETH
        vm.prank(nami);
        multisend.sendETH{value: amounts[0] + amounts[1] }(recipients, amounts);

        assertEq(nami.balance, namiExpectedBalance1);
        assertEq(luffy.balance,luffyExpectedBalance1);
        assertEq(zoro.balance, zoroExpectedBalance1);

        // zoro sends ETH
        recipients = [luffy, nami];
        vm.prank(zoro);
        vm.expectEmit(true, true, false, true);
        emit Multisend.SuccessfulETHTransfer(zoro, recipients, amounts);

        multisend.sendETH{value: amounts[0] + amounts[1] }(recipients, amounts);

        assertEq(nami.balance, namiExpectedBalance2);
        assertEq(luffy.balance, luffyExpectedBalance2);
        assertEq(zoro.balance, zoroExpectedBalance2);
    }
    

    function testSendTokens() external {
        // nami sends dai and weth
        vm.startPrank(nami);

        uint256 amountsApproved;

        for (uint i = 0; i < amounts.length; i++) {
            amountsApproved += amounts[i];
        }
        dai.approve(address(multisend), amountsApproved);
        weth.approve(address(multisend), amountsApproved);
        vm.expectEmit(true, true, false, true);
        emit Multisend.SuccessfulTokenTransfer(nami, tokenRecipients, amounts, address(dai));
        multisend.sendTokens(tokenRecipients, amounts, address(dai));

        vm.expectEmit(true, true, false, true);
        emit Multisend.SuccessfulTokenTransfer(nami, tokenRecipients, amounts, address(weth));
        multisend.sendTokens(tokenRecipients, amounts, address(weth));
        vm.stopPrank;

        assertEq(dai.balanceOf(nami), namiExpectedBalance1);
        assertEq(weth.balanceOf(nami), namiExpectedBalance1);
        assertEq(dai.balanceOf(luffy), luffyExpectedBalance1);
        assertEq(weth.balanceOf(luffy), luffyExpectedBalance1);
        assertEq(dai.balanceOf(zoro), zoroExpectedBalance1);
        assertEq(weth.balanceOf(zoro), zoroExpectedBalance1);

        tokenRecipients = [luffy, nami];

        // zoro sends dai and weth
        vm.startPrank(zoro);

        dai.approve(address(multisend), amountsApproved);
        weth.approve(address(multisend), amountsApproved);

        vm.expectEmit(true, true, false, true);
        emit Multisend.SuccessfulTokenTransfer(zoro, tokenRecipients, amounts, address(dai));
        multisend.sendTokens(tokenRecipients, amounts, address(dai));

        vm.expectEmit(true, true, false, true);
        emit Multisend.SuccessfulTokenTransfer(zoro, tokenRecipients, amounts, address(weth));
        multisend.sendTokens(tokenRecipients, amounts, address(weth));
        vm.stopPrank;

        assertEq(dai.balanceOf(nami), namiExpectedBalance2);
        assertEq(weth.balanceOf(nami), namiExpectedBalance2);
        assertEq(dai.balanceOf(luffy), luffyExpectedBalance2);
        assertEq(weth.balanceOf(luffy), luffyExpectedBalance2);
        assertEq(dai.balanceOf(zoro), zoroExpectedBalance2);
        assertEq(weth.balanceOf(zoro), zoroExpectedBalance2);
    }

    function testSendTokensSameRecipients() external {
        // nami sends dai and weth
        tokenRecipients = [luffy, luffy];

        vm.startPrank(nami);

        uint256 amountsApproved;

        for (uint i = 0; i < amounts.length; i++) {
            amountsApproved += amounts[i];
        }
        dai.approve(address(multisend), amountsApproved);
        weth.approve(address(multisend), amountsApproved);

        vm.expectEmit(true, true, false, true);
        emit Multisend.SuccessfulTokenTransfer(nami, tokenRecipients, amounts, address(dai));
        multisend.sendTokens(tokenRecipients, amounts, address(dai));

        vm.expectEmit(true, true, false, true);
        emit Multisend.SuccessfulTokenTransfer(nami, tokenRecipients, amounts, address(weth));
        multisend.sendTokens(tokenRecipients, amounts, address(weth));
        vm.stopPrank;

        assertEq(dai.balanceOf(nami), namiExpectedBalance1);
        assertEq(weth.balanceOf(nami), namiExpectedBalance1);
        assertEq(dai.balanceOf(luffy), defaultBalance + amounts[0] + amounts[1]);
        assertEq(weth.balanceOf(luffy), defaultBalance + amounts[0] + amounts[1]);
    }

    function testSendETHSameRecipients() external {
        // nami sends luffy ETH
        recipients = [luffy, luffy];

        vm.prank(nami);
        vm.expectEmit(true, true, false, true);
        emit Multisend.SuccessfulETHTransfer(nami, recipients, amounts);

        multisend.sendETH{value: amounts[0] + amounts[1] }(recipients, amounts);

        // Should succeed still
        assertEq(nami.balance, namiExpectedBalance1);
        assertEq(luffy.balance, defaultBalance + amounts[0] + amounts[1]);
    }

    function testNotEnoughETH() external {
        vm.prank(nami);
        vm.expectRevert();
        multisend.sendETH{value: amounts[0]}(recipients, amounts);
    }

    function testNotEnoughTokens() external {
        vm.startPrank(nami);

        dai.approve(address(multisend), defaultBalance + 1);
        weth.approve(address(multisend), defaultBalance + 1);

        vm.expectRevert();
        multisend.sendTokens(tokenRecipients, tooHighAmounts, address(dai));
        vm.stopPrank;
    }

    function testArraysNotEqualLength() external {
        vm.startPrank(nami);

        dai.approve(address(multisend), defaultBalance + 1);
        weth.approve(address(multisend), defaultBalance + 1);

        vm.expectRevert();
        multisend.sendTokens(tokenRecipients, biggerAmountsArray, address(dai));
        vm.stopPrank;

        vm.expectRevert();
        multisend.sendETH{value: amounts[0] + amounts[1] }(recipients, biggerAmountsArray);

        vm.stopPrank;
    }

    function testUnsuccessfulETHTransfer() external {
        address payable CONTRACT_NOT_PAYABLE = payable(vm.addr(3));
        vm.etch(address(CONTRACT_NOT_PAYABLE), "By adding any arbitrary bytecode to the address, it will no longer be payable");

        recipients = [CONTRACT_NOT_PAYABLE, CONTRACT_NOT_PAYABLE];
        vm.prank(nami);
        vm.expectRevert();
        multisend.sendETH{value: amounts[0] + amounts[1]}(recipients, amounts);
    }

    // ========================================= HELPER FUNCTIONS =========================================

    /// @dev Creates an ERC20 test token, labels its address.
    function createERC20(string memory name) internal returns (MockToken token) {
        token = new MockToken(name, name);
        vm.label(address(token), name);
    }

    /// @dev Generates a user, labels its address, and funds it with test assets.
    function createUser(string memory name) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.label(user, name);
        vm.deal(user, defaultBalance);

        for (uint256 index = 0; index < tokens.length; index++) {
            deal(address(tokens[index]), user, defaultBalance);
        }

        return user;
    }
}