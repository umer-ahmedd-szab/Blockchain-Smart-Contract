// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {

    address public bridge;

    constructor() ERC20("TestToken", "TTK") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
        bridge = msg.sender; // Set deployer as default bridge/admin
    }

    modifier onlyBridge() {
        require(msg.sender == bridge, "Not authorized");
        _;
    }

    function setBridge(address _bridge) external onlyBridge {
        bridge = _bridge;
    }

    function burn(address from, uint amount) external onlyBridge {
        _burn(from, amount);
    }

    function mint(address to, uint amount) external onlyBridge {
        _mint(to, amount);
    }
}

contract TokenBridge {
    address public admin;
    TestToken public token;

    // Track amount locked per user (on Chain A)
    mapping(address => uint) public locked;

    event TokenLocked(address indexed from, uint amount, string targetChain, address targetAddress);
    event TokenMinted(address indexed to, uint amount);
    event TokenBurned(address indexed from, uint amount, string targetChain, address targetAddress);
    event TokenReleased(address indexed to, uint amount);

    constructor(address _token) {
        admin = msg.sender;
        token = TestToken(_token);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    // Step 1: Lock tokens in Chain A
    function lockTokens(uint amount, string memory targetChain, address targetAddress) external {
        require(amount > 0, "Amount must be greater than 0");
        token.transferFrom(msg.sender, address(this), amount);
        locked[msg.sender] += amount;
        emit TokenLocked(msg.sender, amount, targetChain, targetAddress);
    }

    // Step 2: Mint tokens on Chain B
    function mintFromOtherChain(address to, uint amount) external onlyAdmin {
        require(locked[to] >= amount, "Insufficient locked tokens in Chain A");
        token.mint(to, amount);
        emit TokenMinted(to, amount);
    }

    // Step 3: Burn tokens on Chain B (when moving back)
    function burnToBridgeBack(uint amount, string memory targetChain, address targetAddress) external {
        token.burn(msg.sender, amount);
        emit TokenBurned(msg.sender, amount, targetChain, targetAddress);
    }

    // Step 4: Release tokens on Chain A
    function releaseTokens(address to, uint amount) external onlyAdmin {
        token.transfer(to, amount);
        locked[to] -= amount;
        emit TokenReleased(to, amount);
    }

    function setAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }
}