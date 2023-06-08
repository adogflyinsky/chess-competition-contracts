
import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { ChessCompetitionPuzzle__factory } from "../typechain-types";

describe("ChessCompetitionPuzzle", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {

    const [owner, acc1, acc2, acc3] = await ethers.getSigners();
    const VToken = await ethers.getContractFactory("VToken");
    const vToken = await VToken.deploy();
    const Prize = await ethers.getContractFactory("Prize");
    const prize = await Prize.deploy(vToken.address);
    const ChessPuzzle = await ethers.getContractFactory("ChessPuzzle");
    const chessPuzzle = await ChessPuzzle.deploy("url");
    const CustomMath = await ethers.getContractFactory("CustomMath");
    const cumstomMath = await CustomMath.deploy();
    // const QuestionSet = await ethers.getContractFactory("QuestionSet");
    // const questionSet = await QuestionSet.deploy();
    const ChessCompetitionPuzzle = await ethers.getContractFactory("ChessCompetitionPuzzle");
    const chessCompetitionPuzzle = await ChessCompetitionPuzzle.deploy(prize.address, chessPuzzle.address);

    return { prize, chessPuzzle, chessCompetitionPuzzle, vToken, owner, acc1, acc2, acc3};
  }

  describe("Deployment", function () {

    it("Should set the right owner", async function () {
      const { chessCompetitionPuzzle, owner } = await loadFixture(deployOneYearLockFixture);
      expect(await chessCompetitionPuzzle.owner()).to.equal(owner.address);
    });
  });
  describe.skip("Happy path", function () {
    it("Flow of competition", async function () {
        // mint prize
        const { prize, owner, vToken, acc1, acc2, acc3, chessPuzzle, chessCompetitionPuzzle } = await loadFixture(deployOneYearLockFixture);
        await vToken.approve(prize.address, 50000);
        const token1 = await prize.mintTo(chessCompetitionPuzzle.address, 1, 10000, [40, 40, 20]);
        const p1 = await prize.prizes(1);
        expect(p1.amount).equal(10000);

        // fund prize
        await prize.fund(1, 10000);
        const new_p1 = await prize.prizes(1);
        expect(new_p1.amount).equal(20000);

        // mint chessPuzzle
        await chessPuzzle.mint(owner.address, 1);
        // create 
        await chessCompetitionPuzzle.create(1, 1);
        // remove
        await chessCompetitionPuzzle.remove(1);
        // create
        await chessCompetitionPuzzle.create(1, 1);
        // start
        await chessCompetitionPuzzle.start(1, [acc1.address, acc2.address, acc3.address], 100);
        // fillProof
        
        // fillData
        await chessCompetitionPuzzle.fillResult(1, "test1");
        // finish
        await time.increase(100);
        await chessCompetitionPuzzle.finish(1);
        // check balances
        expect(await vToken.balanceOf(acc1.address)).equal(20000 * 40 / 100);
        expect(await vToken.balanceOf(acc2.address)).equal(20000 * 40 / 100);
        expect(await vToken.balanceOf(acc3.address)).equal(20000 * 20 / 100);
    })
  })
  
});
