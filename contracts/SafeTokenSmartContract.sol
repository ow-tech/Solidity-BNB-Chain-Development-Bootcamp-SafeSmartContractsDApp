// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/Math.sol";

contract SafeTokenSmartContract {

    using Math for uint256;
    // Arithematical operations
        function getAddition (uint256 x, uint256 y)internal pure returns(bool, uint256){
            (bool overflowsAdd, uint256 resultAdd) =  Math.tryAdd(x, y );
            return(overflowsAdd, resultAdd);
    }
        function getSubtraction(uint256 x, uint256 y)internal pure returns(bool, uint256){
         (bool overflowsSub, uint256 resultSub) = Math.trySub(x, y );
            return  ( overflowsSub, resultSub);
    }
    function getDivsion (uint256 x, uint256 y)internal pure returns(bool, uint256){
             (bool overflowsDiv, uint256 resultDiv)= Math.tryDiv(x, y );
              return (overflowsDiv, resultDiv);
    }
    function getMulDiv (uint256 x, uint256 y,uint256 z)internal pure returns(uint256){
        
            return  Math.mulDiv(x, y, z);
    }

    // create user. User struct, mapping user address for easy access

    struct User {
        string name;
        address payable wallet;
        uint256  accruedRewards;
        uint256 lockedTimestamp;
        uint256 unlockedTimeStamp;
        bool locked;
       
    }

    mapping (address => User) public users;
    mapping (address => bool) public hasAccount;
    address[] public userAddresses;


    event TokensDeposited(address indexed user, uint256 amount);
    event TokensUnlocked(address indexed user,bool);
    // event AccruedRewards(address indexed user, uint256 amount);
    
   modifier onlyOwner() {
     User storage currentUser = users[msg.sender];
        require(msg.sender == currentUser.wallet, "Only owner can call this function");
        _;
    }

 


    function createNewUser(string memory _name) external {
        // check if user already exists
        require(!hasAccount[msg.sender], "User already has an account");

        User memory newUser =User(_name, payable(msg.sender),0 wei, 0 ,0,false);
        users[msg.sender] = newUser;
        userAddresses.push(msg.sender);
          hasAccount[msg.sender] = true;
      
    }
    


        function depositEarnest() public payable onlyOwner{
            require(hasAccount[msg.sender], "Create Account to continue");
            User storage currentUser = users[msg.sender];
            require( !currentUser.locked, "Unlock tokens");
            require(msg.value + address(this).balance >= 10, " Amount Needs to be equal or more than 10" );
            currentUser.lockedTimestamp=block.timestamp;
            emit TokensDeposited(msg.sender, address(this).balance);
}

    // function depositTokensAndLock(uint256 _tokens) external onlyOwner {
       
    //     // require(_tokens >= 100, "Minimum deposit requirement is 100 tokens");
    //     // (bool overflowsAdddepositTokensAndLock1, uint256 resultAdd) =getAddition( currentUser.tokens, _tokens);
    //     // require(!overflowsAdddepositTokensAndLock1, "Due to Overflow in overflowsAdddepositTokensAndLock1, we cant proceed with the Opeartion");
    //     // currentUser.tokens =resultAdd;
    //     currentUser.lockedTimestamp=block.timestamp;
    //      emit TokensDeposited(msg.sender, _tokens);

    // }

    // lock and unlock tokens

    function lockAndUnlock(bool _lock) external onlyOwner {
        User storage currentUser = users[msg.sender];
          if(_lock && !currentUser.locked){
    
            currentUser.locked =_lock;
            currentUser.lockedTimestamp=block.timestamp;
            currentUser.unlockedTimeStamp=0;

          }else if(!_lock && currentUser.locked){
           
            // currentUser.unlockedTimeStamp = block.timestamp;
           
            // calculate rewards and add them to tokens
               uint256 rewards = showUserRewards();
        
            // Add rewards to tokens
            (bool overflowsAddTokens, uint256 resultAdd) =getAddition( currentUser.accruedRewards, rewards);
            require(!overflowsAddTokens, "Due to Overflow in overflowsAddTokens, we cant proceed with the Opeartion");
            currentUser.accruedRewards = resultAdd;
            currentUser.unlockedTimeStamp = block.timestamp;
              currentUser.locked = _lock;
          }
        emit TokensUnlocked(msg.sender, currentUser.locked);

    }

    // calculate Rewards

    function showUserRewards() public view returns(uint256){
       User memory currentUser = users[msg.sender];

        uint256 currentunlockedTimeStamp;

        // check if looked is true. if true, unlocked time stamp is block.timestamp
        if(currentUser.locked){
            currentunlockedTimeStamp = block.timestamp;
        } else{
            currentunlockedTimeStamp = currentUser.unlockedTimeStamp;
        
        }
 
    // uint256 secondsInDay = 86400; 
  (bool overflowsSub, uint256 resultSub) =getSubtraction(currentunlockedTimeStamp, currentUser.lockedTimestamp);
  require(!overflowsSub, "Due to OvoverflowsSubshowUserRewards erflow, we cant proceed with the Opeartion");
//   require(resultSub > 86400, 'Atleast Lock your Rewards for 24 hrs'); 
  if(resultSub > 86400)   {
    (bool overflowsDivShowUserRewards, uint256 resultDiv)=getDivsion(resultSub, 86400);// Number of seconds in a day (24 hours * 60 minutes * 60 seconds)
     require(!overflowsDivShowUserRewards, "Due to Overflow in overflowsDivShowUserRewards, we cant proceed with the Opeartion");
    uint256 numberOfDays = resultDiv;
            
       uint256 totalAmount = address(this).balance;
      uint256 rewards = 0;
        for (uint256 i = 0; i < numberOfDays; i++) {
            // Calculate interest for the current day 1%
          uint256 interest =getMulDiv(totalAmount, (1e16), (1e18)); // 1% of totalAmount in wei
          (bool overflowsAddShowUserRewards, uint256 resultAdd) =getAddition( totalAmount, interest);
        require(!overflowsAddShowUserRewards, "Due to Overflow in overflowsAddShowUserRewards, we cant proceed with the Opeartion");

        totalAmount =resultAdd; 
        (bool overflowsAdd2, uint256 resultAdd2) =getAddition(rewards, interest);
        require(!overflowsAdd2, "Due to Overflow, we cant proceed with the Opeartion");
        rewards =resultAdd2;
        }
   
    // emit AccruedRewards(msg.sender, rewards);
    return rewards;

  }
  return 0;
    

    }

    function getAllUsers() view public returns(User[] memory){
         uint256 numberOfUsers = userAddresses.length;
         User[] memory allUsers = new User[](numberOfUsers);

         for( uint256 i =0; i< numberOfUsers; i++){
            address userAddress = userAddresses[i];
            allUsers[i] =users[userAddress];
         }
        return allUsers;
    }
}