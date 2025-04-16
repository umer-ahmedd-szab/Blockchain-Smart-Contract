// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(address recipient) ERC20("MyToken", "MTK") {
        _mint(recipient, 1000000 * 10 ** decimals());
    }
}

contract Auction {

    constructor(address _tokenAddress) {
        token = MyToken(_tokenAddress);
    }

    MyToken public token;

    struct Listing {
        uint256 id;
        string name;
        address owner;
        address winner;
        uint256 minBidAmount;
        uint256 highestBidValue;
        uint256 remainingTime;
        address[] bidders;
        mapping (address => uint256) bidAmounts;
    }

    mapping(uint256 => Listing) public listings; // A mapping to manage Listing structs by ID
    uint256 public nextListingId;

    function list(string memory _name, uint256 _minBidAmount) public {
        
       uint256 listingId = nextListingId++;
        
        Listing storage l = listings[listingId];
        l.id = listingId;
        l.name = _name;
        l.owner = msg.sender;
        l.minBidAmount = _minBidAmount;
        l.highestBidValue = 0;
        l.remainingTime = block.timestamp + 1 days;
    }

    function showListing(address _owner) public view returns (string memory _name, uint256 _minBidAmount, uint256 _highestBidValue, uint256 _remainingTime) {
        for (uint256 i = 0; i < nextListingId; i++) {
            if (_owner == listings[i].owner) {
                Listing storage l = listings[i];
                return (l.name, l.minBidAmount, l.highestBidValue, l.remainingTime);
            }
        }

        revert("Listing not found");
    }


    function getBidders(uint256 _id) public view returns (address[] memory, uint256[] memory) {
        Listing storage l = listings[_id];
        uint256 len = l.bidders.length;

        address[] memory bidderAddresses = new address[](len);
        uint256[] memory bidValues = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            address bidder = l.bidders[i];
            bidderAddresses[i] = bidder;
            bidValues[i] = l.bidAmounts[bidder];
        }

        return (bidderAddresses, bidValues);
    }


   function bid(uint256 _id, uint256 _bidValue) public {
        Listing storage l = listings[_id];

        require(_bidValue > l.minBidAmount, "Too Low Amount");

        if (l.highestBidValue == 0 || (_bidValue > l.highestBidValue && block.timestamp <= l.remainingTime)) {
            if (l.bidAmounts[msg.sender] == 0) {
                l.bidders.push(msg.sender); // track new bidder if he does not already exits
            }

            l.highestBidValue = _bidValue;
            l.bidAmounts[msg.sender] += _bidValue;
            token.transferFrom(msg.sender, address(this), _bidValue);
        }
    }

    function finalizeAuction(uint256 _id) public {
        Listing storage l = listings[_id];

        require(block.timestamp > l.remainingTime, "Auction not ended yet");
        require(l.winner == address(0), "Auction already finalized");

        address highestBidder;
        uint256 highestBid = 0;

        // Find highest bidder
        for (uint256 i = 0; i < l.bidders.length; i++) {
            address bidder = l.bidders[i];
            uint256 amount = l.bidAmounts[bidder];

            if (amount > highestBid) {
                highestBid = amount;
                highestBidder = bidder;
            }
        }

        require(highestBidder != address(0), "No bids placed");

        // Refund others
        for (uint256 i = 0; i < l.bidders.length; i++) {
            address bidder = l.bidders[i];
            if (bidder != highestBidder) {
                uint256 refund = l.bidAmounts[bidder];
                if (refund > 0) {
                    token.transfer(bidder, refund);
                    l.bidAmounts[bidder] = 0; // Prevent re-entrancy double-spend
                }
            }
        }

        // Send highest bid to the owner (seller)
        token.transfer(l.owner, highestBid);

        // Update ownership and record the winner
        l.owner = highestBidder;
        l.winner = highestBidder;

        // Clean up winner's bidAmount
        l.bidAmounts[highestBidder] = 0;
    }


    function getWinner(uint256 _id) public view returns (address) {
        return listings[_id].winner;
    }

    function getBalanceOfContract() public view returns (uint) {
        return token.balanceOf(address(this));
    }
}