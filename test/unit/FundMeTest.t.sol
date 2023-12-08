// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    // What can we do to work with addresses outside our system?
    // 1. Unit
    //     - Testing a specific part of our code
    // 2. Integration
    //     - Testing how our code works with other parts of our code
    // 3. Forked
    //     - Testing our code on a simulated real environment
    // 4. Staging
    //     - Testing our code in a real environment that is not production

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // Hey, the next line should revert!
        // assert(This transaction fails/revert)
        fundMe.fund(); // send 0 value
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next transaction will be sent by USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Methodology for working with tests
        // Think of these pattern whenever working with a test
        // 1. Arrange - setting up the test
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // 2. Act - do the action that we want to test
        vm.prank(fundMe.getOwner()); // cost: 200 gas
        fundMe.withdraw();

        // 3. Assert - assert the test
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // 1. Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // don't do 0, sometimes the 0 address reverts
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank (new address)
            // vm.deal (new address)
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // creating addresses to fund the fundMe(funders)
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // 2. Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // 3. Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // 1. Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // don't do 0, sometimes the 0 address reverts
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank (new address)
            // vm.deal (new address)
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // creating addresses to fund the fundMe(funders)
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // 2. Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // 3. Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
