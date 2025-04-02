// SPDX-License-Identifier: MIT

// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Stake is ERC20 {
    constructor(address recipient) ERC20("Stake", "STK") {
        _mint(recipient, 100000 * 10 ** decimals());
    }

   
}

/* 
1. first deploy your token (and copy the address of account)
2. then copy the address of this deployed token
3. then select the staking contract and paste the address of the deployed token
4. copy the address of the staking contract and go to the token deployed section => select "transfer" function and paste the address of the staking contract and mint (click transfer)
5. now go to the staking contract and enter a value in "stake"
6. copy the address of the account from which this was deployed and paste in "stakedAmount" function
*/

contract staking {

    Stake public token;

    mapping(address => uint256) public stakes;
    mapping(address => uint256) public stakeTime;

    constructor(address _tokenAddress) {
        token = Stake(_tokenAddress); 
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        token.transfer(address(this), amount);
        stakes[msg.sender] += amount;
        stakeTime[msg.sender] = block.timestamp;
    }

    function withdraw() external {
        require(block.timestamp >= (stakeTime[msg.sender]) + 1 seconds, "Reward is not available");

        uint256 amount = stakes[msg.sender];
        require(amount > 0, "No funds staked");

        uint256 claimTime = block.timestamp - stakeTime[msg.sender];
        claimTime = claimTime / 1 seconds;
        uint256 rewardAmount = ((amount * claimTime) / 100 ) + amount;
        stakes[msg.sender] -= amount;
       
        token.transfer(msg.sender, rewardAmount);
    }
}