// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./CompetitionBase2.sol";
import "./RequestResponseConsumerBase.sol";


contract CompetitionV2 is CompetitionBase2, RequestResponseConsumerBase {
    using ICN for ICN.Request;

    bytes32 private s_jobId;
    string public s_response;

    constructor(IERC721 _competitionToken, IPrize _prize
    , IQuestionSet _questions
    , address _oracleAddress
    ) CompetitionBase2(_competitionToken, _prize, _questions) {
        setOracle(_oracleAddress);
        s_jobId = keccak256(abi.encodePacked("any-api"));
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
