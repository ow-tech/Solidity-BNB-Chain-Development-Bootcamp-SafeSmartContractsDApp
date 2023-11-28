// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SafeTokenSmartContract is ERC20 {

    mapping(address => uint256) public staked;
    mapping(address => uint256) private stakedFromTS;
    mapping(address => uint256) public rewards;
    
    constructor() ERC20("Fixed Staking", "FIX") {
        _mint(msg.sender,1000000000000000000);
    }

// for every staked tokens earns 1 token after a year
    function lockTokens(uint256 amount) external {
        require(amount > 0, "amount is <= 0");
        require(balanceOf(msg.sender) >= amount, "balance is <= amount");
        _transfer(msg.sender, address(this), amount);
        if (staked[msg.sender] > 0) {
            uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];
           rewards[msg.sender]+=staked[msg.sender] * secondsStaked / 3.154e7;
        }
        stakedFromTS[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;
    }

    function unLockTokens(uint256 amount) external {
        require(amount > 0, "amount is <= 0");
        require(staked[msg.sender] >= amount, "amount is > staked");
          uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];
        rewards[msg.sender]+=staked[msg.sender] * secondsStaked / 3.154e7;
        staked[msg.sender] -= amount;
         stakedFromTS[msg.sender] = block.timestamp;
        _transfer(address(this), msg.sender, amount);
    }

    function calculateReward() public view returns(uint256) {
        require(staked[msg.sender] > 0, "staked is <= 0");
        uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];
        uint256 currentRewards = rewards[msg.sender]+ staked[msg.sender] * secondsStaked / 3.154e7;
        return currentRewards;
    }

}