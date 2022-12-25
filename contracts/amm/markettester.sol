// SPDX-License-Identifier: GPL-3.0-or-later
/*
 * AMM contracts
 *
 * Copyright (C) 2022 Serhii Horielyshev, GOSH pubkey 0xd060e0375b470815ea99d6bb2890a2a726c5b0579b83c742f5bb70e10a771a04
 */
pragma ever-solidity >=0.64.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "./modifiers/modifiers.sol";

contract MarketMaker  is Modifiers {
    string constant version = "0.0.1";
    TvmCell m_PriceSaltCode;
    TvmCell m_PriceCode;
    TvmCell m_PriceSaltCodeAddr;
    
    Order[] _price;
    Order[] _priceCan;
    uint128[] _val;
    uint256 _user_id;
    uint128 _pairdecimals = 1e4;
    uint256 x = 0;
    uint128 y1 = 0;
    
    uint128 _time = 10;
    uint128 _ready = 0;
    uint128 _count = 0;
    
    Wallet[] _FlexWallet;
    
    constructor() public onlyOwner accept {
    }
    
    function getLendSellAmount(uint128 index, uint128 value, uint128 price) private view returns(uint128) {
        uint128 res = value;
        if (index == 1) { res = res * price / _pairdecimals + 1; }
        return res * 10015 / 10000 + 1;
    }
    
    function preparePriceXchg(uint128 price_num) private view returns(address) {
    	TvmCell stateInit = tvm.buildStateInit(m_PriceSaltCodeAddr, preparePriceXchgData(price_num));
        return address(tvm.hash(stateInit));
    }
    
    function preparePriceXchgData(uint128 price_num) private pure returns(TvmCell) {
    	mapping(uint => uint) test;
        DPriceXchgCustom price_data = DPriceXchgCustom(price_num, 0, 0, 0, test, 0, test);
        TvmBuilder b;
        b.store(false);
        b.store(price_data);
        return b.toCell();
    }
    
    function setWallet (address wallet, uint8 decimals) public  onlyOwner accept {
        Wallet FlexWallet;
    	FlexWallet.wallet = wallet;
    	FlexWallet.balance = 0;
    	FlexWallet.decimals = decimals;
    	_FlexWallet.push(FlexWallet);
    	
    } 
    
    function clearWallet () public  onlyOwner accept {
    	delete _FlexWallet;
    }
    
    function bindWallets(
    	bool set_binding,
    	optional(BindInfo) binding,
    	bool set_trader,
    	optional(uint256) trader
    )  public view onlyOwner accept {
        AFlexWallet(_FlexWallet[0].wallet).bind{value: 1 ton, flag: 1}(set_binding, binding, set_trader, trader);
        AFlexWallet(_FlexWallet[1].wallet).bind{value: 1 ton, flag: 1}(set_binding, binding, set_trader, trader);
    }
    
    function makeOrders() public onlyOwner accept {
        _makeOrdersIn();
    }
    
    function makeOrdersout() public senderIs(address(this)) accept {
        _makeOrdersIn();
    }
    
    function _makeOrdersIn() private {
        this.makeOrdersout{value: 0.1 ton}();
        y1 = y1 + 1;
        y1 = y1 % 500;
        if (y1 != 0) { return; }
        for (uint128 i = 0; i < _priceCan.length; i++) {
            _cancelOrder(_priceCan[i], false);
        }
        rnd.setSeed(x);
        x += 1;
        uint128 nowPrice = 9000 + rnd.next(2000);
        uint128 nowOrder = rnd.next(10) * 1e6;
        _deployOrder(Order(0, nowPrice), nowOrder);
        _price.push(Order(0, nowPrice));
        _val.push(nowOrder);
        if (_price.length > 5) {
            uint128 y = rnd.next(5);
            Order sw = _price[_price.length - 1];
            _price[_price.length - 1] = _price[y];
            _price[y] = sw;
            _deployOrder(Order(1, _price[_price.length - 1].price), _val[_price.length - 1] * 2);
            _priceCan.push(Order(1, _price[_price.length - 1].price));
            _price.pop();
            _val.pop();
        }
    }
    
    function removeOrders() public onlyOwner accept {
        _removeOrdersIn();
    }
    
    function _removeOrdersIn() private  {
        for (int128 i = 0; i <= int128(_price.length) - 1; i++){
            if (i <= int128(_price.length) / 2 - 1) {  _cancelOrder(_price[uint128(i)], true); }
            else { _cancelOrder(_price[uint128(i)], false); }
        }
        delete _price;
    }
    
     
    function deployOrder(Order price_num, uint128 amount) public view onlyOwner accept {
        _deployOrder(price_num, amount);
    } 
    
    function _deployOrder(
    	Order price_num,
    	uint128 amount) private view {
    	uint32 m_dealTime =  uint32(1);
        m_dealTime =uint32(now + m_dealTime * _time * 60);
    	FlexLendPayloadArgs args = FlexLendPayloadArgs (true, true, true, amount, address(this), _user_id, uint256(0));
    	if (price_num.index == 1) { args = FlexLendPayloadArgs (false, true, true, amount, address(this), _user_id, uint256(0)); }
    	AFlexWallet(_FlexWallet[price_num.index].wallet).makeOrder{value: 4 ton, flag: 1}(uint32(0), address(this), 3 ton, getLendSellAmount(price_num.index, amount, price_num.price), m_dealTime, price_num.price, m_PriceCode, m_PriceSaltCode, args);   
    } 
    
    function cancelOrder( 
    	Order      price,
    	bool isSell
    ) public view onlyOwner accept {
        _cancelOrder(price, isSell);
    } 
    
    function _cancelOrder(  
    	Order price,
    	bool isSell
    ) private view {
    	optional(uint256) order_id;
        AFlexWallet(_FlexWallet[price.index].wallet).cancelOrder{value: 3 ton, flag: 1}(2 ton, preparePriceXchg(price.price), isSell, order_id);   
    }

    
    function sendMoney(uint128 count, address a1) public view onlyOwner minBalance(count) {
        a1.transfer(count, false, 3);
    }

    /* Setters */   
    function setPriceCode(TvmCell code) public onlyOwner accept {
        m_PriceCode = code;
    }
     
    function setPriceSaltCode(TvmCell code) public onlyOwner accept {
        m_PriceSaltCode = code;
    }
    
    function setPriceCodeAddr(TvmCell code) public onlyOwner accept {
        m_PriceSaltCodeAddr = code;
    }
    
    function setUserId(uint256 id) public onlyOwner accept {
        _user_id = id;
    }
    
    function setPairDecimals(uint128 dec) public onlyOwner accept {
        _pairdecimals = dec;
    }
    
    function setReady(uint128 ready) public onlyOwner accept {
        _ready = ready;
    }
    
    function setTime(uint128 time) public onlyOwner accept {
        _time = time;
    }
    
    function updateCode(TvmCell newcode, TvmCell cell) public onlyOwner accept {
        tvm.setcode(newcode);
        tvm.setCurrentCode(newcode);
        onCodeUpgrade(cell);
    }

    function onCodeUpgrade(TvmCell cell) private {
        cell;
        tvm.resetStorage();   
    }
    
    function getWallets() public view returns(Wallet[]) {
        return _FlexWallet;
    }

    /* fallback/receive */
    receive() external pure {
        tvm.accept();
    }
    
    onBounce(TvmSlice body) external pure {
        body;
        tvm.accept();
    }

    fallback() external pure {
        tvm.accept();
    }
    
    /* Getters */   
}

