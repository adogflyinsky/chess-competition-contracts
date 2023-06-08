// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IQuestionSet.sol";
import "./Prize.sol";
import "./ChessPuzzle.sol";


contract ChessCompetitionPuzzle is Ownable {

    error IsNotParticipant(uint256 id);

    struct Competition {
        address owner;
        uint256 id;
        uint256 prizeId;
        address[] participants;
        uint256 endTime;
        bytes[] encodeDatas; // including: address, question(index), answer 
        string result;
        address[] winners;
    }
    Prize public prize;
    ChessPuzzle public chessPuzzle;
    // IQuestionSet public questions;
    
    Competition[] public competitions;
    mapping(uint256 => uint256) private trackingCompetition;

    constructor(Prize _prize, ChessPuzzle _chessPuzzle 
    // , IQuestionSet _questions
    ) {
        chessPuzzle = _chessPuzzle;
        prize = _prize;
        // questions = _questions;
    }

    // function setQuestions(IQuestionSet _questions) external onlyOwner {
    //     require(competitions.length == 0, "Need to remove or finish all competitions first");
    //     questions = _questions;
    // }

    function create(uint256 id, uint256 prizeId) external  {
        require(!isInCompetition(id), "The id is existed in competition");
        require(msg.sender == chessPuzzle.ownerOf(id), "You are not owner of this puzzle id");
        require(prize.ownerOf(prizeId) == address(this), "The prizeId is not minted to the contract");
        require(!prize.checkIsActive(prizeId), "This prize is actived");
        Competition memory competition;
        competition.owner = msg.sender;
        competition.id = id;
        competition.prizeId = prizeId;
        competitions.push(competition);
        trackingCompetition[id] = competitions.length - 1;
    }  

    function remove(uint256 id) external {
        uint256 index = trackingCompetition[id];
        require(msg.sender == owner() || msg.sender == competitions[index].owner, "You are not owner of this puzzle id");
        require(competitions[index].participants.length == 0, "The competition is started");
        _naiveRemove(id);
    }
    
    function start(uint256 id, address[] memory participants, uint256 time) external {
        require(isInCompetition(id), "This id is not in competition");
        uint256 index = trackingCompetition[id];
        require(msg.sender == competitions[index].owner, "You are not owner of this puzzle id");
        competitions[index].participants = participants;
        competitions[index].endTime = block.timestamp + time;
    }

    function fill(uint256 id, uint256 data) external {
        // remove address in participants by assign address(0) and add encodeData to encodedatas
        uint256 participantIndex = getParticipant(id);
        uint256 competitionIndex = trackingCompetition[id];
        competitions[competitionIndex].participants[participantIndex] = address(0);
        bytes memory encodeData = abi.encode(msg.sender, participantIndex, data);
        competitions[competitionIndex].encodeDatas.push(encodeData);
    } 
    
    function requestResult(uint256 id) external  { 
        
    }


     function fillResult(uint256 id, string memory result) external onlyOwner isValidCompetition(id) {
        uint256 index = trackingCompetition[id];
        require(bytes(competitions[index].result).length == 0, "Result is filled");
        competitions[index].result = result;
    }

    function getWinners(uint256 id) internal isValidCompetition(id) {
        uint256 index = trackingCompetition[id];
        require(bytes(competitions[index].result).length != 0, "Result is not filled");
        
        // for (uint256 i=0; i < competitions[index].encodeDatas.length; i++) {
        //     (address participant, uint256 participantIndex, uint256 data) = abi.decode(competitions[index].encodedatas[i], (address, uint256, uint256));
        //     if (questions.verify(data, competitions[index].result, competitions[index].participants.length, participantIndex)) {
        //         competitions[index].winners.push(participant);
        //     }
        // }
        competitions[index].winners = competitions[index].participants;
    }

    function finish(uint256 id) external {
        uint256 index = trackingCompetition[id];
        require(competitions[index].endTime <= block.timestamp, "Can not finish yet");
        getWinners(id);
        prize.active(competitions[index].prizeId, id, competitions[index].winners);
        _naiveRemove(id);
    }
    

    function _naiveRemove(uint256 id) private {
        uint256 index = trackingCompetition[id];
        Competition memory lastCompetition = competitions[competitions.length - 1];
        uint256 lastPuzzleId = lastCompetition.id;
        competitions[index] = lastCompetition;
        trackingCompetition[lastPuzzleId] = index;
        trackingCompetition[id] = 0;
        competitions.pop();

    }

    function getParticipant(uint256 id) public view isValidCompetition(id) returns(uint256) {
        uint256 competitionIndex = trackingCompetition[id];
        for (uint i=0; i < competitions[competitionIndex].participants.length; i++) {
            if (msg.sender == competitions[competitionIndex].participants[i]) {
                return i;
            }
        }
        revert IsNotParticipant(id);
    }

    function isInCompetition(uint256 id) public view returns(bool) {
        if (competitions.length == 0) {
            return false;
        }
        if (trackingCompetition[id] == 0 && competitions[0].id != id) {
            return false;
        }
        return true;
    }
   
    modifier isValidCompetition(uint256 id) {
        require(isInCompetition(id), "This id is not in competition");
        uint256 index = trackingCompetition[id];
        require(competitions[index].endTime != 0, "endTime has to be different from 0");
        // ...
        _;
    }

}   



