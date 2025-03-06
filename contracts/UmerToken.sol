// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UmerToken is ERC20 {
    constructor(address recipient) ERC20("UmerToken", "UTK") {
        _mint(recipient, 10000 * 10 ** decimals());
    }
}
