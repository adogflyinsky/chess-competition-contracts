import { ethers } from 'hardhat'

async function main() {
  const [owner] = await ethers.getSigners();
  const userContract = await ethers.getContractAt('ChessPuzzle', "0x8cA44BfD3f8437Eeb014A737e78E6832255Aa226", owner)
  await userContract.mint(owner.address, 1);
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
