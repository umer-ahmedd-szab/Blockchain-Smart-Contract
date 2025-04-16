/*
INSTRUCTIONS TO EXECUTE:
1-Deploy an ERC20 token.
2-Deploy ERC20Auction.
3-Approve ERC20Auction from ERC20
4-List ERC20 token with desired parameters with listTokens function.(Every listTokens user must have to approve
  the contract to use the tokens).listTokens on ERC20Auction will transfer the tokens to the contract.
4-Execute buyTokens on ERC20Auction.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
    function transfer(address to, uint amount) external returns (bool);
}

contract ERC20Auction {
    struct Listing {
        address seller;
        IERC20 token;
        uint pricePerToken; // ETH per token (e.g., 0.01 ether)
        uint remainingAmount;
        uint deadline; // Timestamp for listing expiration to prevent front-running
    }
    
    Listing[] public listings;
    
    event TokensListed(uint indexed listingId, address indexed seller, address indexed tokenAddress, uint amount, uint pricePerToken);
    event TokensPurchased(uint indexed listingId, address indexed buyer, uint amount, uint totalPrice);
    
    
    function listTokens(IERC20 token, uint totalAmount, uint pricePerToken) public returns (uint) {
        require(address(token) != address(0), "Invalid token address");
        require(totalAmount > 0, "Amount must be greater than zero");
        require(pricePerToken > 0, "Price must be greater than zero");
        
        // Transfer tokens from seller to contract
        bool success = token.transferFrom(msg.sender, address(this), totalAmount);
        require(success, "Token transfer failed");
        
        // Create new listing
        uint deadline = block.timestamp + 7 days; 
        
        listings.push(Listing({
            seller: msg.sender,
            token: token,
            pricePerToken: pricePerToken,
            remainingAmount: totalAmount,
            deadline: deadline
        }));
        
        uint listingId = listings.length - 1;
        
        emit TokensListed(listingId, msg.sender, address(token), totalAmount, pricePerToken);
        
        return listingId;
    }
   
    function buyTokens(uint listingId, uint tokenAmount) external payable {
        require(listingId < listings.length, "Listing does not exist");
        Listing storage listing = listings[listingId];
        
        require(block.timestamp < listing.deadline, "Listing has expired");
        require(tokenAmount > 0, "Amount must be greater than zero");
        require(tokenAmount <= listing.remainingAmount, "Not enough tokens available");
        
        // Calculate total price and check sufficient payment
        uint totalPrice = tokenAmount * listing.pricePerToken;
        require(msg.value >= totalPrice, "Insufficient ETH sent");
        
        // Update listing
        listing.remainingAmount -= tokenAmount;
        
        // Transfer tokens to buyer
        bool tokenTransferSuccess = listing.token.transfer(msg.sender, tokenAmount);
        require(tokenTransferSuccess, "Token transfer to buyer failed");
        
        // Transfer ETH to seller
        (bool ethTransferSuccess, ) = listing.seller.call{value: totalPrice}("");
        require(ethTransferSuccess, "ETH transfer to seller failed");
        
        // Refund excess ETH if any
        uint refundAmount = msg.value - totalPrice;
        if (refundAmount > 0) {
            (bool refundSuccess, ) = msg.sender.call{value: refundAmount}("");
            require(refundSuccess, "Failed to refund excess ETH");
        }
        
        emit TokensPurchased(listingId, msg.sender, tokenAmount, totalPrice);
    }
    
    
    function getListingCount() external view returns (uint) {
        return listings.length;
    }
    
  
}

