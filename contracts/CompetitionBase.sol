// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract CompetitionBase {

    error IsNotParticipant(uint256 id);

    struct Competition {
        address owner;
        uint256 id;
        address[] participants;
        uint256 endTime;
        bytes[] encodeDatas; // including: address, index of participant, answer 
        string result;
        address[] winners;
    }

    IERC721 public competitionToken;
    Competition[] public competitions;
    mapping(uint256 => uint256) internal trackingCompetition;

    constructor(IERC721 _competitionToken) {
        competitionToken = _competitionToken;
    }

    function create(uint256 id) internal virtual {
        require(!isInCompetition(id), "The id is existed in competition");
        require(competitionToken.ownerOf(id) == msg.sender, "You are not owner of this puzzle id");
        competitionToken.safeTransferFrom(msg.sender, address(this), id);

        Competition memory competition;
        competition.owner = msg.sender;
        competition.id = id;
        competitions.push(competition);
        trackingCompetition[id] = competitions.length;
    }  

    function remove(uint256 id) public virtual isValidCompetition(id) {
        uint256 index = trackingCompetition[id];
        require(msg.sender == competitions[index].owner, "You are not owner of this puzzle id");
        require(competitions[index].participants.length == 0, "The competition is started");
        _naiveRemove(id);
    }
    
    function start(uint256 id, address[] memory participants, uint256 time) public virtual {
        require(isInCompetition(id), "This id is not in competition");
        uint256 index = trackingCompetition[id];
        require(msg.sender == competitions[index].owner, "You are not owner of this puzzle id");
        competitions[index].participants = participants;
        competitions[index].endTime = block.timestamp + time;
    }

    function fillData(uint256 id, uint256 data) public virtual {
        // remove address in participants by assign address(0) and add encodeData to encodeDatas
        uint256 participantIndex = getParticipant(id);
        uint256 competitionIndex = trackingCompetition[id];
        competitions[competitionIndex].participants[participantIndex] = address(0);
        bytes memory encodeData = abi.encode(msg.sender, participantIndex, data);
        competitions[competitionIndex].encodeDatas.push(encodeData);
    } 

    // add condition and specific address allowing to fill result
    function fillResult(uint256 id, string memory result) internal isValidCompetition(id) {
        uint256 index = trackingCompetition[id];
        require(bytes(competitions[index].result).length == 0, "result is filled");
        competitions[index].result = result;
    }

    function getWinners(uint256 id) internal virtual;

    function finish(uint256 id) public virtual isValidCompetition(id) {
        uint256 index = trackingCompetition[id];
        require(competitions[index].endTime <= block.timestamp, "Can not finish yet");
        getWinners(id);
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

    function getParticipants(uint256 id) public view virtual isValidCompetition(id) returns(uint256) {
        uint256 competitionIndex = trackingCompetition[id];
        for (uint i=0; i < competitions[competitionIndex].participants.length; i++) {
            if (msg.sender == competitions[competitionIndex].participants[i]) {
                return i;
            }
        }
        revert IsNotParticipant(id);
    }

    function isInCompetition(uint256 id) public view virtual returns(bool) {
        if (competitions.length == 0) {
            return false;
        }
        if (trackingCompetition[id] == 0 && competitions[0].id != id) {
            return false;
        }
        return true;
    }
   
    modifier isValidCompetition(uint256 id) virtual {
        require(isInCompetition(id), "This id is not in competition");
        uint256 index = trackingCompetition[id];
        require(competitions[index].endTime != 0, "endTime has to be different from 0");
        _;
    }

}   




