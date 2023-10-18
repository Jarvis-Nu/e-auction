// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

// Bid contract
contract Bid {

  // Submit private bid
  function submitBid(uint bidAmount) external {
    
    // Encrypt bid
    uint encryptedBid = encryptBid(bidAmount);

    // Emit encrypted bid event
    emit BidSubmitted(encryptedBid);
  }

}