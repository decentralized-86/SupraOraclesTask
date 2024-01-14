// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {MultiSignWallet} from "../contracts/MultiSignWallet.sol";

/**
 * @title MultiSignWalletTest
 * @dev Test suite for the MultiSignWallet contract.
 * This suite checks all the functionalities of MultiSignWallet, 
 * ensuring that the contract works as expected.
 */
contract MultiSignWalletTest is Test {
    MultiSignWallet multiSignWallet;
    address[] owners;
    uint required;

    /**
     * @dev Sets up the test by deploying the MultiSignWallet contract
     * with predefined owners and a required approval count.
     */
    function setUp() public {
        owners = [address(1), address(2), address(3)];
        required = 2;
        multiSignWallet = new MultiSignWallet(owners, required);
    }

    /**
     * @dev Tests if the contract is initialized correctly with valid parameters.
     */
    function testContractInitialization() public {
        // Check if the required number of approvals is set correctly
        assertEq(multiSignWallet.required(), required, "Required approvals not set correctly");

        // Check if the number of owners is set correctly
        assertEq(multiSignWallet.ownerCount(), owners.length, "Owner count not set correctly");

        // Check if each owner is recognized by the contract
        for (uint i = 0; i < owners.length; i++) {
            assertTrue(multiSignWallet.isOwner(owners[i]), "Owner not recognized");
        }
    }

    /**
     * @dev Tests if initializing the contract with zero owners reverts.
     */
    function testFailInitializationWithZeroOwners() public {
        new MultiSignWallet(new address[](0), required);
    }
  
  /**
 * @dev Tests that initializing the contract with a required number of approvals greater than the number of owners reverts.
 * This test ensures that the contract constructor correctly handles invalid input parameters.
 */
function testFailInitializationWithInvalidRequired() public {
    // Attempt to initialize the contract with more required approvals than owners.
    // This should revert, as it's not a valid configuration for the MultiSignWallet.
    new MultiSignWallet(owners, owners.length + 1);
}

/**
 * @dev Tests the functionality of depositing Ether into the MultiSignWallet contract.
 * It verifies if the contract's balance is correctly updated after receiving a deposit.
 * This test ensures that the wallet can securely receive and account for Ether deposits.
 */
function testDepositFunctionality() public {
    // Define the amount of Ether to deposit into the contract
    uint256 depositAmount = 1 ether;

    // Provide this test contract with Ether for testing the deposit functionality
    vm.deal(address(this), depositAmount);

    // Execute the deposit by sending Ether to the MultiSignWallet contract
    payable(address(multiSignWallet)).transfer(depositAmount);

    // Assert that the contract's balance is correctly updated to reflect the deposit
    assertEq(address(multiSignWallet).balance, depositAmount, "Incorrect contract balance after deposit");
}

  /**
 * @dev Tests the ability of an owner to submit a transaction. 
 * It verifies that the transaction is correctly stored in the contract.
 */
function testSubmitTransactionByOwner() public {
    // Define the recipient, value, and data for the transaction
    address to = address(0x1234);
    uint value = 0.5 ether;
    bytes memory data = "";

    // Simulate submission of the transaction by the first owner
    vm.prank(owners[0]);
    multiSignWallet.submit(to, value, data);

    // Infer the transaction ID (assuming it's the first transaction)
    uint txId = 0;

    // Retrieve the submitted transaction from the contract
    (address transactionTo, uint transactionValue, bytes memory transactionData, bool executed) = multiSignWallet.transactions(txId);

    // Assert that the transaction details are correctly stored in the contract
    assertEq(transactionTo, to, "Incorrect transaction recipient");
    assertEq(transactionValue, value, "Incorrect transaction value");
    assertEq(transactionData, data, "Incorrect transaction data");
    assertEq(executed, false, "Transaction should not be executed yet");
}
  
  /**
 * @dev Tests the functionality of an owner approving a submitted transaction.
 * Verifies that the approval is correctly recorded in the contract, ensuring
 * that only valid owners can approve transactions.
 */
function testApproveTransactionByOwner() public {
    // Submit a transaction for approval
    vm.prank(owners[0]);
    multiSignWallet.submit(address(0x1234), 0.5 ether, "");

    // Assuming the first transaction's ID is 0
    uint txId = 0;

    // Approve the transaction by a different owner
    vm.prank(owners[1]);
    multiSignWallet.approve(txId);

    // Verify that the transaction approval is recorded in the contract
    bool isApproved = multiSignWallet.approved(txId, owners[1]);
    assertTrue(isApproved, "Transaction was not approved by the owner");
}

  
  /**
 * @dev Tests the ability of an owner to revoke their approval for a transaction.
 * Verifies that the revocation is correctly recorded in the contract.
 */
function testRevokeApprovalByOwner() public {
    // Submit a transaction and approve it
    vm.prank(owners[0]);
    multiSignWallet.submit(address(0x1234), 0.5 ether, "");
    uint txId = 0; // Assuming this is the first transaction

    vm.prank(owners[0]);
    multiSignWallet.approve(txId);

    // Revoke the approval for the transaction
    vm.prank(owners[0]);
    multiSignWallet.revoke(txId);

    // Verify that the approval has been successfully revoked
    bool isApproved = multiSignWallet.approved(txId, owners[0]);
    assertFalse(isApproved, "Approval was not revoked");
}

/**
 * @dev Tests that a non-owner cannot revoke approval for a transaction.
 * This test ensures that only owners can revoke approvals.
 */
function testFailRevokeApprovalByNonOwner() public {
    // Submit a transaction and approve it
    vm.prank(owners[0]);
    multiSignWallet.submit(address(0x1234), 0.5 ether, "");
    uint txId = 0; // Assuming this is the first transaction

    vm.prank(owners[0]);
    multiSignWallet.approve(txId);

    // Attempt to revoke the approval as a non-owner, which should fail
    address nonOwner = address(0xdead);
    vm.prank(nonOwner);
    multiSignWallet.revoke(txId); // This action should revert
}

/**
 * @dev Tests revoking approval for a non-existent transaction.
 * Ensures that revoking approval for an invalid transaction ID reverts.
 */
function testFailRevokeNonExistentTransaction() public {
    // Attempt to revoke approval for a non-existent transaction
    vm.prank(owners[0]);
    multiSignWallet.revoke(999); // This should fail as transaction 999 does not exist
}


}