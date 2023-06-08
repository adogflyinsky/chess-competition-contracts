import { ethers, hardhatArguments } from 'hardhat';
import * as Config from './config';

async function main() {
    await Config.initConfig();
    const network = hardhatArguments.network ? hardhatArguments.network : 'dev';
    const [owner] = await ethers.getSigners();
    console.log('deploy from address: ', owner.address);


    // const Token = await ethers.getContractFactory("VToken", owner);
    // const token = await Token.deploy();
    // console.log('VTken address: ', token.address);
    // Config.setConfig(network + '.VToken', token.address);

    // const Prize = await ethers.getContractFactory("Prize", owner);
    // const prize = await Prize.deploy("0xb8895a2f8925AFcA92A7ef9664E093FFcD4E8D31");
    // Config.setConfig(network + '.prize', prize.address);

    // const ChessPuzzle = await ethers.getContractFactory("ChessPuzzle", owner);
    // const chessPuzzle = await ChessPuzzle.deploy("https://old.chesstempo.com/chess-problems/");
    // Config.setConfig(network + '.chessPuzzle', chessPuzzle.address);

    // const RequestResponseCoordinator = await ethers.getContractFactory("RequestResponseCoordinator", owner);
    // const  requestResponseCoordinator = await RequestResponseCoordinator.deploy();
    // Config.setConfig(network + '.requestResponseCoordinator', requestResponseCoordinator.address);

    // const CompetitionChessPuzzle = await ethers.getContractFactory("CompetitionChessPuzzle", owner);
    // const competitionChessPuzzle = await CompetitionChessPuzzle.deploy(
    //     "0x8cA44BfD3f8437Eeb014A737e78E6832255Aa226",
    //     "0x320b6e6d7BC446028BE3Cd67aC11f80947c164C7",
    //     "0xB9c5cc822E11AD0ed8cb19ACBc3FDc02E9944a26",
    //     "0x845F3DEF90dF82eF27a09cc39C65d94186133a25");
    // Config.setConfig(network + '.competitionChessPuzzle', competitionChessPuzzle.address);
    
    await Config.updateConfig();
    
}

main().then(() => process.exit(0))
    .catch(err => {
        console.error(err);
        process.exit(1);
});
