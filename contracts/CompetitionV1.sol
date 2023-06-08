// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./CompetitionBase.sol";
import "./interfaces/IPrize.sol";
import "./interfaces/IQuestionSet.sol";
import "hardhat/console.sol";


// import "./ChessPuzzle.sol";

contract CompetitionV1 is CompetitionBase {
    
    IERC721 competitionToken;
    address public prizeAddress;
    IQuestionSet public questions;
    
    constructor(IERC721 _competitionToken, address _prizeAddress, IQuestionSet _questions) {
        competitionToken = _competitionToken;
        prizeAddress = _prizeAddress;
        questions = _questions;
    }   
    mapping(uint256 => uint256) competitionToPrize;
    function create(uint256 id, uint256 prizeId, uint256 startTime) external {
        require(competitionToken.ownerOf(id) == msg.sender, "You are not owner of competitionToken");
        competitionToken.transferFrom(msg.sender, address(this), id);
        require(IERC721(prizeAddress).ownerOf(prizeId) == address(this), "The prizeId is not minted to the contract");
        require(!IPrize(prizeAddress).checkIsActive(prizeId), "The prize is actived");
        require(IPrize(prizeAddress).taskIdOf(prizeId) == id, "The prize is not minted to the task");
        competitionToPrize[id] = prizeId;
        _create(id, startTime);
    }
    function remove(uint256 id) external {
        uint256 index = trackingCompetition[id];
        require(msg.sender == competitions[index].owner, "You are not owner of the id");
        address owner = competitions[index].owner;
        competitionToken.transferFrom(address(this), owner, id);
        _remove(id);
    }

    function start(uint256 id, address[] memory participants) external {
        uint256 index = trackingCompetition[id];
        require(msg.sender == competitions[index].owner, "You are not owner of the id");
        _start(id, participants);
    }

    function fillData(uint256 id, uint256 data) external {
        _fillData(id, data);
    }

    function _getWinners(uint256 id) internal override { 
        uint256 index = trackingCompetition[id];
        require(bytes(competitions[index].result).length != 0, "Result is not filled");
        for (uint256 i=0; i < competitions[index].encodedDataList.length; i++) {
            (address participant, uint256 participantIndex, uint256 data) = abi.decode(competitions[index].encodedDataList[i], (address, uint256, uint256));
            if (questions.verify(data, competitions[index].result, competitions[index].participants.length, participantIndex)) {
                competitions[index].winners.push(participant);
            }
        }
        IPrize(prizeAddress).active(competitionToPrize[id], id, competitions[index].winners);
    }

    function fillResult(uint256 id, string memory result) external {
        uint256 index = trackingCompetition[id];
        require(msg.sender == competitions[index].owner, "You are not owner of the id");
        _fillResult(id, result);
    }

    function finish(uint256 id) external {
        uint256 index = trackingCompetition[id];
        address owner = competitions[index].owner;
        competitionToken.transferFrom(address(this), owner, id);
        _finish(id);
    }

    function getProof(uint256 id, string memory data) external view returns (uint256) {
        uint256 index = trackingCompetition[id];
        for (uint256 i=0; i < competitions[index].participants.length; i++) {
            if (msg.sender == competitions[index].participants[i]) {
                return questions.getProof(data, competitions[index].participants.length , i);
            }

        }
        revert IsNotParticipant();
    }

}