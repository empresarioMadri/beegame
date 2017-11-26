pragma solidity ^0.4.18;

import 'https://github.com/empresarioMadri/beegame/TiposCompartidos.sol';
import 'https://github.com/empresarioMadri/beegame/owned.sol';

contract MensajeDao is Owned {

    uint internal numeroMensajes;
    mapping (uint256 => TiposCompartidos.Mensaje) mensajes;
    uint256[] indiceMensajes;

    function MensajeDao() public {
        numeroMensajes = 1;
        uint256 ahora = now * 1000;
        indiceMensajes.push(ahora);
        TiposCompartidos.Mensaje memory mensaje = TiposCompartidos.Mensaje(
            {
                creador:msg.sender,
                apodo:stringToBytes32("Admin"),
                fechaCreacion:ahora,
                mensaje:stringToBytes32("Welcome to beegame"),
                estado:TiposCompartidos.EstadoMensaje.aprobado,
                motivo:stringToBytes32("")
            }
        );
        mensajes[ahora] = mensaje;
    }

    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
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

    function getMensajes(uint id) public view returns(
        address creador, bytes32  apodo, uint256 fechaCreacion, 
        bytes32  mensaje, TiposCompartidos.EstadoMensaje estado, bytes32  motivo) {
        uint256 indexA = indiceMensajes[id];
        TiposCompartidos.Mensaje memory mensajeO = mensajes[indexA];
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