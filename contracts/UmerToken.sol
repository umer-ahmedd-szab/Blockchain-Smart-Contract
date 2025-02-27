// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract UmerToken is ERC20, ERC20Permit
{
    constructor() ERC20("UmerToken", "UT") ERC20Permit("UmerToken") {}

    
}