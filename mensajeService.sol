pragma solidity ^0.4.18;

import './calledA.sol';
import './mensajeDao.sol';
import './usuarioService.sol';


contract MensajeService is CalledA {

    address internal mensajeDao;
    MensajeDao internal mensajeDaoImpl;
    
    address internal usuarioService;
    UsuarioService internal usuarioServiceImpl;
    
    function setUsuarioService(address _usuarioService) public onlyCallers {
        usuarioService = _usuarioService;
        usuarioServiceImpl = UsuarioService(usuarioService);
    }

    function setMensajeDao(address _mensajeDao)public onlyCallers {
        mensajeDao = _mensajeDao;
        mensajeDaoImpl = MensajeDao(mensajeDao);
    }
    
    function getMensajeDao() public view returns(address){
        return mensajeDao;
    }

    function getMensaje(uint index) public view returns(address creador,uint fechaCreacion,bytes32  _mensaje,bytes32  apodo, TiposCompartidos.EstadoMensaje estado, bytes32  motivo){
        uint256 indexA = mensajeDaoImpl.getIndiceMensajes(index);
        TiposCompartidos.Mensaje memory mensaje = getMensajesO(indexA);
        return (mensaje.creador,mensaje.fechaCreacion,mensaje.mensaje,mensaje.apodo,mensaje.estado,mensaje.motivo);
    }
    
    function insertarMensaje(address sender,uint256 _fechaCreacion, bytes32  _apodo,bytes32  _mensaje) public onlyCallers{
        bool encontrado = false;
        for (uint i = 0; i < usuarioServiceImpl.getNumeroUsuarios() && !encontrado; i++) {
            address usuarioT = usuarioServiceImpl.getIndiceUsuarios(i);
            if (usuarioT == sender) {
                encontrado = true;
            }
        }
        require(encontrado);
        mensajeDaoImpl.setIndiceMensajes(_fechaCreacion);
        mensajeDaoImpl.setNumeroMensajes(TiposCompartidos.safeAdd(mensajeDaoImpl.getNumeroMensajes(),1));
        mensajeDaoImpl.setMensajes(sender,_fechaCreacion,_apodo,_mensaje,TiposCompartidos.EstadoMensaje.aprobado,"");
    }
    
    function aprobarMensaje(uint256 _fechaCreacion,TiposCompartidos.EstadoMensaje _estado,bytes32  _motivo) public onlyCallers {
        TiposCompartidos.Mensaje memory mensaje = getMensajesO(_fechaCreacion);
        mensaje.estado = _estado;
        mensaje.motivo = _motivo;
        mensajeDaoImpl.setMensajes(msg.sender,_fechaCreacion,mensaje.apodo,mensaje.mensaje,mensaje.estado,mensaje.motivo);
    }
    
    function getMensajesO(uint256 index) internal view returns (TiposCompartidos.Mensaje) {
        TiposCompartidos.Mensaje memory mensaje;
        (mensaje.creador,mensaje.apodo,mensaje.fechaCreacion,mensaje.mensaje,mensaje.estado,mensaje.motivo) = mensajeDaoImpl.getMensajes(index);
        return mensaje;
    }

    function getNumeroMensajes() public view returns(uint) {
        return mensajeDaoImpl.getNumeroMensajes();
    }


}