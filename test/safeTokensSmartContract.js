const { expect } = require("chai");
const { ethers } = require("hardhat");

const etherTokens = (n) => {
  return ethers.parseUnits(n.toString(), "ether");
};

describe("SafeTokenSmartContract", function () {
  let SafeTokenSmartContract;
  let safeToken;
  let owner;
  let addr1; // address to represent a user

  beforeEach(async function () {
    SafeTokenSmartContract = await ethers.getContractFactory(
      "SafeTokenSmartContract"
    );
    [owner, addr1] = await ethers.getSigners();
    safeToken = await SafeTokenSmartContract.deploy();
  });

  it("Should lock tokens and calculate rewards", async function () {
    const initialBalance = await safeToken.balanceOf(owner.address);
    let depositAmount = etherTokens(1);
    await safeToken.lockTokens(100000000000000);
    const stakedBalance = await safeToken.staked(owner.address);
    const rewardsBalance = await safeToken.rewards(owner.address);
    expect(stakedBalance).to.equal(100000000000000);
    expect(rewardsBalance).to.equal(0); // No rewards immediately after locking

    // Advance time by 1 day
    await ethers.provider.send("evm_increaseTime", [24 * 60 * 60 * 4]);

    const initialRewards = await safeToken.calculateReward();
    // Advance time by 1 year
    await ethers.provider.send("evm_increaseTime", [60 * 60 * 24 * 365 * 4]);

    const finalRewards = await safeToken.calculateReward();
    expect(finalRewards).to.be.above(initialRewards); // Rewards should increase over time
    expect(finalRewards).to.be.above(0); // Ensure final rewards are above 0
  });

  it("Should not allow unlocking more than staked amount", async function () {
    await safeToken.lockTokens(100);

    await expect(safeToken.unLockTokens(150)).to.be.revertedWith(
      "amount is > staked"
    );
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
    await expect(safeToken.unLockTokens(50)).to.be.revertedWith(
      "amount is > staked"
    );
  });

  it("Should calculate rewards correctly", async function () {
    await safeToken.lockTokens(100000000000000);

    // Advance time by 1 day
    await ethers.provider.send("evm_increaseTime", [24 * 60 * 60]);

    const initialRewards = await safeToken.calculateReward();

    // Advance time by 10 year
    await ethers.provider.send("evm_increaseTime", [60 * 60 * 24 * 365*365]);

    const finalRewards = await safeToken.calculateReward();
    expect(finalRewards).to.be.above(initialRewards); // Rewards should increase over time
  });
});
