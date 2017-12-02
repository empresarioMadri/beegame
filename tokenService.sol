pragma solidity ^0.4.18;

import './calledA.sol';
import './tokenDao.sol';
import './boteService.sol';
import './TiposCompartidos.sol';
import './usuarioService.sol';

contract TokenService is CalledA {

    address internal tokenDao;
    TokenDao internal tokenDaoImpl;

    address internal usuarioService;
    UsuarioService internal usuarioServiceImpl;
    
    address internal boteService;
    BoteService internal boteServiceImpl;

    address owner;
    
    uint256 fechaTax;

    function TokenService () public {
        owner = msg.sender;
    }
    
    function setBoteService(address _boteService) public onlyCallers {
        boteService = _boteService;
        boteServiceImpl = BoteService(boteService);
    }
    
    function setUsuarioService(address _usuarioService) public onlyCallers {
        usuarioService = _usuarioService;
        usuarioServiceImpl = UsuarioService(usuarioService);
    }

    function setTokenDao(address _tokenDao)public onlyCallers {
        tokenDao = _tokenDao;
        tokenDaoImpl = TokenDao(tokenDao);
    }
    
    function getTokenDao() public view returns(address){
        return tokenDao;
    }

    function getBote() public view returns(uint) {
        uint retorno;
        for (uint i = 0; i < usuarioServiceImpl.getNumeroUsuarios(); i++) {
            address usuario = usuarioServiceImpl.getIndiceUsuarios(i);
            if (tokenDaoImpl.getBalance(usuario) > 0) {
                retorno = TiposCompartidos.safeAdd(retorno,1);
            }
        }
        return retorno;
    }

    function buy(uint value,address sender) public onlyCallers{
        uint amount = value / tokenDaoImpl.getBuyPrice();         
        require(tokenDaoImpl.getBalance(owner) >= amount); 
        _transfer(owner, sender, amount);
        usuarioServiceImpl.incluirUsuario(sender);
    }

    function cobrarImpuesto(uint _fechaTax,uint ganador) public onlyCallers {
        uint bote = 0;
        for (uint i = 0; i < usuarioServiceImpl.getNumeroUsuarios(); i++) {
            address usuario = usuarioServiceImpl.getIndiceUsuarios(i);
            if (tokenDaoImpl.getBalance(usuario) > 0) {
                _transfer(usuario, owner, 1);
                bote = TiposCompartidos.safeAdd(bote,1);
            }
        }
        address premiado = usuarioServiceImpl.getIndiceUsuarios(ganador);
        _transfer(owner, premiado, bote);
        boteServiceImpl.setBotes(premiado,_fechaTax,bote);
        boteServiceImpl.setIndiceBotes(_fechaTax);
        boteServiceImpl.setNumeroBotes(TiposCompartidos.safeAdd(boteServiceImpl.getNumeroBotes(), 1));
        fechaTax = _fechaTax;
    }

    function getBalance(address addr) public view returns(uint) {
		return tokenDaoImpl.getBalance(addr);
	}

    function getRevenue(uint amount) public onlyCallers {
        owner.transfer(amount);
    }

    function sell(uint amount) public {
        require(tokenDaoImpl.getBalance(msg.sender) >= amount);         
        _transfer(msg.sender, owner, amount);
        uint revenue = TiposCompartidos.safeMul(amount,tokenDaoImpl.getSellPrice());
        if (!msg.sender.send (revenue)) {                
            _transfer(owner, msg.sender, amount);
        }                                   
    }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyCallers {
        tokenDaoImpl.setSellPrice(newSellPrice * 1 finney);
        tokenDaoImpl.setBuyPrice(newBuyPrice * 1 finney);
    }

    function transfer(address _to, uint _value) public {
        _transfer(msg.sender, _to, _value);
        usuarioServiceImpl.incluirUsuario(_to);
    }
    
    function getFechaTax() public view returns(uint) {
        return fechaTax;
    }
    
    function setFechaTax(uint256 _fechaTax) public onlyCallers{
        fechaTax = _fechaTax;
    }

    function _transfer(address _from, address _to, uint _value) public {
        require(_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require(tokenDaoImpl.getBalance(_from) >= _value);                // Check if the sender has enough
        require(TiposCompartidos.safeAdd(tokenDaoImpl.getBalance(_to),_value) > tokenDaoImpl.getBalance(_to)); // Check for overflows
        tokenDaoImpl.setBalance(_from,TiposCompartidos.safeSub(tokenDaoImpl.getBalance(_from),_value));                         
        tokenDaoImpl.setBalance(_to,TiposCompartidos.safeAdd(tokenDaoImpl.getBalance(_to),_value));                           
    }
}