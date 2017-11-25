pragma solidity ^0.4.18;

import 'https://github.com/empresarioMadri/beegame/TiposCompartidos.sol';

contract MensajeDao {

    uint internal numeroMensajes;
    mapping (uint256 => TiposCompartidos.Mensaje) mensajes;
    uint256[] indiceMensajes;
    address llamador;

    function MensajeDao(
        address _llamador
    ) public {
        llamador = _llamador;
    }

    function getNumeroMensajes() public view returns(uint) {
        return numeroMensajes;
    }

    function setNumeroMensajes(uint numero) public onlyLlamador {
        numeroMensajes = numero;
    }

    function getIndiceMensajes(uint indice) public view returns(uint256) {
        return indiceMensajes[indice];
    }

    function setIndiceMensajes(uint256 value) public onlyLlamador {
        indiceMensajes.push(value);
    }

    function getMensajes(uint256 id) public view returns(
        address creador, string apodo, uint256 fechaCreacion, 
        string mensaje, TiposCompartidos.EstadoMensaje estado, string motivo) {
        
        TiposCompartidos.Mensaje memory mensajeO = mensajes[id];
        return (mensajeO.creador,mensajeO.apodo,mensajeO.fechaCreacion,mensajeO.mensaje,mensajeO.estado,mensajeO.motivo);
    }

    function getMensajesO(uint256 id) public view returns(
        TiposCompartidos.Mensaje mensaje) {
        TiposCompartidos.Mensaje memory mensajeO = mensajes[id];
        return mensajeO;
    }

    function setMensaje(uint256 _fechaCreacion, string _apodo,string _mensaje,TiposCompartidos.EstadoMensaje _estado, string _motivo) public onlyLlamador {
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

    function setMensajeO(uint256 _fechaCreacion, TiposCompartidos.Mensaje mensaje) public onlyLlamador {
        mensajes[_fechaCreacion] = mensaje;
    }

    function cambiarLlamador(address _llamador) public onlyLlamador {
        llamador = _llamador;
    }
    modifier onlyLlamador {
        require(msg.sender == llamador);
        _;
    }
}