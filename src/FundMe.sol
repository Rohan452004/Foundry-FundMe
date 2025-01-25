// Get money from users
// Withdraw
// Set a minimum amount to donate

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error notOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5 * 1e18; // Use chainlink (Data Feeds) for coversion
    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;
    address private immutable owner;

    AggregatorV3Interface private s_pricefeed;

    constructor(address priceFeed) {
        s_pricefeed = AggregatorV3Interface(priceFeed);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        // require(msg.sender==owner, "Sender is not Owner !");
        if(msg.sender != owner){
            revert notOwner();
        }
        _;
    }

    function fund() public payable {
        // Allow users to send money
        // Have a minimum amount to send
        // 1. How do we send ETH ? -> use payable keyword in function
        require(msg.value.getConversionRate(s_pricefeed) >= MINIMUM_USD, "Didnt send enough ETH");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_pricefeed.version();
    }

    function withdraw() public onlyOwner {
        // require(msg.sender==owner,"Must be Onwer !");
        for(uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // Reset the funders array
        s_funders = new address[](0);
        // Withdraw the funds ( 3 methods )

        /* // transfer
        payable(msg.sender).transfer(address(this).balance);
        // send
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess,"Send Failed"); */
        // call
        (bool callSuccess, )= payable(msg.sender).call{value:address(this).balance}("");
        require(callSuccess,"Call Failed");
    }

     function cheaperWithdraw() public onlyOwner {
        address[] memory funders = s_funders;
        // mappings can't be in memory, sorry!
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // payable(msg.sender).transfer(address(this).balance);
        (bool success,) = owner.call{value: address(this).balance}("");
        require(success);
    }

        // What happen if someoone sends ETH to this contract without calling the fund() function
        // -> Receieve and fallback functions

        // Explainer from: https://solidity-by-example.org/fallback/
        // Ether is sent to contract
        //      is msg.data empty?
        //          /   \
        //         yes  no
        //         /     \
        //    receive()?  fallback()
        //     /   \
        //   yes   no
        //  /        \
        //receive()  fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    /**
     * View / Pure Functions
     */

    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return owner;
    }
    
}

// 1. Solidity rollbacks transaction when it fails, so whatever is executed above it in the function
// it also gets rolled back

// 2. ChainLink data feeds will help integrate currency conversion inside our FundME Contract

// 3. Gas optimization technique -> Constant and immutable , Custom errors

// 4. Fallback and Recieve functions