// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract lecture2
{
    receive() external payable { }
    address payable owner = payable(msg.sender);
    uint public contractBalance = address(this).balance;

    function sendEther() public payable {
        require(msg.value >= 1 ether, "Not enough money");
        contractBalance = address(this).balance;
        payable(owner).transfer(contractBalance);
    }


//  address payable public owner;

    // constructor() {
    //     owner = payable(msg.sender); 
    // }

    // // Function to receive Ether
    // function deposit() external payable {
    //     require(msg.value > 0, "Must send some Ether");
    // }

    // // Withdraw function, only callable by the owner
    // function withdraw() external {
    //     require(msg.sender == owner, "Not the owner");
    //     require(address(this).balance > 0, "No balance to withdraw");

    //     owner.transfer(address(this).balance);
    // }

    // // Get contract balance
    // function getBalance() external view returns (uint) {
    //     return address(this).balance;
    // }   
}