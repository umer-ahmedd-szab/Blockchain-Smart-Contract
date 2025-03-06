// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

contract dummyToken {

    mapping (address => uint) public balanceOf;
    uint public totalSupply;
    uint public mintCap = 1000;

    function mint(uint256 amount) public returns (bool) {
        require(totalSupply <= mintCap, "Amount larger than cap");
        require(amount > 0, "Amount must be greater than zero");
        totalSupply += amount;  
        balanceOf[msg.sender] += amount;  

        return true;
    }


    function deposit(uint amount) public {
        balanceOf[msg.sender] = amount;
    }

    function transfer(address sender, address recipient, uint amount) public returns (bool) {
        require(balanceOf[sender] >= amount, "Not enough balance");
        require(recipient != address(0), "Zero address detected");
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }
}
