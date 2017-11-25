pragma solidity ^0.4.18;

contract MensajeDao {

    enum EstadoMensaje{pendiente,aprobado,rechazado}

    struct Mensaje {
        address creador;
        string apodo;
        uint256 fechaCreacion;
        string mensaje;
        EstadoMensaje estado;
        string motivo;
    }

    uint internal numeroMensajes;
    mapping (uint256 => Mensaje) mensajes;
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
        string mensaje, EstadoMensaje estado, string motivo) {
        
        Mensaje memory mensajeO = mensajes[id];
        return (mensajeO.creador,mensajeO.apodo,mensajeO.fechaCreacion,mensajeO.mensaje,mensajeO.estado,mensajeO.motivo);
    }

    function setMensaje(uint256 _fechaCreacion, string _apodo,string _mensaje,EstadoMensaje _estado, string motivo) public onlyLlamador {
        mensajeO = Mensaje({
            creador:msg.sender,
            apodo:_apodo,
            fechaCreacion:_fechaCreacion,
            mensaje:_mensaje,
            estado:_estado,
            motivo:_motivo
        });
        mensajes[_fechaCreacion] = mensajeO;
    }

    function cambiarLlamador(address _llamador) public onlyLlamador {
        llamador = _llamador;
    }
    modifier onlyLlamador {
        require(msg.sender == llamador);
        _;
    }
}