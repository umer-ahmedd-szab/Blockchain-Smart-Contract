// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {
    constructor(address recipient) ERC20("tokenA", "ATK") {
        _mint(recipient, 1000000 * 10 ** decimals());
    }
}

contract TokenB is ERC20 {
    constructor(address recipient) ERC20("tokenB", "BTK") {
        _mint(recipient, 1000000 * 10 ** decimals());
    }
}

contract Swapping {
    IERC20 tokenA;
    IERC20 tokenB;
    uint rate;
    event swapped(address tokenA, address tokenB, uint rate);
    address public owner;

    constructor (address _tokenA, address _tokenB, uint _rate) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        rate = _rate;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function setRate(uint newRate) external onlyOwner {
        require(newRate > 0, "Rate must be greater than 0");
        rate = newRate;
    }

    function swapFunc(uint amount) external {
        require(amount > 0, "Amount should be greater than 0");

        tokenA.transferFrom(msg.sender, address(this), amount*rate);
        //                                              100 * 10 = 1000
        tokenB.transfer(msg.sender, amount);
        //                          100
        emit swapped(address(tokenA), address(tokenB), rate);
    }

    function getTokenABalance() public view returns (uint256) {
        return tokenA.balanceOf(address(this));
    }

    function getTokenBBalance() public view returns (uint256) {
        return tokenB.balanceOf(address(this));
    }
}