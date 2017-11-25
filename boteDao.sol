pragma solidity ^0.4.18;


contract CeldaDao {

    struct Bote {
        address premiado;
        uint256 fechaCreacion;
        uint polenes;
    }

    uint internal numeroBotes;
    mapping (uint256 => Bote) botes;
    uint256[] indiceBotes;
    address llamador;

    function BoteDao(
        address _llamador
    ) {
        llamador = _llamador;
    }

    function getNumeroBotes() public view returns(uint) {
        return numeroBotes;
    }

    function setNumeroBotes(uint numero) public onlyLlamador {
        numeroBotes = numero;
    }

    function getIndiceBotes(uint indice) public view returns(uint256) {
        return indiceBotes[indice];
    }

    function setIndiceBotes(uint256 value) public onlyLlamador {
        indiceBotes.push(value);
    }

    function getBotes(uint256 id) public view returns(
        address creador,uint256 fechaCreacion,uint polenes) {
        
        Bote memory bote = botes[id];
        return (bote.creador,bote.fechaCreacion,bote.polenes);
    }

    function setBotes(address creador,uint256 _fechaCreacion,uint _polenes)
    {
        Bote memory bote = Bote({
            creador:msg.sender,
            fechaCreacion:_fechaCreacion,
            polenes:_polenes
        });
        botes[_fechaCreacion] = bote;
    }

    modifier onlyLlamador {
        require(msg.sender == llamador);
        _;
    }

}