pragma solidity ^0.4.18;

import "./called.sol";

contract TokenDao is Called {

    address internal llamador;
    uint256 internal sellPrice;
    uint256 internal buyPrice;
    string internal name;
    string internal symbol;
    uint8 internal decimals;
    mapping (address => uint) balanceOf;

    function TokenDao() public 
    {
        balanceOf[msg.sender] = 30000000;
        sellPrice = 20 * 1 finney;
        buyPrice = 30 * 1 finney;
        name = "Beether";
        symbol = "beeth"; 
        decimals = 2;
    }

    function setDecimals(uint8 _decimals) public onlyCaller {
        decimals = _decimals;
    }
    
    function getDecimals()public view returns(uint8) {
        return decimals;
    }

    function setName(string _name) public onlyCaller {
        name = _name;
    }
    
    function getName()public view returns(string){
        return name;
    }

    function setSymbol(string _symbol) public onlyCaller {
        symbol = _symbol;
    }
    
    function getSymbol()public view returns(string){
        return symbol;
    }

    function getSellPrice() public view returns(uint256){
        return sellPrice;
    }

    function setSellPrice(uint256 _sellPrice) public onlyCaller {
        sellPrice = _sellPrice;
    }

    function getBuyPrice() public view returns(uint256){
        return buyPrice;
    }

    function setBuyPrice(uint256 _buyPrice) public onlyCaller {
        sellPrice = _buyPrice;
    }

    function getBalance(address addr) public view returns(uint) {
		return balanceOf[addr];
	}

    function setBalance(address addr,uint value) public onlyCaller {
		balanceOf[addr] = value;
	}
}