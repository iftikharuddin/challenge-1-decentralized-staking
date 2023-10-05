// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  event Staked(address,uint256);
  uint256 public deadline = block.timestamp + 72 hours;
  event Withdrawn(address indexed user, uint256 amount);
  bool public openForWithdraw = false;
  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

  /**
  * @notice Stake method that update the user's balance
  */
  function stake() public payable {
    // update the user's balance
    balances[msg.sender] += msg.value;

    // emit the event to notify the blockchain that we have correctly Staked some fund for the user
    emit Staked(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() public {
    require(block.timestamp >= deadline, "Deadline not reached yet");

    if (address(this).balance >= threshold) {
      require(!exampleExternalContract.completed(), "External contract already completed");
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
  }

  function withdraw() external {
    require(openForWithdraw, "Funds not open for withdrawal");
    uint256 amount = balances[msg.sender];
    require(amount > 0, "No balance to withdraw");

    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Transfer failed!");

    balances[msg.sender] = 0;
    emit Withdrawn(msg.sender, amount);
  }



  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (block.timestamp < deadline) {
      return deadline - block.timestamp;
    } else {
      return 0;
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()
  function receive() external payable {
    stake();
  }

}
