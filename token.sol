pragma solidity ^0.4.18;

contract Token {

    address internal llamador;
    uint256 internal sellPrice;
    uint256 internal buyPrice;
    string internal name;
    string internal symbol;
    uint8 internal decimals;

    mapping (address => uint) balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event TransferKO(address indexed from, address indexed to, uint256 value);

    function Token(
        address _llamador,
        uint256 initialSupply,
        uint256 newSellPrice,
        uint256 newBuyPrice) public {
        llamador = _llamador;
        balanceOf[llamador] = initialSupply;
        setPrices(newSellPrice,newBuyPrice);
        name = "Beether";
        symbol = "beeth"; 
        decimals = 2;
    }

    function buy() public payable onlyLLamador returns (uint amount) {
        amount = msg.value / buyPrice;         
        require(balanceOf[owner] >= amount); 
        _transfer(owner, msg.sender, amount);
        return amount;                         
    }

    function cambiarLlamador(address _llamador) public onlyLlamador {
        llamador = _llamador;
    }

    modifier onlyLlamador {
        require(msg.sender == llamador);
        _;
    }

}