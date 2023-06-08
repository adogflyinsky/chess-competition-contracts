// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./CompetitionBase.sol";
import "./interfaces/IQuestionSet.sol";
import "./Prize.sol";
import "./RequestResponseConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// import "./ChessPuzzle.sol";

contract CompetitionChessPuzzle is CompetitionBase, RequestResponseConsumerBase {
    using ICN for ICN.Request;
    
    Prize public prize;
    IQuestionSet public questions;

    bytes32 private s_jobId;
    string public s_response;
    
    constructor(IERC721 _chessPuzzle, Prize _prize
    , IQuestionSet _questions
    , address _oracleAddress
    ) CompetitionBase(_chessPuzzle) {
        prize = _prize;
        questions = _questions;
        setOracle(_oracleAddress);
        s_jobId = keccak256(abi.encodePacked("any-api"));
    }   
    mapping(uint256 => uint256) competitionToPrize;
    function create(uint256 id, uint256 prizeId) public {
        require(prize.ownerOf(prizeId) == address(this), "The prizeId is not minted to the contract");
        require(!prize.checkIsActive(prizeId), "The prize is actived");
        require(prize.taskIdOf(prizeId) == id, "The prize is not minted to the task");
        competitionToPrize[id] = prizeId;
        create(id);
    }

    function getWinners(uint256 id) internal override { 
        uint256 index = trackingCompetition[id];
        require(bytes(competitions[index].result).length != 0, "Result is not filled");
        for (uint256 i=0; i < competitions[index].encodeDatas.length; i++) {
            (address participant, uint256 participantIndex, uint256 data) = abi.decode(competitions[index].encodeDatas[i], (address, uint256, uint256));
            if (questions.verify(data, competitions[index].result, competitions[index].participants.length, participantIndex)) {
                competitions[index].winners.push(participant);
            }
        }
        prize.active(competitionToPrize[id], id, competitions[index].winners);
    }

    function requestResult(string memory id) public returns (bytes32 requestId) {
        ICN.Request memory req = buildRequest(s_jobId, address(this), this.fillResult.selector);
        req.add("get", "");
        req.add("id", id);
        req.add("path", "answer");
        return sendRequest(req);
    }

    function fillResult(bytes32 _requestId, uint256 id, string memory _respone) public ICNResponseFulfilled(_requestId) {
        fillResult(id, _respone);
    }

}