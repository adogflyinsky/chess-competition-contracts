
import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("QuestionSet", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployOneYearLockFixture() {
        const [deployer] = await ethers.getSigners();
        const CustomMath = await ethers.getContractFactory("CustomMath");
        const customMath = await CustomMath.deploy();
        const QuestionSet = await ethers.getContractFactory("QuestionSet", {
            libraries: {
                CustomMath: customMath.address,
            }
        });
        const questionSet = await QuestionSet.deploy();
        return { questionSet, deployer };
    }

    it("Happy path", async function () {
        const { questionSet, deployer } = await loadFixture(deployOneYearLockFixture);
        const result = "Happy path";
        const proof = await questionSet.getProof(result, 16, 15);
        expect(await questionSet.verify(proof, result, 16, 15)).equal(true);
    })

    it("Unhappy path", async function () {
        const { questionSet, deployer } = await loadFixture(deployOneYearLockFixture);
        const result = "Unhappy path";
        const proof = await questionSet.getProof(result, 16, 15);
        expect(await questionSet.verify(10n, result, 16, 15)).equal(false);
        
    })

});
