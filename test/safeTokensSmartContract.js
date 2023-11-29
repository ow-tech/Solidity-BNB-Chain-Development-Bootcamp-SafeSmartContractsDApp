const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SafeTokenSmartContract", function () {
  let SafeTokenSmartContract;
  let safeToken;
  let owner;
  let addr1; // address to represent a user
  let depositAmount = 100;
  beforeEach(async function () {
    SafeTokenSmartContract = await ethers.getContractFactory(
      "SafeTokenSmartContract"
    );
    [owner, addr1] = await ethers.getSigners();
    safeToken = await SafeTokenSmartContract.deploy();
  });

  it("Should lock tokens and calculate rewards", async function () {

    await safeToken.lockTokens(depositAmount);
    const stakedBalance = await safeToken.staked(owner.address);
    const rewardsBalance = await safeToken.rewards(owner.address);
  console.log('stakedBalance', stakedBalance)
    expect(stakedBalance).to.equal(depositAmount);
    expect(rewardsBalance).to.equal(0); // No rewards immediately after locking

    // Advance time by 1 day
    await ethers.provider.send("evm_increaseTime", [24 * 60 * 60 * 4]);

   await safeToken.calculateReward();
   const initialRewards = await safeToken.rewards(owner.address);
    // Advance time by 1 year
    await ethers.provider.send("evm_increaseTime", [60 * 60 * 24 * 365]);

    await safeToken.calculateReward();
    const finalRewards = await safeToken.rewards(owner.address);
    expect(finalRewards).to.be.above(initialRewards); // Rewards should increase over time
    expect(finalRewards).to.be.above(0); // Ensure final rewards are above 0
  });

  it("Should not allow unlocking more than staked amount", async function () {
    await safeToken.lockTokens(depositAmount);

    await expect(
      safeToken.unLockTokens(depositAmount + 150)
    ).to.be.revertedWith("amount is > staked");
  });

  it("Should not allow locking 0 tokens", async function () {
    await expect(safeToken.lockTokens(0)).to.be.revertedWith("amount is <= 0");
  });

  it("Should not allow unlocking 0 tokens", async function () {
    await expect(safeToken.unLockTokens(0)).to.be.revertedWith(
      "amount is <= 0"
    );
  });

  it("Should not allow unlocking without staking", async function () {
    await expect(safeToken.unLockTokens(depositAmount + 50)).to.be.revertedWith(
      "amount is > staked"
    );
  });

  it("Should calculate rewards correctly", async function () {
    await safeToken.lockTokens(depositAmount);

    // Advance time by 1 day
    await ethers.provider.send("evm_increaseTime", [24 * 60 * 60]);

    await safeToken.calculateReward();
    const initialRewards = await safeToken.rewards(owner.address);

    // Advance time by 10 year
    await ethers.provider.send("evm_increaseTime", [24 * 60 * 60 * 365]);

    await safeToken.calculateReward();
    const finalRewards = await safeToken.rewards(owner.address);
    expect(finalRewards).to.be.above(initialRewards); // Rewards should increase over time
  });
});
