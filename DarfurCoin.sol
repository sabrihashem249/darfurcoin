// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DarfurCoin {
    string public name = "Darfur Coin";
    string public symbol = "DFC";
    uint8 public decimals = 18;
    uint256 public totalSupply = 10000000000 * 10 ** uint256(decimals); // 10 مليار عملة

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public frozenAccount;

    address public owner;
    uint256 public taxPercentage = 2; // 2% ضريبة
    address public taxWallet;

    constructor(address _taxWallet) {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        taxWallet = _taxWallet;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FrozenFunds(address target, bool frozen);
    event Burn(address indexed burner, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(!frozenAccount[msg.sender], "Sender account frozen");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        uint256 tax = (_value * taxPercentage) / 100;
        uint256 netAmount = _value - tax;
        _transfer(msg.sender, _to, netAmount);
        _transfer(msg.sender, taxWallet, tax);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(!frozenAccount[_from], "From account frozen");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        uint256 tax = (_value * taxPercentage) / 100;
        uint256 netAmount = _value - tax;
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, netAmount);
        _transfer(_from, taxWallet, tax);
        return true;
    }

    // خاصية الحرق
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance to burn");
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    // خاصية تجميد الحسابات
    function freezeAccount(address _target, bool _freeze) public onlyOwner {
        frozenAccount[_target] = _freeze;
        emit FrozenFunds(_target, _freeze);
    }

    // تعديل نسبة الضريبة
    function setTaxPercentage(uint256 _tax) public onlyOwner {
        require(_tax <= 10, "Max tax is 10%");
        taxPercentage = _tax;
    }

    // تغيير محفظة الضرائب
    function setTaxWallet(address _wallet) public onlyOwner {
        taxWallet = _wallet;
    }
}