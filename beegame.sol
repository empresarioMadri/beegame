pragma solidity ^0.4.18;

import './owned.sol';
import './TiposCompartidos.sol';
import './boteDao.sol';
import './mensajeDao.sol';
import './celdaDao.sol';
import './tokenDao.sol';
import './usuarioDao.sol';
import './TiposCompartidos.sol';

contract BeeGame is Owned {

    address internal tokenDao = 0xe4a90C6C3C1909305A7EC5148Ca958c59909A473;
    TokenDao internal tokenDaoImpl = TokenDao(tokenDao);

    address internal celdaDao = 0x1aA5B9d3c1E0d6898Bf6858A64bB8c450073d523; 
    CeldaDao internal celdaDaoImpl = CeldaDao(celdaDao);

    address internal mensajeDao = 0x9f10797df33aeFbFED8Cd1A7a5a257Fb66AE00D9;
    MensajeDao internal mensajeDaoImpl = MensajeDao(mensajeDao);

    address internal boteDao = 0x0a49219fa06290F63524cdB35E08d9a80eE6fF70;
    BoteDao internal boteDaoImpl = BoteDao(boteDao);

    address internal usuarioDao = 0x2d6b5093b4Bef15985B5b31484Dc3e1252E030F7;
    UsuarioDao internal usuarioDaoImpl = UsuarioDao(usuarioDao);
    
    uint internal fechaTax;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event TransferKO(address indexed from, address indexed to, uint256 value);
    
    function BeeGame (uint _fechaTax) public {
        fechaTax = _fechaTax; 
    }
    
    function setBoteDao(address _boteDao)public onlyOwner {
        boteDao = _boteDao;
        boteDaoImpl = BoteDao(boteDao);
    }

    function setBoteDaoCaller(address _caller) public onlyOwner {
        boteDaoImpl.transferCallership(_caller);
    }

    function setUsuarioDao(address _usuarioDao)public onlyOwner {
        usuarioDao = _usuarioDao;
        usuarioDaoImpl = UsuarioDao(usuarioDao);
    }

    function setUsuarioDaoCaller(address _caller) public onlyOwner {
        usuarioDaoImpl.transferCallership(_caller);
    }

    function setCeldaDao(address _celdaDao)public onlyOwner {
        celdaDao = _celdaDao;
        celdaDaoImpl = CeldaDao(celdaDao);
    }

    function setCeldaDaoCaller(address _caller) public onlyOwner {
        celdaDaoImpl.transferCallership(_caller);
    }

    function setMensajeDao(address _mensajeDao)public onlyOwner {
        mensajeDao = _mensajeDao;
        mensajeDaoImpl = MensajeDao(mensajeDao);
    }

    function setMensajeDaoCaller(address _caller) public onlyOwner {
        mensajeDaoImpl.transferCallership(_caller);
    }

    function setTokenDao(address _tokenDao)public onlyOwner {
        tokenDao = _tokenDao;
        tokenDaoImpl = TokenDao(tokenDao);
    }

    function setTokenDaoCaller(address _caller) public onlyOwner {
        tokenDaoImpl.transferCallership(_caller);
    }
    
    function buy() public payable {
        uint amount = msg.value / tokenDaoImpl.getBuyPrice();         
        require(tokenDaoImpl.getBalance(owner) >= amount); 
        _transfer(owner, msg.sender, amount);
        incluirUsuario(msg.sender);
        Transfer(owner, msg.sender, amount); 
    }

    
    function getBote() public view returns(uint) {
        uint retorno;
        for (uint i = 0; i < usuarioDaoImpl.getNumeroUsuarios(); i++) {
            address usuario = usuarioDaoImpl.getIndiceUsuarios(i);
            if (tokenDaoImpl.getBalance(usuario) > 0) {
                retorno = TiposCompartidos.safeAdd(retorno,1);
            }
        }
        return retorno;
    }
    
    function cobrarImpuesto(uint _fechaTax,uint ganador) public onlyOwner {
        uint bote = 0;
        for (uint i = 0; i < usuarioDaoImpl.getNumeroUsuarios(); i++) {
            address usuario = usuarioDaoImpl.getIndiceUsuarios(i);
            if (tokenDaoImpl.getBalance(usuario) > 0) {
                _transfer(usuario, owner, 1);
                bote = TiposCompartidos.safeAdd(bote,1);
            }
        }
        address premiado = usuarioDaoImpl.getIndiceUsuarios(ganador);
        _transfer(owner, premiado, bote);
        boteDaoImpl.setBotes(premiado,_fechaTax,bote);
        boteDaoImpl.setIndiceBotes(_fechaTax);
        boteDaoImpl.setNumeroBotes(TiposCompartidos.safeAdd(boteDaoImpl.getNumeroBotes(), 1));

        fechaTax = _fechaTax;
    }
    
    function crearCelda(uint _polenes, uint256 _fechaCreacion, uint posicion, uint _celdaPadre, uint _celdaAbuelo, TiposCompartidos.TipoPremio tipo) public {
        require(tokenDaoImpl.getBalance(msg.sender)>=3);
        require(_polenes == 3);
        require(_celdaPadre != 0);
        require((posicion >= 0 && posicion < 7) || (posicion == 0 && msg.sender == owner));
        require(((tipo == TiposCompartidos.TipoPremio.free || tipo == TiposCompartidos.TipoPremio.x2 || tipo == TiposCompartidos.TipoPremio.x3 || tipo == TiposCompartidos.TipoPremio.x5 || tipo == TiposCompartidos.TipoPremio.surprise) && msg.sender == owner) || tipo == TiposCompartidos.TipoPremio.none);
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
            celda.creador = msg.sender;
            celda.premio = false;
            tipoPremio = celda.tipo;
            celda.tipo = TiposCompartidos.TipoPremio.none;
        } else {
            if (msg.sender != owner) {
                celda = TiposCompartidos.Celda({
                    creador:msg.sender,
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
                    creador:msg.sender,
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
        address repartidor = msg.sender;
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
            _transfer(repartidor,celdaPadre.creador,TiposCompartidos.safeMul(2,multiplicador));
            celdaPadre.polenPositivos = TiposCompartidos.safeAdd(celdaPadre.polenPositivos,TiposCompartidos.safeMul(2,multiplicador));
            celdaAbuelo.polenPositivos = TiposCompartidos.safeAdd(celdaAbuelo.polenPositivos,TiposCompartidos.safeMul(1,multiplicador));
            _transfer(repartidor,celdaAbuelo.creador,TiposCompartidos.safeMul(1,multiplicador));
            setCeldasO(celdaAbuelo);
        }else if (!celda.premio) {
            _transfer(repartidor,celdaPadre.creador,TiposCompartidos.safeMul(3,multiplicador));
            celdaPadre.polenPositivos = TiposCompartidos.safeAdd(celdaPadre.polenPositivos,TiposCompartidos.safeMul(3,multiplicador));
        }
        setCeldasO(celdaPadre);
    }
    
    
    function setCeldasO(TiposCompartidos.Celda celda) internal {
        celdaDaoImpl.setCeldas(celda.creador,celda.polenPositivos,celda.polenNegativos
            ,celda.fechaCreacion,celda.primeraPosicion,celda.segundaPosicion,celda.terceraPosicion,celda.cuartaPosicion
            ,celda.quintaPosicion,celda.sextaPosicion,celda.tipo,celda.premio);
    }
    
    
    function getBote(uint index) public view returns (address premiado, uint polenes, uint256 fechaCreacion){
        uint256 indexA = boteDaoImpl.getIndiceBotes(index);
        TiposCompartidos.Bote memory bote;
        (bote.premiado,bote.fechaCreacion,bote.polenes)= boteDaoImpl.getBotes(indexA);
        return (bote.premiado, bote.polenes, bote.fechaCreacion);
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

    function bytes32ToStr(bytes32 _bytes32) internal pure returns (string) {
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function getMensaje(uint index) public view returns(address creador,uint fechaCreacion,string  _mensaje,string  apodo, TiposCompartidos.EstadoMensaje estado, string  motivo){
        uint256 indexA = mensajeDaoImpl.getIndiceMensajes(index);
        TiposCompartidos.Mensaje memory mensaje = getMensajesO(indexA);
        return (mensaje.creador,mensaje.fechaCreacion,bytes32ToStr(mensaje.mensaje),bytes32ToStr(mensaje.apodo),mensaje.estado,bytes32ToStr(mensaje.motivo));
    }
    
    function insertarMensaje(uint256 _fechaCreacion, bytes32  _apodo,bytes32  _mensaje) public {
        bool encontrado = false;
        for (uint i = 0; i < usuarioDaoImpl.getNumeroUsuarios() && !encontrado; i++) {
            address usuarioT = usuarioDaoImpl.getIndiceUsuarios(i);
            if (usuarioT == msg.sender) {
                encontrado = true;
            }
        }
        require(encontrado);
        mensajeDaoImpl.setIndiceMensajes(_fechaCreacion);
        mensajeDaoImpl.setNumeroMensajes(TiposCompartidos.safeAdd(mensajeDaoImpl.getNumeroMensajes(),1));
        TiposCompartidos.Mensaje memory mensaje = TiposCompartidos.Mensaje({
            creador:msg.sender,
            apodo:_apodo,
            fechaCreacion:_fechaCreacion,
            mensaje:_mensaje,
            estado:TiposCompartidos.EstadoMensaje.aprobado,
            motivo:""
        });
        mensajeDaoImpl.setMensajes(_fechaCreacion,mensaje.apodo,mensaje.mensaje,mensaje.estado,mensaje.motivo);
    }
    
    function aprobarMensaje(uint256 _fechaCreacion,TiposCompartidos.EstadoMensaje _estado,bytes32  _motivo) public onlyOwner {
        TiposCompartidos.Mensaje memory mensaje = getMensajesO(_fechaCreacion);
        mensaje.estado = _estado;
        mensaje.motivo = _motivo;
        mensajeDaoImpl.setMensajes(_fechaCreacion,mensaje.apodo,mensaje.mensaje,mensaje.estado,mensaje.motivo);
    }
    
    function getMensajesO(uint256 index) internal view returns (TiposCompartidos.Mensaje) {
        TiposCompartidos.Mensaje memory mensaje;
        (mensaje.creador,mensaje.apodo,mensaje.fechaCreacion,mensaje.mensaje,mensaje.estado,mensaje.motivo) = mensajeDaoImpl.getMensajes(index);
        return mensaje;
    }

    function getBalance(address addr) public view returns(uint) {
		return tokenDaoImpl.getBalance(addr);
	}

    function getFechaTax() public view returns(uint) {
        return fechaTax;
    }

    function getNumeroCeldas() public view returns(uint) {
        return celdaDaoImpl.getNumeroCeldas();
    }

    function getNumeroUsuarios() public view returns(uint) {
        return usuarioDaoImpl.getNumeroUsuarios();
    }

    function getNumeroBotes() public view returns(uint) {
        return boteDaoImpl.getNumeroBotes();
    }

    function getNumeroMensajes() public view returns(uint) {
        return mensajeDaoImpl.getNumeroMensajes();
    }

    function getOwner() public view returns(address) {
        return owner;
    }

    function getRevenue(uint amount) public onlyOwner {
        owner.transfer(amount);
    }
    
    function sell(uint amount) public {
        require(tokenDaoImpl.getBalance(msg.sender) >= amount);         
        _transfer(msg.sender, owner, amount);
        uint revenue = TiposCompartidos.safeMul(amount,tokenDaoImpl.getSellPrice());
        if (msg.sender.send (revenue)) {                
            Transfer(msg.sender, owner, revenue);  
        }else {
            _transfer(owner, msg.sender, amount);
            TransferKO(msg.sender, this, revenue);
        }                                   
    }

    function setFechaTax(uint _fechaTax) public onlyOwner {
        fechaTax = _fechaTax;
    }

    function incluirUsuario(address usuario) public {
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

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyOwner {
        tokenDaoImpl.setSellPrice(newSellPrice * 1 finney);
        tokenDaoImpl.setBuyPrice(newBuyPrice * 1 finney);
    }

    function transfer(address _to, uint _value) public {
        _transfer(msg.sender, _to, _value);
        incluirUsuario(_to);
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require(tokenDaoImpl.getBalance(_from) >= _value);                // Check if the sender has enough
        require(TiposCompartidos.safeAdd(tokenDaoImpl.getBalance(_to),_value) > tokenDaoImpl.getBalance(_to)); // Check for overflows
        tokenDaoImpl.setBalance(_from,TiposCompartidos.safeSub(tokenDaoImpl.getBalance(_from),_value));                         
        tokenDaoImpl.setBalance(_to,TiposCompartidos.safeAdd(tokenDaoImpl.getBalance(_to),_value));                           
        Transfer(_from, _to, _value);
    }
}