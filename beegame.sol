pragma solidity ^0.4.18;

import 'https://github.com/empresarioMadri/beegame/boteDao.sol';
import 'https://github.com/empresarioMadri/beegame/celdaDao.sol';
import 'https://github.com/empresarioMadri/beegame/mensajeDao.sol';
import 'https://github.com/empresarioMadri/beegame/tokenDao.sol';
import 'https://github.com/empresarioMadri/beegame/usuarioDao.sol';

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

    enum TipoPremio {none,free,x2,x3,x5, surprise }
    struct Celda {
        address creador;
        uint polenPositivos;
        uint polenNegativos;
        uint256 fechaCreacion;
        uint primeraPosicion;
        uint segundaPosicion;
        uint terceraPosicion;
        uint cuartaPosicion;
        uint quintaPosicion;
        uint sextaPosicion;
        TipoPremio tipo;
        bool premio;
    }

    struct Bote {
        address premiado;
        uint256 fechaCreacion;
        uint polenes;
    }

    enum EstadoMensaje{pendiente,aprobado,rechazado}

    struct Mensaje {
        address creador;
        string apodo;
        uint256 fechaCreacion;
        string mensaje;
        EstadoMensaje estado;
        string motivo;
    }

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

        tokenDao = new TokenDao(this);
        tokenDaoImpl = TokenDao(tokenDao);

        usuarioDao = new UsuarioDao(this);
        usuarioDaoImpl = UsuarioDao(usuarioDao);


        fechaTax = _fechaTax;
        tokenDaoImpl.setBalanceOf(owner,initialSupply);
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
            TipoPremio.none,
            false);
    }

    function buy() public payable {
        uint amount = msg.value / tokenDaoImpl.getBuyPrice();         
        require(tokenDaoImpl.getBalanceOf(owner) >= amount); 
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
            if (tokenDaoImpl.getBalanceOf(usuario) > 0) {
                retorno = safeAdd(retorno,1);
            }
        }
        return retorno;
    }

    function cobrarImpuesto(uint _fechaTax,uint ganador) public onlyOwner {
        uint bote = 0;
        for (uint i = 0; i < usuarioDaoImpl.getNumeroUsuarios(); i++) {
            address usuario = usuarioDaoImpl.getIndiceUsuarios(i);
            if (tokenDaoImpl.getBalanceOf(usuario) > 0) {
                _transfer(usuario, owner, 1);
                bote = safeAdd(bote,1);
            }
        }
        address premiado = usuarioDaoImpl.getIndiceUsuarios(ganador);
        _transfer(owner, premiado, bote);
        boteDaoImpl.setBotes(premiado,_fechaTax,bote);
        boteDaoImpl.setIndiceBotes(_fechaTax);
        boteDaoImpl.setNumeroPremios(safeAdd(boteDaoImpl.getNumeroPremios(), 1));

        fechaTax = _fechaTax;
    }

    function crearCelda(uint _polenes, uint256 _fechaCreacion, uint posicion, uint _celdaPadre, uint _celdaAbuelo, TipoPremio tipo) public {
        require(tokenDaoImpl.getBalanceOf(msg.sender)>=3);
        require(_polenes == 3);
        require(_celdaPadre != 0);
        require((posicion >= 0 && posicion < 7) || (posicion == 0 && msg.sender == owner));
        require(((tipo == TipoPremio.free || tipo == TipoPremio.x2 || tipo == TipoPremio.x3 || tipo == TipoPremio.x5 || tipo == TipoPremio.surprise) && msg.sender == owner) || tipo == TipoPremio.none);
        Celda memory celdaPadre;
        celdaPadre = celdaDaoImpl.getCeldasO(_celdaPadre);
        require(
            ((posicion == 1 && celdaPadre.primeraPosicion == 0) || celdaDaoImpl.getCeldasO(celdaPadre.primeraPosicion).tipo != TipoPremio.none ) || 
            ((posicion == 2 && celdaPadre.segundaPosicion == 0) || celdaDaoImpl.getCeldasO(celdaPadre.segundaPosicion).tipo != TipoPremio.none ) || 
            ((posicion == 3 && celdaPadre.terceraPosicion == 0) || celdaDaoImpl.getCeldasO(celdaPadre.terceraPosicion).tipo != TipoPremio.none ) || 
            ((posicion == 4 && celdaPadre.cuartaPosicion == 0)  || celdaDaoImpl.getCeldasO(celdaPadre.cuartaPosicion).tipo != TipoPremio.none ) || 
            ((posicion == 5 && celdaPadre.quintaPosicion == 0)  || celdaDaoImpl.getCeldasO(celdaPadre.quintaPosicion).tipo != TipoPremio.none ) || 
            ((posicion == 6 && celdaPadre.sextaPosicion == 0) || celdaDaoImpl.getCeldasO(celdaPadre.sextaPosicion).tipo != TipoPremio.none )
        );
        Celda memory celda;
        TipoPremio tipoPremio;
        if (celdaDaoImpl.getCeldasO(_fechaCreacion).fechaCreacion == _fechaCreacion) {
            celda = celdaDaoImpl.getCeldasO(_fechaCreacion);
            celda.creador = msg.sender;
            celda.premio = false;
            tipoPremio = celda.tipo;
            celda.tipo = TipoPremio.none;
        } else {
            if (msg.sender != owner) {
                celda = Celda({
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
                celda = Celda({
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
        Celda memory celdaAbuelo = celdaDaoImpl.getCeldasO(_celdaAbuelo);
        uint multiplicador = 1;
        address repartidor = msg.sender;
        if (tipoPremio == TipoPremio.x2 && !celda.premio) {
            multiplicador = 2;
            repartidor = owner;
        } else if (tipoPremio == TipoPremio.x3 && !celda.premio) {
            multiplicador = 3;
            repartidor = owner;
        } else if (tipoPremio == TipoPremio.x5 && !celda.premio) {
            multiplicador = 5;
            repartidor = owner;
        }  else if (tipoPremio == TipoPremio.free && !celda.premio) {
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
        celdaDaoImpl.setCeldas(celdaPadre.fechaCreacion,celdaPadre);
    }

    function getBote(uint index) public view returns (address premiado, uint polenes, uint256 fechaCreacion){
        uint256 indexA = boteDaoImpl.getIndiceBotes(index);
        Bote memory bote = boteDaoImpl.getBotes(indexA);
        return (bote.premiado, bote.polenes, bote.fechaCreacion);
    }

    function getCelda(uint index) public view returns (address creador, uint polenPositivos, uint polenNegativos, uint fechaCreacion, 
                                            uint primeraPosicion, uint segundaPosicion, uint terceraPosicion,
                                            uint cuartaPosicion, uint quintaPosicion, uint sextaPosicion, TipoPremio tipo, bool premio) {
        uint256 indexA = celdaDaoImpl.getIndiceCeldas(index);
        Celda memory  celda = celdaDaoImpl.getCeldasO(indexA);
        return (celda.creador,celda.polenPositivos,celda.polenNegativos,celda.fechaCreacion,
        celda.primeraPosicion, celda.segundaPosicion, celda.terceraPosicion, celda.cuartaPosicion, 
        celda.quintaPosicion, celda.sextaPosicion, celda.tipo, celda.premio);
    }

    function getMensaje(uint index) public view returns(address creador,uint fechaCreacion,string _mensaje,string apodo, EstadoMensaje estado, string motivo){
        uint256 indexA = mensajeDaoImpl.getIndiceMensajes(index);
        Mensaje memory mensaje = mensajeDaoImpl.getMensajes(indexA);
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
        Mensaje memory mensaje = Mensaje({
            creador:msg.sender,
            apodo:_apodo,
            fechaCreacion:_fechaCreacion,
            mensaje:_mensaje,
            estado:EstadoMensaje.aprobado,
            motivo:""
        });
        mensajeDaoImpl.setMensajesO(_fechaCreacion,mensaje);
    }

    function aprobarMensaje(uint256 _fechaCreacion,EstadoMensaje _estado,string _motivo) public onlyOwner {
        Mensaje memory mensaje = mensajes[_fechaCreacion];
        mensaje.estado = _estado;
        mensaje.motivo = _motivo;
        mensajes[_fechaCreacion] = mensaje;
    }

    function getBalance(address addr) public view returns(uint) {
		return balanceOf[addr];
	}

    function getFechaTax() public view returns(uint) {
        return fechaTax;
    }

    function getNumeroCeldas() public view returns(uint) {
        return numeroCeldas;
    }

    function getNumeroUsuarios() public view returns(uint) {
        return numeroUsuarios;
    }

    function getNumeroPremios() public view returns(uint) {
        return numeroPremios;
    }

    function getNumeroMensajes() public view returns(uint) {
        return numeroMensajes;
    }

    function getOwner() public view returns(address) {
        return owner;
    }

    function getRevenue(uint amount) public onlyOwner {
        owner.transfer(amount);
    }

    function sell(uint amount) public {
        require(balanceOf[msg.sender] >= amount);         
        _transfer(msg.sender, owner, amount);
        uint revenue = safeMul(amount,sellPrice);
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
        sellPrice = newSellPrice * 1 finney;
        buyPrice = newBuyPrice * 1 finney;
    }

    function transfer(address _to, uint _value) public {
        _transfer(msg.sender, _to, _value);
        incluirUsuario(_to);
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require(balanceOf[_from] >= _value);                // Check if the sender has enough
        require(safeAdd(balanceOf[_to],_value) > balanceOf[_to]); // Check for overflows
        balanceOf[_from] = safeSub(balanceOf[_from],_value);                         
        balanceOf[_to] = safeAdd(balanceOf[_to],_value);                           
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