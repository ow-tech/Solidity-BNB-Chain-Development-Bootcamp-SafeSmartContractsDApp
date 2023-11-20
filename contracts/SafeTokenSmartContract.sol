// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/Math.sol";
// import "contracts/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";




//ERC Token Standard #20 Interface



contract SafeTokenSmartContract  {
  IERC20 public token;
   

  address private owner;
   constructor(
       
   
    ) {
        owner =msg.sender;
       
    }


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
    
   modifier onlyOwner () {
    require(msg.sender ==owner, "Only Owner can call this method");
     _;
   }

   modifier onlyCurrentUserAndHasAccount() {
    User storage currentUser = users[msg.sender];
        require(hasAccount[msg.sender], "Caller must have an account");
        require(msg.sender == owner || msg.sender == currentUser.wallet, "Not authorized to call this function");
        _;
    }

 


    function createNewUser() external {
        // check if user already exists
        require(!hasAccount[msg.sender], "User already has an account");

        User memory newUser =User( payable(msg.sender),0 wei, 0 ,0,false);
        users[msg.sender] = newUser;
        userAddresses.push(msg.sender);
          hasAccount[msg.sender] = true;
      
    }

    
        function depositEarnest(uint256 amount) external payable onlyCurrentUserAndHasAccount{
            require(hasAccount[msg.sender], "Create Account to continue");
            // require(msg.value >0, "Tokens need to be more than 0");
            User storage currentUser = users[msg.sender];
            require( !currentUser.locked, "Unlock tokens");
            bool sent = token.transferFrom(msg.sender, address(this), amount);
              require(sent, "Token transfer failed");
            currentUser.lockedTimestamp=block.timestamp;
             
           currentUser.accruedRewards += msg.value;
            emit TokensDeposited(msg.sender,msg.value );         
}

       function depositEarnestV2() external payable onlyCurrentUserAndHasAccount{
            require(hasAccount[msg.sender], "Create Account to continue");
            // require(msg.value >0, "Tokens need to be more than 0");
            User storage currentUser = users[msg.sender];
            require( !currentUser.locked, "Unlock tokens");
            bool sent = token.transferFrom(msg.sender, address(this), msg.value);
              require(sent, "Token transfer failed");
            currentUser.lockedTimestamp=block.timestamp;
             
           currentUser.accruedRewards += msg.value;
            emit TokensDeposited(msg.sender,msg.value );         
}
        function depositEarnestTransferTo(address _to, uint256 amount) external payable onlyCurrentUserAndHasAccount{
            require(hasAccount[msg.sender], "Create Account to continue");
            // require(msg.value >0, "Tokens need to be more than 0");
            User storage currentUser = users[msg.sender];
            require( !currentUser.locked, "Unlock tokens");
            bool sent = token.transfer(_to, amount);
              require(sent, "Token transfer failed");
            currentUser.lockedTimestamp=block.timestamp;
             
           currentUser.accruedRewards += amount;
            emit TokensDeposited(msg.sender,amount );         
}

 
    // Fallback function to receive ether
    receive() external payable {
        emit TokensDeposited(msg.sender, msg.value);
    }

   

    function lockAndUnlock(bool _lock) external onlyCurrentUserAndHasAccount {
             require(hasAccount[msg.sender], "Create Account to continue");
           
        User storage currentUser = users[msg.sender];
            require(currentUser.accruedRewards >0, "Tokens need to be more than 0 to Lock");
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
        
            currentUser.accruedRewards = resultAdd;
            currentUser.unlockedTimeStamp = block.timestamp;
              currentUser.locked = _lock;
          }
        emit TokensUnlocked(msg.sender, currentUser.locked);

    }

    // calculate Rewards

    function showUserRewards() public view returns(uint256){
             require(hasAccount[msg.sender], "Create Account to continue");
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

  if(resultSub > 86400)   {
    (bool overflowsDivShowUserRewards, uint256 resultDiv)=getDivsion(resultSub, 86400);// Number of seconds in a day (24 hours * 60 minutes * 60 seconds)
    
    uint256 numberOfDays = resultDiv;
            
       uint256 totalAmount = currentUser.accruedRewards;
      uint256 rewards = 0;
        for (uint256 i = 0; i < numberOfDays; i++) {
         
          uint256 interest =getMulDiv(totalAmount, (1e16), (1e18)); // 1% of totalAmount in wei
          (bool overflowsAddShowUserRewards, uint256 resultAdd) =getAddition( totalAmount, interest);


        totalAmount =resultAdd; 
        (bool overflowsAdd2, uint256 resultAdd2) =getAddition(rewards, interest);

        rewards =resultAdd2;
        }
   
    // emit AccruedRewards(msg.sender, rewards);
    return rewards;

  }
  return 0;
    
    }

    function getAllUsers()  public view  returns(User[] memory) {
         uint256 numberOfUsers = userAddresses.length;
         User[] memory allUsers = new User[](numberOfUsers);

         for( uint256 i =0; i< numberOfUsers; i++){
            address userAddress = userAddresses[i];
            allUsers[i] =users[userAddress];
         }
        return allUsers;
    }

    function getContractBalance() public view  returns(uint256) {
      return address(this).balance;
    }


}