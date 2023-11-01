// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SafeTokenSmartContract {

    // create user. User struct, mapping user address for easy access

    struct User {
        string name;
        address payable wallet;
        uint256  tokens;
        // uint256 rewards;
        uint256 lokedTimestamp;
        uint256 unlockedTimeStamp;
        bool locked;
        
    }

    mapping (address => User) public users;
    address[] public userAddresses;
  // Internal function to get the current user's storage reference
    function _getCurrentUser() private view returns (User storage) {
        return users[msg.sender];
    }


    function createNewUser(string memory _name) public{
        User memory newUser =User(_name, payable(msg.sender),0 ether, 0 ,0, false);
        users[msg.sender] = newUser;
        userAddresses.push(msg.sender);
      

    }

    // all tokens will remain locked for a period of 1 year to attain rewards. if unlocked before
    //  a year gets completed, they loose their accrued rewards
    // if 1 year, and user does not unclock tokens, we continue with compounded interest to
    //  the new princpal.Hence for loked tokens to realise rewards, they must undergo a full circle of 12 months.

    function depositTokensAndLock(uint256 _tokens) public{
        User storage currentUser = _getCurrentUser();
        currentUser.tokens = _tokens;
        currentUser.locked =true;
        currentUser.lokedTimestamp=block.timestamp;

    }

    // lock and unlock tokens

    function lockAndUnlock(bool _lock) public {
          User storage currentUser = _getCurrentUser();
          if(_lock && !currentUser.locked){
            currentUser.locked =_lock;
            currentUser.lokedTimestamp=block.timestamp;
            currentUser.unlockedTimeStamp=0;

          }else if(!_lock && currentUser.locked){
            currentUser.locked = _lock;
            currentUser.unlockedTimeStamp = block.timestamp;
          }

    }

    // calculate Rewards

    function showUserRewards() public view returns(uint256){
        User memory currentUser =_getCurrentUser();

        uint256 currentunlockedTimeStamp;

        // check if looked is true. if true, unlocked time stamp is block.timestamp
        if(currentUser.locked){
            currentunlockedTimeStamp = block.timestamp;
        } else{
            currentunlockedTimeStamp = currentUser.unlockedTimeStamp;
        
        }
 
            uint256 secondsInYear = 31556952; // Average number of seconds in a year (365.25 days)
        
            uint256 numberOfYears = (currentunlockedTimeStamp - currentUser.lokedTimestamp) / secondsInYear;
            
       uint256 totalAmount = currentUser.tokens;
       uint256 rewards;
        for (uint256 i = 0; i < numberOfYears; i++) {
            // Calculate interest for the current year
            uint256 interest = (totalAmount * 2) / 100;
            // Add the interest to the total amount
            totalAmount += interest;
            rewards +=interest;
        }

        return rewards;


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