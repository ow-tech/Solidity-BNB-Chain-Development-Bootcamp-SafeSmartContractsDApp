// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenContract is ERC20 {
    constructor() ERC20("MyToken", "MT") {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
    }
    function decimals() public pure override returns (uint8){
        return 0;
    }
}