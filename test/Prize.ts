
import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Prize", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {



    // Contracts are deployed using the first signer/account by default
    const [deployer, acc1, acc2, acc3] = await ethers.getSigners();
    const VToken = await ethers.getContractFactory("VToken");
    const vToken = await VToken.deploy();
    const Prize = await ethers.getContractFactory("Prize");
    const prize = await Prize.deploy(vToken.address);

    return { prize, deployer, vToken, acc1, acc2 , acc3};
  }

  describe.skip("Deployment", function () {

    
  });
  describe("Happy path", function () {
    it("mint + fund + active function", async function () {
        // mint
        const { prize, deployer, vToken, acc1, acc2, acc3 } = await loadFixture(deployOneYearLockFixture);
        const init_deployer_balance = await vToken.balanceOf(deployer.address);
        await vToken.approve(prize.address, 50000);
        await prize.mintTo(deployer.address, 1, 10000, [40, 40, 20]);
        await prize.mintTo(deployer.address, 2, 20000, [50, 30, 20]);
        const p1 = await prize.prizes(1);
        const p2 = await prize.prizes(2);
        expect(p1.amount).equal(10000);
        expect(p2.amount).equal(20000);

        // fund
        await prize.fund(1, 10000);
        await prize.fund(2, 10000);
        const new_p1 = await prize.prizes(1);
        const new_p2 = await prize.prizes(2);
        expect(new_p1.amount).equal(20000); // deployer deposits 20000 VT
        expect(new_p2.amount).equal(30000); // deployer deposits 30000 VT

        // active
        await prize.active(1, 1, [acc1.address, acc2.address, acc3.address]); // spend all: no refund to deployer
        expect(await vToken.balanceOf(acc2.address)).equal(20000 * 40 / 100);
        expect((await vToken.balanceOf(deployer.address)).toBigInt() + 50000n).equal(init_deployer_balance.toBigInt());
        await prize.active(2, 2, [acc1.address, acc2.address]); // spend for 2/3 accounts: refund `30000 * 20 / 100 = 6000` to deployer
        expect(await vToken.balanceOf(acc2.address)).equal(20000 * 40 / 100 + 30000 * 30 / 100);
        expect((await vToken.balanceOf(deployer.address)).toBigInt() + 44000n).equal(init_deployer_balance.toBigInt());
    })
  })
  
});
