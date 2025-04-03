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

    constructor (address _tokenA, address _tokenB, uint _rate) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        rate = _rate;
    }

    function swapFunc(uint amount) external {
        require(amount > 0, "Amount should be greater than 0");
        tokenA.transferFrom(msg.sender, address(this), amount*rate);
        tokenB.transfer(msg.sender, amount);
        emit swapped(address(tokenA), address(tokenB), rate);
    }
}