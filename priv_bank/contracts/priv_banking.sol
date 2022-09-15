//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";


contract priv_Bank is Ownable {

    address private _owner;
    bool private constant has_owned = true;
    bytes32[] public tokenList;
    bool private constant isApproved = true;
    uint private num;
    uint private num_checker;

    enum state {
        locked,
        unlocked
    }

    struct banker {
        bool isMem;
        address pubAd;
        uint256 userID;
        state s;
    }

    struct Token {
        bytes32 ticker;
        address tokenAddress;
    }

 
    mapping(bytes32 => Token) public tokenMapping;
    mapping(address => bool) private active_user;
    mapping(address => mapping(bytes32 => uint256)) public balances;
    mapping(address => state) private approval_stat;
    
    
    event depositDone(uint amount, address indexed depositedTo);
    event addTx(address from, address to, uint amount);

    modifier tokenExist(bytes32 ticker){
        require(tokenMapping[ticker].tokenAddress != address(0), "Token does not exist.");
        _;
    }
    modifier minimumBal(bytes32 ticker){
        require(balances[_owner][ticker] > 0);
        _;
    }
    modifier newUser(address pubAd){
        require(active_user[pubAd] == false);
        _;
    }

    
    function deposit(bytes32 ticker) public payable returns (uint)  {
        balances[msg.sender][ticker] = msg.value;
        emit depositDone(msg.value, msg.sender);
        banker memory user = banker(false, msg.sender, num, state.locked);
        require(user.pubAd == msg.sender);
        return balances[msg.sender][ticker];
    }
    
    function withdraw(address payable withdrawer, uint amount, bytes32 ticker) public onlyOwner returns (uint){
        require(balances[msg.sender][ticker] >= amount);
        require(withdrawer == msg.sender);
        withdrawer.transfer(amount);
        return balances[msg.sender][ticker];
    }
    
    function getBalance(bytes32 ticker) public view onlyOwner returns (uint){
        return balances[msg.sender][ticker];
    }
    
    function transfer(address recipient, uint amount, bytes32 ticker) public onlyOwner {
        require(balances[msg.sender][ticker] >= amount, "Balance not sufficient");
        require(msg.sender != recipient, "Don't transfer money to yourself");
        
        uint previousSenderBalance = balances[msg.sender][ticker];
        
        _transfer(msg.sender, recipient, amount, ticker);
        
        emit addTx(msg.sender, recipient, amount);
        
        assert(balances[msg.sender][ticker] == previousSenderBalance - amount);
    }
    
    function _transfer(address from, address to, uint256 amount, bytes32 ticker) internal view {
        require(balances[from][ticker] > amount);
        uint256 minfee = (amount/100);
        balances[from][ticker] - (amount + minfee);
        balances[to][ticker] + amount;
    }
    
    
}