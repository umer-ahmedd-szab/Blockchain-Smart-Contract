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

contract ERC20Auction {
    struct Listing {
        address seller;
        IERC20 token;
        uint pricePerToken;
        uint remainingAmount;
    }

    Listing[] public listings;
    MyToken public myToken;

    constructor(address _tokenAddress) {
        myToken = MyToken(_tokenAddress); 
    }

    event list (address _sender, uint _totalAmount, uint _pricePerToken);

    function listToken (IERC20 token, uint totalAmount, uint pricePerToken)  external  {
        // require(totalAmount > 0 && totalAmount <= address(this).balance, "Not enough balance");
        myToken.transferFrom(msg.sender,address(this), totalAmount);
        listings.push(Listing({
            seller: msg.sender,
            token: token,
            pricePerToken: pricePerToken,
            remainingAmount: totalAmount}));    

        emit list(msg.sender, totalAmount, pricePerToken);    
    }

    function buyToken (uint lisitngId, uint tokenAmount) external payable {
        myToken.transfer(msg.sender, tokenAmount);
        listings[lisitngId].remainingAmount -= tokenAmount;
    }

    function getListCount() view public returns (uint) {
        return listings.length;
    }

    function getBalanceOfContract() public view returns (uint) {
        return myToken.balanceOf(address(this));
    }
    
}