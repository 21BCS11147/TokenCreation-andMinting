// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CustomToken {
    string public nameOfToken;
    string public tokenSymbol;
    uint8 public decimalsOfToken;
    uint256 public totalSupplyOfToken;
    address public ownerOfContract;

    mapping(address => uint256) public accountBalances;
    mapping(address => mapping(address => uint256)) public authorizedAllowances;

    event TransferCompleted(address indexed from, address indexed to, uint256 amount);
    event AuthorizationGranted(address indexed owner, address indexed spender, uint256 amount);
    event NewTokensGenerated(address indexed receiver, uint256 amount);
    event TokensDestroyed(address indexed from, uint256 amount);

    modifier onlyOwner {
        require(msg.sender == ownerOfContract, "Only the contract's owner can initiate this operation");
        _;
    }

    constructor(string memory _tokenName, string memory _tokenSymbol, uint8 _tokenDecimals, uint256 _initialSupply) {
        nameOfToken = _tokenName;
        tokenSymbol = _tokenSymbol;
        decimalsOfToken = _tokenDecimals;
        totalSupplyOfToken = _initialSupply * 10**uint256(_tokenDecimals);
        ownerOfContract = msg.sender;
        accountBalances[ownerOfContract] = totalSupplyOfToken;
    }

    function initiateTokenTransfer(address _to, uint256 _amount) external {
        require(_to != address(0), "Destination address is invalid");
        require(accountBalances[msg.sender] >= _amount, "Insufficient balance");

        accountBalances[msg.sender] -= _amount;
        accountBalances[_to] += _amount;

        emit TransferCompleted(msg.sender, _to, _amount);
    }

    function authorizeAllowance(address _spender, uint256 _amount) external {
        require(_spender != address(0), "Invalid spender address");

        authorizedAllowances[msg.sender][_spender] = _amount;

        emit AuthorizationGranted(msg.sender, _spender, _amount);
    }

    function transferFromWithAllowedAmount(address _from, address _to, uint256 _amount) external {
        require(_from != address(0), "Source address is invalid");
        require(_to != address(0), "Destination address is invalid");
        require(accountBalances[_from] >= _amount, "Insufficient balance");
        require(authorizedAllowances[_from][msg.sender] >= _amount, "Allowance exceeded");

        accountBalances[_from] -= _amount;
        accountBalances[_to] += _amount;
        authorizedAllowances[_from][msg.sender] -= _amount;

        emit TransferCompleted(_from, _to, _amount);
    }

    function generateNewTokens(address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "Destination address is invalid");
        require(_amount > 0, "Token generation amount must be greater than zero");

        totalSupplyOfToken += _amount;
        accountBalances[_to] += _amount;

        emit NewTokensGenerated(_to, _amount);
    }

    function destroyTokens(uint256 _amount) external {
        require(accountBalances[msg.sender] >= _amount, "Insufficient balance");
        require(_amount > 0, "Token destruction amount must be greater than zero");

        totalSupplyOfToken -= _amount;
        accountBalances[msg.sender] -= _amount;

        emit TokensDestroyed(msg.sender, _amount);
    }

    function increaseAllowanceAmount(address _spender, uint256 _additionalAmount) external {
        require(_spender != address(0), "Invalid spender address");

        authorizedAllowances[msg.sender][_spender] += _additionalAmount;

        emit AuthorizationGranted(msg.sender, _spender, authorizedAllowances[msg.sender][_spender]);
    }

    function decreaseAllowanceAmount(address _spender, uint256 _reducedAmount) external {
        require(_spender != address(0), "Invalid spender address");
        uint256 currentAllowance = authorizedAllowances[msg.sender][_spender];
        require(currentAllowance >= _reducedAmount, "Allowance reduction below zero");

        authorizedAllowances[msg.sender][_spender] = currentAllowance - _reducedAmount;

        emit AuthorizationGranted(msg.sender, _spender, authorizedAllowances[msg.sender][_spender]);
    }
}
