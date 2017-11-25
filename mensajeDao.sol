pragma solidity ^0.4.18;

import 'https://github.com/empresarioMadri/beegame/TiposCompartidos.sol';
import 'https://github.com/empresarioMadri/beegame/owned.sol';

contract MensajeDao is Owned {

    uint internal numeroMensajes;
    mapping (uint256 => TiposCompartidos.Mensaje) mensajes;
    uint256[] indiceMensajes;

    function MensajeDao() public {
        
    }

    function getNumeroMensajes() public view returns(uint) {
        return numeroMensajes;
    }

    function setNumeroMensajes(uint numero) public onlyOwner {
        numeroMensajes = numero;
    }

    function getIndiceMensajes(uint indice) public view returns(uint256) {
        return indiceMensajes[indice];
    }

    function setIndiceMensajes(uint256 value) public onlyOwner {
        indiceMensajes.push(value);
    }

    function getMensajes(uint256 id) public view returns(
        address creador, bytes32  apodo, uint256 fechaCreacion, 
        bytes32  mensaje, TiposCompartidos.EstadoMensaje estado, bytes32  motivo) {
        
        TiposCompartidos.Mensaje memory mensajeO = mensajes[id];
        return (mensajeO.creador,mensajeO.apodo,mensajeO.fechaCreacion,mensajeO.mensaje,mensajeO.estado,mensajeO.motivo);
    }

    function setMensajes(uint256 _fechaCreacion, bytes32  _apodo,bytes32  _mensaje,TiposCompartidos.EstadoMensaje _estado, bytes32  _motivo) public onlyOwner {
        TiposCompartidos.Mensaje memory mensaje = TiposCompartidos.Mensaje({
            creador:msg.sender,
            apodo:_apodo,
            fechaCreacion:_fechaCreacion,
            mensaje:_mensaje,
            estado:_estado,
            motivo:_motivo
        });
        mensajes[_fechaCreacion] = mensaje;
    }
}