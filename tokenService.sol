pragma solidity ^0.4.18;

import 'https://github.com/empresarioMadri/beegame/tokenDao.sol';

contract TokenService {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event TransferKO(address indexed from, address indexed to, uint256 value);

    address tokenDao;
    TokenDao internal tokenDaoImpl;

    function TokenService(
        address _llamador,
        uint256 initialSupply,
        uint256 newSellPrice,
        uint256 newBuyPrice) {
        tokenDAO = new TokenDao(_llamador,initialSuply,newSellPrice,newBuyPrice);
        tokenDaoImpl = TokenDao(tokenDao);

    }

    function changeTokenDao(
        address _llamador,
        uint256 initialSupply,
        uint256 newSellPrice,
        uint256 newBuyPrice) public onlyLlamador {
        tokenDao = new TokenDao(_llamador,initialSuply,newSellPrice,newBuyPrice);
    }

    function buy(value) public onlyLLamador returns (uint amount) {
        amount = value / referencia.getBuyPrice();         
        require(referencia.getBalanceOf(llamador) >= amount); 
        _transfer(llamador, msg.sender, amount);
        return amount;                         
    }

    function transfer(address _to, uint _value) public onlyLlamador{
        _transfer(msg.sender, _to, _value);
        // TODO incluirUsuario(_to);
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require(tokenDaoImpl.getBalanceOf(_from) >= _value);                // Check if the sender has enough
        require(safeAdd(tokenDaoImpl.getBalanceOf(_to),_value) > tokenDaoImpl.getBalanceOf(_to)); // Check for overflows
        tokenDaoImpl.getBalanceOf(_from) = safeSub(tokenDaoImpl.getBalanceOf(_from),_value);                         
        tokenDaoImpl.getBalanceOf(_to) = safeAdd(tokenDaoImpl.getBalanceOf(_to),_value);                           
        Transfer(_from, _to, _value);
    }

    function sell(uint amount) public onlyLlamador {
        require(tokenDaoImpl.getBalanceOf(msg.sender) >= amount);         
        _transfer(msg.sender, owner, amount);
        uint revenue = safeMul(amount,tokenDaoImpl.getSellPrice());
        if (msg.sender.send (revenue)) {                
            Transfer(msg.sender, owner, revenue);  
        }else {
            _transfer(owner, msg.sender, amount);
            TransferKO(msg.sender, this, revenue);
        }                                   
    }

    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    function cambiarLlamador(address _llamador) public onlyLlamador {
        llamador = _llamador;
    }

    modifier onlyLlamador {
        require(msg.sender == llamador);
        _;
    }
}