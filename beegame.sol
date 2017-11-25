pragma solidity ^0.4.18;

import 'https://github.com/empresarioMadri/beegame/boteDao.sol';
import 'https://github.com/empresarioMadri/beegame/celdaDao.sol';
import 'https://github.com/empresarioMadri/beegame/mensajeDao.sol';
import 'https://github.com/empresarioMadri/beegame/tokenDao.sol';
import 'https://github.com/empresarioMadri/beegame/usuarioDao.sol';
import 'https://github.com/empresarioMadri/beegame/TiposCompartidos.sol';

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract BeeGame is owned {

    address tokenDao;
    TokenDao internal tokenDaoImpl;

    address celdaDao;
    CeldaDao internal celdaDaoImpl;

    address mensajeDao;
    MensajeDao internal mensajeDaoImpl;

    address boteDao;
    BoteDao internal boteDaoImpl;

    address usuarioDao;
    UsuarioDao internal usuarioDaoImpl;
    
    uint fechaTax;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event TransferKO(address indexed from, address indexed to, uint256 value);
    
    function BeeGame (
        uint256 initialSupply,
        uint256 newSellPrice,
        uint256 newBuyPrice,
        uint _fechaTax) public {
        boteDao = new BoteDao(this);
        boteDaoImpl = BoteDao(boteDao);

        celdaDao = new CeldaDao(this);
        celdaDaoImpl = CeldaDao(celdaDao);

        mensajeDao = new MensajeDao(this);
        mensajeDaoImpl = MensajeDao(mensajeDao);

        tokenDao = new TokenDao(this,initialSupply,newSellPrice,newBuyPrice);
        tokenDaoImpl = TokenDao(tokenDao);

        usuarioDao = new UsuarioDao(this);
        usuarioDaoImpl = UsuarioDao(usuarioDao);


        fechaTax = _fechaTax;
        tokenDaoImpl.setBalance(owner,initialSupply);
        setPrices(newSellPrice,newBuyPrice);
        celdaDaoImpl.setNumeroCeldas(0);
        tokenDaoImpl.setName("Beether");
        tokenDaoImpl.setSymbol("beeth"); 
        tokenDaoImpl.setDecimals(2);
        celdaDaoImpl.setIndiceCeldas(1509302402021);
        celdaDaoImpl.setNumeroCeldas(safeAdd(celdaDaoImpl.getNumeroCeldas(),1));
        usuarioDaoImpl.setNumeroUsuarios(safeAdd(usuarioDaoImpl.getNumeroUsuarios(),1));
        usuarioDaoImpl.setIndiceUsuarios(msg.sender);
        celdaDaoImpl.setCeldas(msg.sender,
            0, 
            3,
            1509302402021,
            0,
            0,
            0,
            0,
            0,
            0,
            TiposCompartidos.TipoPremio.none,
            false);
    }

    function buy() public payable {
        uint amount = msg.value / tokenDaoImpl.getBuyPrice();         
        require(tokenDaoImpl.getBalance(owner) >= amount); 
        _transfer(owner, msg.sender, amount);
        incluirUsuario(msg.sender);
        Transfer(owner, msg.sender, amount); 
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
            usuarioDaoImpl.setNumeroUsuarios(safeAdd(usuarioDaoImpl.getNumeroUsuarios(),1));
        }
    }

    function getBote() public view returns(uint) {
        uint retorno;
        for (uint i = 0; i < usuarioDaoImpl.getNumeroUsuarios(); i++) {
            address usuario = usuarioDaoImpl.getIndiceUsuarios(i);
            if (tokenDaoImpl.getBalance(usuario) > 0) {
                retorno = safeAdd(retorno,1);
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
                bote = safeAdd(bote,1);
            }
        }
        address premiado = usuarioDaoImpl.getIndiceUsuarios(ganador);
        _transfer(owner, premiado, bote);
        boteDaoImpl.setBotes(premiado,_fechaTax,bote);
        boteDaoImpl.setIndiceBotes(_fechaTax);
        boteDaoImpl.setNumeroBotes(safeAdd(boteDaoImpl.getNumeroBotes(), 1));

        fechaTax = _fechaTax;
    }

    function getCeldaO(uint256 id) internal returns (TiposCompartidos.Celda){
        TiposCompartidos.Celda memory celda;
        (celda.creador,celda.polenPositivos,celda.polenNegativos
        ,celda.fechaCreacion,celda.primeraPosicion,celda.segundaPosicion
        ,celda.terceraPosicion, celda.cuartaPosicion,celda.quintaPosicion
        ,celda.sextaPosicion,celda.tipo,celda.premio) = celdaDaoImpl.getCeldas(id);
        return celda;
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
        if (getCeldaO(_fechaCreacion).fechaCreacion == _fechaCreacion) {
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
            celdaDaoImpl.setNumeroCeldas(safeAdd(celdaDaoImpl.getNumeroCeldas(), 1));
        }
        celdaDaoImpl.setCeldasO(_fechaCreacion,celda);
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
            _transfer(repartidor,celdaPadre.creador,safeMul(2,multiplicador));
            celdaPadre.polenPositivos = safeAdd(celdaPadre.polenPositivos,safeMul(2,multiplicador));
            celdaAbuelo.polenPositivos = safeAdd(celdaAbuelo.polenPositivos,safeMul(1,multiplicador));
            _transfer(repartidor,celdaAbuelo.creador,safeMul(1,multiplicador));
            celdaDaoImpl.setCeldasO(celdaAbuelo.fechaCreacion,celdaAbuelo);
        }else if (!celda.premio) {
            _transfer(repartidor,celdaPadre.creador,safeMul(3,multiplicador));
            celdaPadre.polenPositivos = safeAdd(celdaPadre.polenPositivos,safeMul(3,multiplicador));
        }
        celdaDaoImpl.setCeldasO(celdaPadre.fechaCreacion,celdaPadre);
    }

    function getBote(uint index) public view returns (address premiado, uint polenes, uint256 fechaCreacion){
        uint256 indexA = boteDaoImpl.getIndiceBotes(index);
        TiposCompartidos.Bote memory bote = boteDaoImpl.getBotesO(indexA);
        return (bote.premiado, bote.polenes, bote.fechaCreacion);
    }

    function getCelda(uint index) public view returns (address creador, uint polenPositivos, uint polenNegativos, uint fechaCreacion, 
                                            uint primeraPosicion, uint segundaPosicion, uint terceraPosicion,
                                            uint cuartaPosicion, uint quintaPosicion, uint sextaPosicion, TiposCompartidos.TipoPremio tipo, bool premio) {
        uint256 indexA = celdaDaoImpl.getIndiceCeldas(index);
        TiposCompartidos.Celda memory  celda = getCeldaO(indexA);
        return (celda.creador,celda.polenPositivos,celda.polenNegativos,celda.fechaCreacion,
        celda.primeraPosicion, celda.segundaPosicion, celda.terceraPosicion, celda.cuartaPosicion, 
        celda.quintaPosicion, celda.sextaPosicion, celda.tipo, celda.premio);
    }

    function getMensajesO(uint256 index) internal returns (TiposCompartidos.Mensaje) {
        TiposCompartidos.Mensaje memory mensaje;
        (mensaje.creador,mensaje.apodo,mensaje.fechaCreacion,mensaje.mensaje,mensaje.estado,mensaje.motivo) = mensajeDaoImpl.getMensajes(index);
        return mensaje;

    }

    function getMensaje(uint index) public view returns(address creador,uint fechaCreacion,string _mensaje,string apodo, TiposCompartidos.EstadoMensaje estado, string motivo){
        uint256 indexA = mensajeDaoImpl.getIndiceMensajes(index);
        TiposCompartidos.Mensaje memory mensaje = getMensajesO(indexA);
        return (mensaje.creador,mensaje.fechaCreacion,mensaje.mensaje,mensaje.apodo,mensaje.estado,mensaje.motivo);
    }

    function insertarMensaje(uint256 _fechaCreacion, string _apodo,string _mensaje) public {
        bool encontrado = false;
        for (uint i = 0; i < usuarioDaoImpl.getNumeroUsuarios() && !encontrado; i++) {
            address usuarioT = usuarioDaoImpl.getIndiceUsuarios(i);
            if (usuarioT == msg.sender) {
                encontrado = true;
            }
        }
        require(encontrado);
        mensajeDaoImpl.setIndiceMensajes(_fechaCreacion);
        mensajeDaoImpl.setNumeroMensajes(safeAdd(mensajeDaoImpl.getNumeroMensajes(),1));
        TiposCompartidos.Mensaje memory mensaje = TiposCompartidos.Mensaje({
            creador:msg.sender,
            apodo:_apodo,
            fechaCreacion:_fechaCreacion,
            mensaje:_mensaje,
            estado:TiposCompartidos.EstadoMensaje.aprobado,
            motivo:""
        });
        mensajeDaoImpl.setMensajesO(_fechaCreacion,mensaje);
    }

    function aprobarMensaje(uint256 _fechaCreacion,TiposCompartidos.EstadoMensaje _estado,string _motivo) public onlyOwner {
        TiposCompartidos.Mensaje memory mensaje = getMensajesO(_fechaCreacion);
        mensaje.estado = _estado;
        mensaje.motivo = _motivo;
        mensajeDaoImpl.setMensajesO(_fechaCreacion, mensaje);
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
        uint revenue = safeMul(amount,tokenDaoImpl.getSellPrice());
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
        require(safeAdd(tokenDaoImpl.getBalance(_to),_value) > tokenDaoImpl.getBalance(_to)); // Check for overflows
        tokenDaoImpl.setBalance(_from,safeSub(tokenDaoImpl.getBalance(_from),_value));                         
        tokenDaoImpl.setBalance(_to,safeAdd(tokenDaoImpl.getBalance(_to),_value));                           
        Transfer(_from, _to, _value);
    }

    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
}