// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Exchanges is Ownable {
    using SafeERC20 for IERC20;
    address payable public wallet;
    uint256 public rate; // prefer 1, 10, 100, ...
    IERC20 public token;


    event SetRate(uint256 newRate);
    event ExchangeTokenToEther(address sender, uint256 tokenAmount, uint256 etherAmount);
    event ExchangeEtherToToken(address sender, uint256 etherAmount, uint256 tokenAmount);

    constructor(
        uint256 _rate,
        IERC20 _token

    ) {
        rate = _rate;
        token = _token;
    }


    function setRate(uint256 new_rate) public onlyOwner {
        rate = new_rate;
        emit SetRate(new_rate);
    }


    function EtherToToken() external payable {
        uint256 etherAmount = msg.value;
        uint256 amount = getTokenAmount(etherAmount);
        require(amount > 0, "Amount is zero");
        require(
            token.balanceOf(address(this)) >= amount,
            "Insufficient token"
        );
        SafeERC20.safeTransfer(token, msg.sender, amount);
        emit ExchangeEtherToToken(msg.sender, etherAmount, amount);
    }

    function TokenToEther(uint256 amount) external payable {
        uint256 etherAmount = getEtherAmount(amount);
        require(
            token.balanceOf(msg.sender) >= amount,
            "Insufficient token"
        );
        require(amount > 0, "Amount is zero");
        require(
            address(this).balance >= etherAmount,
            "Insufficient ether"
        );
        payable(address(this)).transfer(etherAmount);
        SafeERC20.safeTransferFrom(token, msg.sender, address(this), amount);
        emit ExchangeTokenToEther(msg.sender, amount, etherAmount);
    }

    function getTokenAmount(uint256 amount)
        public
        view
        returns (uint256)
    {
        return amount * rate;
    }

    function getEtherAmount(uint256 amount)
        public
        view
        returns (uint256)
    {
        return amount / rate;
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawERC20() public onlyOwner {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function deposit() public payable onlyOwner {

    }

    function depositERC20(uint256 amount) public onlyOwner {
        SafeERC20.safeTransfer(token, address(this), amount);
    }
}