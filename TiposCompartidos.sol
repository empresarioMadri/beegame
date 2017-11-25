pragma solidity ^0.4.18;

library TiposCompartidos {
    enum TipoPremio {none,free,x2,x3,x5, surprise }

    enum EstadoMensaje{pendiente,aprobado,rechazado}

    struct Celda {
        address creador;
        uint polenPositivos;
        uint polenNegativos;
        uint fechaCreacion;
        uint primeraPosicion;
        uint segundaPosicion;
        uint terceraPosicion;
        uint cuartaPosicion;
        uint quintaPosicion;
        uint sextaPosicion;
        TipoPremio tipo;
        bool premio;
    }

    struct Mensaje {
        address creador;
        bytes32 apodo;
        uint fechaCreacion;
        bytes32 mensaje;
        TiposCompartidos.EstadoMensaje estado;
        bytes32 motivo;
    }

    struct Premio {
        address premiado;
        uint fechaCreacion;
        uint polenes;
    }

    struct Bote {
        address premiado;
        uint fechaCreacion;
        uint polenes;
    }
    
}