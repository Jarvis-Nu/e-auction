// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Auction contract for trading items with bids
 * @dev This contract allows users to create auctions, place bids, and finalize auctions.
 */
contract Auction is ReentrancyGuard {
  struct AuctionItem {
    uint256 itemId;
    address payable seller;
    uint256 startingPrice;
    uint256 endAuctionTime;
    bool sold;
  }

  event AuctionCreated(
    uint256 indexed itemId,
    address indexed seller,
    uint256 startingPrice,
    uint256 endAuctionTime
  );

  event AuctionSuccessful(
    uint256 indexed itemId,
    address winner,
    uint256 finalPrice
  );

  event AuctionCancelled(uint256 indexed itemId);

  mapping(uint256 => AuctionItem) public auctionItems;
  uint256 public auctionCounter;

  /**
   * @dev Modifier to ensure that only the seller of an auction item can call a function.
   * @param _itemId The ID of the auction item.
   */
  modifier onlySeller(uint256 _itemId) {
    require(msg.sender == auctionItems[_itemId].seller, "Only seller can call this");
    _;
  }

  /**
   * @dev Create a new auction item.
   * @param _startingPrice The starting price for the auction.
   * @param _endAuctionTime The duration of the auction (in seconds).
   */
  function createAuction(uint256 _startingPrice, uint256 _endAuctionTime) external {
    auctionCounter++;
    auctionItems[auctionCounter] = AuctionItem(
      auctionCounter,
      payable(msg.sender),
      _startingPrice,
      block.timestamp + _endAuctionTime,
      false
    );
    
    emit AuctionCreated(
      auctionCounter, 
      msg.sender, 
      _startingPrice,
      block.timestamp + _endAuctionTime
    );
  }

  /**
   * @dev Place a bid on an auction item.
   * @param _itemId The ID of the auction item.
   */
  function bid(uint256 _itemId) external payable nonReentrant {
    AuctionItem storage auction = auctionItems[_itemId];

    require(block.timestamp < auction.endAuctionTime, "Auction has ended");
    require(!auction.sold, "Item has already been sold");
    require(msg.value > auction.startingPrice, "Must bid higher than starting price");

    auction.seller.transfer(auction.startingPrice);
    auction.startingPrice = msg.value; 
    auction.seller = payable(msg.sender);
  }

  /**
   * @dev Cancel an auction item.
   * @param _itemId The ID of the auction item.
   */
  function cancelAuction(uint256 _itemId) external onlySeller(_itemId) {
    AuctionItem storage auction = auctionItems[_itemId];
    require(!auction.sold, "Item has already been sold");

    emit AuctionCancelled(_itemId);
    delete auctionItems[_itemId];
    auction.seller.transfer(auction.startingPrice);
  }

  /**
   * @dev Finalize an auction and transfer the winning bid to the seller.
   * @param _itemId The ID of the auction item.
   */
  function endAuction(uint256 _itemId) external nonReentrant {
    AuctionItem storage auction = auctionItems[_itemId];

    require(block.timestamp >= auction.endAuctionTime, "Auction has not ended yet");
    require(!auction.sold, "Item has already been sold");

    auction.sold = true;
    auction.seller.transfer(auction.startingPrice);

    emit AuctionSuccessful(_itemId, auction.seller, auction.startingPrice);
  }
}
