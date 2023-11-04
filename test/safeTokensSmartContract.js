const { expect } = require("chai");
const { ethers } = require("hardhat");

// const SafeTokenSmartContract = require("../artifacts/contracts/SafeTokenSmartContract.sol/SafeTokenSmartContract.json");

describe("SafeTokenSmartContract", () => {
  let SafeTokenSmartContract;
  let owner;
  let user;

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    owner = accounts[0];
    user = accounts[1];

    SafeTokenSmartContract = await ethers.getContractFactory(
      "SafeTokenSmartContract"
    );

    // deploy contracts
    contract = await SafeTokenSmartContract.deploy();
  });

  it("should allow users to create an account", async () => {
    const tx = await contract.createNewUser("Alice");
    await tx.wait();

    const user = await contract.users(owner.address);
    expect(user.name).to.equal("Alice");
    expect(user.wallet).to.equal(owner.address);
    expect(user.accruedRewards).to.equal(0);
    expect(user.lockedTimestamp).to.equal(0);
    expect(user.unlockedTimeStamp).to.equal(0);
    expect(user.locked).to.be.false;
  });

  it("should allow users to deposit tokens", async () => {
    let balance;
    await contract.createNewUser("Alice");

    const depositAmount = ethers.parseEther("100");
    const tx = await contract
      .connect(owner)
      .depositEarnest({ value: depositAmount });
    await tx.wait();
    balance = await ethers.provider.getBalance(contract.target);

    const user = await contract.users(owner.address);

    expect(balance).to.equal(depositAmount);
    expect(user.locked).to.be.false;
    expect(user.lockedTimestamp).to.not.equal(0);
  });

  it("should allow users to unlock tokens and calculate rewards", async () => {
      await contract.createNewUser("Alice");
      const depositAmount = ethers.parseEther("100");
      await contract.connect(owner).depositEarnest({value:depositAmount});
      let user;
      const unlockTx = await contract.connect(owner).lockAndUnlock(false);
      await unlockTx.wait();

      user = await contract.users(owner.address);
      expect(user.locked).to.be.false;

      
      const lockTx = await contract.connect(owner).lockAndUnlock(true);
      await lockTx.wait();
      user = await contract.users(owner.address);
      expect(user.locked).to.be.true;
      console.log('user :', user)
      const un_lockTx = await contract.connect(owner).lockAndUnlock(false);
     
      await un_lockTx.wait();

    //   user = await contract.users(owner.address);
    //   console.log(user)
    //   expect(user.locked).to.be.false;

    //   const rewards = await contract.connect(owner).showUserRewards();
    //   console.log("Accrued rewards: ", ethers.formatEther(rewards));
  });
});
