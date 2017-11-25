pragma solidity ^0.4.18;

contract TokenDao {

    address internal llamador;
    uint256 internal sellPrice;
    uint256 internal buyPrice;
    string internal name; 
    string internal symbol;
    uint8 internal decimals;
    mapping (address => uint) balanceOf;

    function TokenDao(
        address _llamador,
        uint256 initialSupply,
        uint256 newSellPrice,
        uint256 newBuyPrice) public 
    {
        llamador = _llamador;
        balanceOf[llamador] = initialSupply;
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
        name = "Beether";
        symbol = "beeth"; 
        decimals = 2;
    }

    function setDecimals(uint8 _decimals) public{
        decimals = _decimals;
    }
    
    function getDecimals()public view returns(uint8){
        return decimals;
    }

    function setName(string _name) public{
        name = _name;
    }
    
    function getName()public view returns(string){
        return name;
    }

    function setSymbol(string _symbol) public{
        symbol = _symbol;
    }
    
    function getSymbol()public view returns(string){
        return symbol;
    }

    function getSellPrice() public view returns(uint256){
        return sellPrice;
    }

    function setSellPrice(uint256 _sellPrice) public{
        sellPrice = _sellPrice;
    }

    function getBuyPrice() public view returns(uint256){
        return buyPrice;
    }

    function setBuyPrice(uint256 _buyPrice) public{
        sellPrice = _buyPrice;
    }

    function getBalance(address addr) public view returns(uint) {
		return balanceOf[addr];
	}

    function setBalance(address addr,uint value) public {
		balanceOf[addr] = value;
	}

    function cambiarLlamador(address _llamador) public onlyLlamador {
        llamador = _llamador;
    }

    modifier onlyLlamador {
        require(msg.sender == llamador);
        _;
    }

}
