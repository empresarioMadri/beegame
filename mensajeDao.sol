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
    mapping (uint256 => TiposCompartidos.Mensaje) mensajes;
    uint256[] indiceMensajes;

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
        
        Mensaje memory mensaje = mensajes[id];
        return (mensaje.creador,mensaje.apodo,mensaje.fechaCreacion,mensaje.mensaje,mensaje.estado,mensaje.motivo);
    }

    function setMensaje(uint256 _fechaCreacion, string _apodo,string _mensaje,EstadoMensaje _estado, string motivo) public onlyLlamador {
        Mensaje memory mensaje = Mensaje({
            creador:msg.sender,
            apodo:_apodo,
            fechaCreacion:_fechaCreacion,
            mensaje:_mensaje,
            estado:_estado,
            motivo:_motivo
        });
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