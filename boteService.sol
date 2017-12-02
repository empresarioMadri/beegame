pragma solidity ^0.4.18;

import './calledA.sol';
import './TiposCompartidos.sol';
import './boteDao.sol';

contract BoteService is CalledA {

    address internal boteDao;
    BoteDao internal boteDaoImpl;

    function setBotes(address premiado,uint256 fecha,uint polenes) public{
        boteDaoImpl.setBotes(premiado,fecha,polenes);
    }
    
    function setNumeroBotes(uint numero) public onlyCallers {
        boteDaoImpl.setNumeroBotes(numero);
    }
    
    function setIndiceBotes(uint256 value) public onlyCallers {
        boteDaoImpl.setIndiceBotes(value);
    }
    
    function getBoteIndex(uint index) public view returns (address premiado, uint polenes, uint256 fechaCreacion){
        uint256 indexA = boteDaoImpl.getIndiceBotes(index);
        TiposCompartidos.Bote memory bote;
        (bote.premiado,bote.fechaCreacion,bote.polenes)= boteDaoImpl.getBotes(indexA);
        return (bote.premiado, bote.polenes, bote.fechaCreacion);
    }

    function setBoteDao(address _boteDao)public onlyCallers {
        boteDao = _boteDao;
        boteDaoImpl = BoteDao(boteDao);
    }
    
    function getBoteDao() public view returns(address){
        return boteDao;
    }

    function getNumeroBotes() public view returns(uint) {
        return boteDaoImpl.getNumeroBotes();
    }

}