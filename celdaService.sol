pragma solidity ^0.4.18;

import './celdaDao.sol';
import './calledA.sol';
import './TiposCompartidos.sol';
import './tokenService.sol';

contract CeldaService is CalledA {

    address internal celdaDao; 
    CeldaDao internal celdaDaoImpl;

    address internal tokenService;
    TokenService internal tokenServiceImpl;
    
    address internal creadorTmp;
    address internal owner;
    
    function CeldaService() public {
        owner = msg.sender;
    }
    
    function setTokenService(address _tokenService) public onlyCallers {
        tokenService = _tokenService;
        tokenServiceImpl = TokenService(tokenService);
    }

    function setCeldaDao(address _celdaDao)public onlyCallers {
        celdaDao = _celdaDao;
        celdaDaoImpl = CeldaDao(celdaDao);
    }
    
    function getCeldaDao() public view returns(address){
        return celdaDao;
    }

    function getCelda1(uint index) public view returns (address creador, uint polenPositivos, uint polenNegativos, uint256 fechaCreacion,
                                            uint primeraPosicion, uint segundaPosicion, uint terceraPosicion) {
        uint256 indexA = celdaDaoImpl.getIndiceCeldas(index);                                               
        TiposCompartidos.Celda memory  celda = getCeldaO(indexA);
        return (celda.creador,celda.polenPositivos,celda.polenNegativos,celda.fechaCreacion, celda.primeraPosicion, celda.segundaPosicion, celda.terceraPosicion);
    }

    function getCelda2(uint index) public view returns (uint cuartaPosicion, uint quintaPosicion, uint sextaPosicion, TiposCompartidos.TipoPremio tipo, bool premio) {
        uint256 indexA = celdaDaoImpl.getIndiceCeldas(index);                                               
        TiposCompartidos.Celda memory  celda = getCeldaO(indexA);
        return (celda.cuartaPosicion, 
        celda.quintaPosicion, celda.sextaPosicion, celda.tipo, celda.premio);
    }
    
    function getCeldaO(uint256 id) internal view returns (TiposCompartidos.Celda){
        TiposCompartidos.Celda memory celda;
        (celda.creador,celda.polenPositivos,celda.polenNegativos,celda.fechaCreacion
        ,celda.primeraPosicion,celda.segundaPosicion
        ,celda.terceraPosicion) = celdaDaoImpl.getCeldas1(id); 
        (celda.cuartaPosicion,celda.quintaPosicion,celda.sextaPosicion,celda.tipo,celda.premio) = celdaDaoImpl.getCeldas2(id);
        return celda;
    }

    function getNumeroCeldas() public view returns(uint) {
        return celdaDaoImpl.getNumeroCeldas();
    }
    
    function setCreador(address _creador) public onlyCallers{
        creadorTmp = _creador;
    }

    function crearCelda(uint _polenes, uint256 _fechaCreacion, uint posicion, uint _celdaPadre, uint _celdaAbuelo, TiposCompartidos.TipoPremio tipo) public {
        require(tokenServiceImpl.getBalance(creadorTmp)>=3);
        require(_polenes == 3);
        require(_celdaPadre != 0);
        require((posicion >= 0 && posicion < 7) || (posicion == 0 && creadorTmp == owner));
        require(((tipo == TiposCompartidos.TipoPremio.free || tipo == TiposCompartidos.TipoPremio.x2 || tipo == TiposCompartidos.TipoPremio.x3 || tipo == TiposCompartidos.TipoPremio.x5 || tipo == TiposCompartidos.TipoPremio.surprise) && creadorTmp == owner) || tipo == TiposCompartidos.TipoPremio.none);
        TiposCompartidos.Celda memory celdaPadre = getCeldaO(_celdaPadre);
        require(
            ((posicion == 1 && celdaPadre.primeraPosicion == 0) || getCeldaO(celdaPadre.primeraPosicion).tipo != TiposCompartidos.TipoPremio.none ) || 
            ((posicion == 2 && celdaPadre.segundaPosicion == 0) || getCeldaO(celdaPadre.segundaPosicion).tipo != TiposCompartidos.TipoPremio.none ) || 
            ((posicion == 3 && celdaPadre.terceraPosicion == 0) || getCeldaO(celdaPadre.terceraPosicion).tipo != TiposCompartidos.TipoPremio.none ) || 
            ((posicion == 4 && celdaPadre.cuartaPosicion == 0)  || getCeldaO(celdaPadre.cuartaPosicion).tipo != TiposCompartidos.TipoPremio.none ) || 
            ((posicion == 5 && celdaPadre.quintaPosicion == 0)  || getCeldaO(celdaPadre.quintaPosicion).tipo != TiposCompartidos.TipoPremio.none ) || 
            ((posicion == 6 && celdaPadre.sextaPosicion == 0) || getCeldaO(celdaPadre.sextaPosicion).tipo != TiposCompartidos.TipoPremio.none )
        );
        TiposCompartidos.Celda memory celda;
        TiposCompartidos.TipoPremio tipoPremio;
        TiposCompartidos.Celda memory celdaNew = getCeldaO(_fechaCreacion);
        if (celdaNew.fechaCreacion == _fechaCreacion) {
            celda = getCeldaO(_fechaCreacion);
            celda.creador = creadorTmp;
            celda.premio = false;
            tipoPremio = celda.tipo;
            celda.tipo = TiposCompartidos.TipoPremio.none;
        } else {
            if (creadorTmp != owner) {
                celda = TiposCompartidos.Celda({
                    creador:creadorTmp,
                    polenPositivos : 0, 
                    polenNegativos : _polenes,
                    fechaCreacion: _fechaCreacion,
                    primeraPosicion : 0,
                    segundaPosicion : 0,
                    terceraPosicion : 0,
                    cuartaPosicion : 0,
                    quintaPosicion : 0,
                    sextaPosicion : 0,
                    tipo:tipo,
                    premio:false
                });
            }else {
                celda = TiposCompartidos.Celda({
                    creador:creadorTmp,
                    polenPositivos : 0, 
                    polenNegativos : _polenes,
                    fechaCreacion: _fechaCreacion,
                    primeraPosicion : 0,
                    segundaPosicion : 0,
                    terceraPosicion : 0,
                    cuartaPosicion : 0,
                    quintaPosicion : 0,
                    sextaPosicion : 0,
                    tipo:tipo,
                    premio:true
                });
            }
            celdaDaoImpl.setIndiceCeldas(_fechaCreacion);
            celdaDaoImpl.setNumeroCeldas(TiposCompartidos.safeAdd(celdaDaoImpl.getNumeroCeldas(), 1));
        }
        setCeldasO(celda);
        TiposCompartidos.Celda memory celdaAbuelo = getCeldaO(_celdaAbuelo);
        uint multiplicador = 1;
        address repartidor = creadorTmp;
        if (tipoPremio == TiposCompartidos.TipoPremio.x2 && !celda.premio) {
            multiplicador = 2;
            repartidor = owner;
        } else if (tipoPremio == TiposCompartidos.TipoPremio.x3 && !celda.premio) {
            multiplicador = 3;
            repartidor = owner;
        } else if (tipoPremio == TiposCompartidos.TipoPremio.x5 && !celda.premio) {
            multiplicador = 5;
            repartidor = owner;
        }  else if (tipoPremio == TiposCompartidos.TipoPremio.free && !celda.premio) {
            repartidor = owner;
        }
        if (posicion == 1 && celdaPadre.primeraPosicion == 0) {
            celdaPadre.primeraPosicion = _fechaCreacion;   
        }else if (posicion == 2 && celdaPadre.segundaPosicion == 0 ) {
            celdaPadre.segundaPosicion = _fechaCreacion;
        }else if (posicion == 3 && celdaPadre.terceraPosicion == 0) {
            celdaPadre.terceraPosicion = _fechaCreacion;
        }else if (posicion == 4 && celdaPadre.cuartaPosicion == 0) {
            celdaPadre.cuartaPosicion = _fechaCreacion;
        }else if (posicion == 5 && celdaPadre.quintaPosicion == 0) {
            celdaPadre.quintaPosicion = _fechaCreacion;
        }else if (posicion == 6 && celdaPadre.sextaPosicion == 0) {
            celdaPadre.sextaPosicion = _fechaCreacion;
        }
        if (_celdaAbuelo != 0 && !celda.premio) {
            tokenServiceImpl._transfer(repartidor,celdaPadre.creador,TiposCompartidos.safeMul(2,multiplicador));
            celdaPadre.polenPositivos = TiposCompartidos.safeAdd(celdaPadre.polenPositivos,TiposCompartidos.safeMul(2,multiplicador));
            celdaAbuelo.polenPositivos = TiposCompartidos.safeAdd(celdaAbuelo.polenPositivos,TiposCompartidos.safeMul(1,multiplicador));
            tokenServiceImpl._transfer(repartidor,celdaAbuelo.creador,TiposCompartidos.safeMul(1,multiplicador));
            setCeldasO(celdaAbuelo);
        }else if (!celda.premio) {
            tokenServiceImpl._transfer(repartidor,celdaPadre.creador,TiposCompartidos.safeMul(3,multiplicador));
            celdaPadre.polenPositivos = TiposCompartidos.safeAdd(celdaPadre.polenPositivos,TiposCompartidos.safeMul(3,multiplicador));
        }
        setCeldasO(celdaPadre);
    }
    
    
    function setCeldasO(TiposCompartidos.Celda celda) internal {
        celdaDaoImpl.setCeldas1(celda.creador,celda.polenPositivos,celda.polenNegativos
            ,celda.fechaCreacion,celda.primeraPosicion,celda.segundaPosicion,celda.terceraPosicion);
        celdaDaoImpl.setCeldas2(celda.cuartaPosicion
            ,celda.quintaPosicion,celda.sextaPosicion,celda.tipo,celda.premio);
    }

}
