pragma solidity ^0.4.18;

import './calledA.sol';
import './usuarioDao.sol';
import './TiposCompartidos.sol';

contract UsuarioService is CalledA {

    address internal usuarioDao;
    UsuarioDao internal usuarioDaoImpl;
    
    function UsuarioService() public {
        
    }

    function setUsuarioDao(address _usuarioDao)public onlyCallers {
        usuarioDao = _usuarioDao;
        usuarioDaoImpl = UsuarioDao(usuarioDao);
    }
    
    function getUsuarioDao() public view returns(address){
        return usuarioDao;
    }

    function getNumeroUsuarios() public view returns(uint) {
        return usuarioDaoImpl.getNumeroUsuarios();
    }

    function incluirUsuario(address usuario) public onlyCallers{
        bool encontrado = false;
        for (uint i = 0; i < usuarioDaoImpl.getNumeroUsuarios(); i++) {
            address usuarioT = usuarioDaoImpl.getIndiceUsuarios(i);
            if (usuarioT == usuario) {
                encontrado = true;
            }
        }
        if (!encontrado){
            usuarioDaoImpl.setIndiceUsuarios(usuario);
            usuarioDaoImpl.setNumeroUsuarios(TiposCompartidos.safeAdd(usuarioDaoImpl.getNumeroUsuarios(),1));
        }
    }
    
    function getIndiceUsuarios(uint index) public view returns (address) {
        return usuarioDaoImpl.getIndiceUsuarios(index);
    }


}