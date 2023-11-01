// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SafeTokenSmartContract {

     using SafeMath for uint256;

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
    mapping (address => bool) public hasAccount;
    address[] public userAddresses;


    event TokensDeposited(address indexed user, uint256 amount);
    event TokensUnlocked(address indexed user,bool);
    // event AccruedRewards(address indexed user, uint256 amount);

       address private owner;

    constructor() {
        owner = msg.sender;
    }

   modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
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

    // all tokens will remain locked for a max period of 1 year. if unlocked before
    //  a year gets completed, they daily rewards will be calculated
    // if 1 year, and user does not unclock tokens, will automatically unlock the tokens

    function depositTokensAndLock(uint256 _tokens) external onlyOwner {
        require(hasAccount[msg.sender], "Create Account to continue");
        User storage currentUser = users[msg.sender];
        require( !currentUser.locked, "Unlock tokens");
        require(_tokens >= 100, "Minimum deposit requirement is 100 tokens");
         currentUser.tokens += _tokens;
        currentUser.lokedTimestamp=block.timestamp;
         emit TokensDeposited(msg.sender, _tokens);

    }

    // lock and unlock tokens

    function lockAndUnlock(bool _lock) external onlyOwner {
        User storage currentUser = users[msg.sender];
          if(_lock && !currentUser.locked){
    
            currentUser.locked =_lock;
            currentUser.lokedTimestamp=block.timestamp;
            currentUser.unlockedTimeStamp=0;

          }else if(!_lock && currentUser.locked){
            currentUser.locked = _lock;
            currentUser.unlockedTimeStamp = block.timestamp;
           
            // calculate rewards and add them to tokens
               uint256 rewards = showUserRewards();
        
            // Add rewards to tokens
            currentUser.tokens += rewards;
             
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
 
    uint256 secondsInDay = 86400; // Number of seconds in a day (24 hours * 60 minutes * 60 seconds)
        
            uint256 numberOfDays = (currentunlockedTimeStamp - currentUser.lokedTimestamp) / secondsInDay;
            
       uint256 totalAmount = currentUser.tokens;
      uint256 rewards = 0;
        for (uint256 i = 0; i < numberOfDays; i++) {
            // Calculate interest for the current day 1%
          uint256 interest = totalAmount.mul(1e16).div(1e18); // 1% of totalAmount in wei
        totalAmount = totalAmount.add(interest);
        rewards = rewards.add(interest);
        }
   
    // emit AccruedRewards(msg.sender, rewards);
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