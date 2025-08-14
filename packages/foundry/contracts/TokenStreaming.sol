//SPDX-License-Identifier: MIT

pragma solidity 0.8.26;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenStreaming {
    uint public immutable unlockTime;
    address public owner;
    IERC20 public immutable token;
    
    struct Stream {
        uint cap;
        uint timeOfLastWithdrawal;
    }
    
    mapping(address => Stream) public streams;
    
    event AddStream(address recipient, uint cap);
    event Withdraw(address recipient, uint amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    constructor(uint _unlockTime, address _token) {
        unlockTime = _unlockTime;
        owner = msg.sender;
        token = IERC20(_token);
    }
    
    function addStream(address recipient, uint cap) external onlyOwner {
        streams[recipient] = Stream(cap, 0);
        emit AddStream(recipient, cap);
    }
    
    function withdraw(uint amount) external {
        Stream storage userStream = streams[msg.sender];
        
        require(userStream.cap > 0, "No stream found for caller");
        
        require(token.balanceOf(address(this)) >= amount, "Insufficient contract balance");
        
        uint timeElapsed = block.timestamp - userStream.timeOfLastWithdrawal;
        uint unlocked = (timeElapsed * userStream.cap) / unlockTime;
        
        if (unlocked > userStream.cap) {
            unlocked = userStream.cap;
        }
        
        require(amount <= unlocked, "Amount exceeds unlocked funds");
        
        if (amount == unlocked) {
            userStream.timeOfLastWithdrawal = block.timestamp;
        } else {
            uint timeUsed = (amount * unlockTime) / userStream.cap;
            userStream.timeOfLastWithdrawal += timeUsed;
        }
        
        require(token.transfer(msg.sender, amount), "Transfer failed");
        
        emit Withdraw(msg.sender, amount);
    }
} 
