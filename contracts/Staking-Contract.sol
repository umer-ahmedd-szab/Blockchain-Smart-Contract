// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Stake is ERC20 {
    constructor(address recipient) ERC20("Stake", "STK") {
        _mint(recipient, 100000 * 10 ** decimals());
    }

   
}

contract staking {

    Stake public token;

    mapping(address => uint256) public stakes;

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        token.transfer(address(this), amount);
        stakes[msg.sender] += amount;
    }

    function withdraw() external {
        uint256 amount = stakes[msg.sender];
        require(amount > 0, "No funds staked");
        uint256 reward = (amount * 5) / 100;
       
        token.transfer(address(this), amount + reward);
    }
}