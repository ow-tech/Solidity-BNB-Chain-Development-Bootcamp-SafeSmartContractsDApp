// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SafeTokenSmartContract is ReentrancyGuard  {

    IERC20 public stakingToken;
    // IERC20 public rewardToken;

    
    
    mapping(address => uint256) public staked;
    mapping(address => uint256) private stakedFromTS;
    mapping(address => uint256) public rewards;
    
    event Staked(address indexed user, uint256 indexed amount);
    event RewardsClaimed(address indexed user, uint256 indexed amount);

    constructor(address _stakingToken) {
        stakingToken = IERC20(_stakingToken);
        // rewardToken = IERC20(_rewardToken);
    }


      function lockTokens(uint256 amount) external payable {
    require(amount > 0, "amount is <= 0");
    bool success = stakingToken.transferFrom(msg.sender, address(this), amount);
    if (staked[msg.sender] > 0) {
        calculateReward();
    }
    stakedFromTS[msg.sender] = block.timestamp;
    staked[msg.sender] += amount;
    require(success, "Transfer failed");
}

    function unLockTokens(uint256 amount) external {
        require(amount > 0, "amount is <= 0");
        require(staked[msg.sender] >= amount, "amount is > staked");
          calculateReward();
        staked[msg.sender] -= amount;
         stakedFromTS[msg.sender] = block.timestamp;
         bool success = stakingToken.transfer( msg.sender, amount);
          require(success, "Transfer failed");
    }

    function calculateReward() public {
        require(staked[msg.sender] > 0, "staked is <= 0");
        uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];
      rewards[msg.sender]+= staked[msg.sender] * secondsStaked /10;
      stakedFromTS[msg.sender] = block.timestamp;
     emit RewardsClaimed (msg.sender,rewards[msg.sender] );
       
    }

}

}