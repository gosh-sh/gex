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
    
    Deal[1000] _deals;
    uint128 _point = 0;
    uint128 _volume = 0;
    uint128 _volumeold;
    uint128[10] _volume10;
    uint128[100] _volume100;
    
    Order[] _price;
    uint256 _user_id;
    uint128 _pairdecimals = 1e4;
    
    uint128 _time = 6e4;
    
    uint128 _ready = 0;
    uint128 _oldprice = 0;
    
    uint128 _count = 0;
    uint128 _zone = 1e3;
    uint128 _div = 100;
    
    address _notify;
    
    Wallet[] _FlexWallet;
    
    constructor() public onlyOwner accept {
    }
    
    function notifyDeal(uint128 price, uint128 amount, uint128 time) public senderIs(_notify) accept {
        time;
        _volumeold = _volume;
        _volume -= _deals[_point].amount;
        _volume10[_deals[_point].price / _pairdecimals] -= _deals[_point].amount;
        _volume100[_deals[_point].price * 10 / _pairdecimals] -= _deals[_point].amount;
        _volume += amount;
        _volume10[price / _pairdecimals] -= amount;
        _volume100[price * 10 / _pairdecimals] -= amount;    
        _innerPrice();
    }
        
    function _innerPrice() private returns(uint128) {
        uint128 need = _volume / 2;
        uint128 index = 0;
        uint128 bal = 0;
        for (uint128 i = 0; i < 10; i++){
            bal += _volume10[i];
            index = i; 
            if (bal > need) { bal -= _volume10[i]; break; }
        }
        uint128 index1;
        for (uint128 i = index * 10; i < index * 10 + 10; i++){
            bal += _volume100[i];
            index1 = i; 
            if (bal > need) { break; }
        }
        if (index1 != _oldprice) { _oldprice = index1; _removeOrdersIn(); _makeOrdersIn(); }
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
    	FlexWallet.decimals = decimals;
    	_FlexWallet.push(FlexWallet);
    	AFlexWallet(FlexWallet.wallet).details{value: 1 ton}(uint32(100));    	
    } 
    
    function onTip3Transfer(uint32 answer_id, uint128 balance, uint128 newtoken, uint128 ever_balance, Tip3Cfg config, optional(Tip3Creds) sender, Tip3Creds receiver, TvmCell payload, address answer) public accept functionID(0xca) {
        answer_id; newtoken; ever_balance; config; sender; receiver; answer;      
        TvmSlice data = payload.toSlice();
        bool sender_sell = data.decode(bool);
        bool sender_taker = data.decode(bool);
        uint256 sender_user_id = data.decode(uint256);
        uint256 receiver_user_id = data.decode(uint256);
        uint256 receiver_order_id = data.decode(uint256);
        data = data.loadRefAsSlice();
        address another_tip3_root = data.decode(address);
        uint128 price_num = data.decode(uint128);
        sender_sell; sender_taker; sender_user_id; receiver_user_id; receiver_order_id; another_tip3_root;
        require(((_FlexWallet[0].wallet == msg.sender) || (_FlexWallet[1].wallet == msg.sender)),ERR_INVALID_SENDER);
        if (_FlexWallet[0].wallet == msg.sender) { 
        	uint128 change = balance - _FlexWallet[0].balance; 
        	_FlexWallet[0].balance = balance; 
        	_FlexWallet[1].balance -= (change * price_num / _pairdecimals)  * 10000 / 10015;
        }
        if (_FlexWallet[1].wallet == msg.sender) { 
        	uint128 change = balance - _FlexWallet[1].balance; 
        	_FlexWallet[1].balance = balance; 
        	_FlexWallet[0].balance -= (change * _pairdecimals / price_num) * 10000 / 10015;        	
        }
    }
    
    function setBalance(
            string name, string symbol, uint8 decimals, uint128 balance,
            uint256 root_public_key, address root_address, uint256 wallet_pubkey,
            optional(address) owner_address,
            optional(uint256) lend_pubkey,
            lend_owner_array_record[] lend_owners,
            uint128 lend_balance,
            optional(BindInfo) binding,
            uint256 code_hash,
            uint16 code_depth,
            int8 workchain_id) public accept functionID(100) {
        name; symbol; decimals; root_public_key; root_address; wallet_pubkey; owner_address; lend_pubkey; lend_owners; lend_balance; binding; code_hash; code_depth; workchain_id;
        if (_FlexWallet[0].wallet == msg.sender) { _FlexWallet[0].balance = balance; if (_ready == 1) { AFlexWallet(_FlexWallet[1].wallet).details{value: 1 ton}(100); }}
        if (_FlexWallet[1].wallet == msg.sender) { _FlexWallet[1].balance = balance; if (_ready == 1) { AFlexWallet(_FlexWallet[0].wallet).details{value: 1 ton}(100); }}
        if ((_FlexWallet.length == 2) && (_ready == 1)) { refresh(); }
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
    
    function refreshBalance(address wallet) public onlyOwner accept view {
         if (_FlexWallet[0].wallet == wallet) { AFlexWallet(wallet).details{value: 1 ton}(100); return; } 
         if (_FlexWallet[1].wallet == wallet) { AFlexWallet(wallet).details{value: 1 ton}(100); return; } 
    }
    
    function refreshOut() public onlyOwner accept {
        refresh();
    }
    
    function refresh() private {
        uint128 newprice = _innerPrice();
        _count++;
        if ((newprice != _oldprice) || (_count >= 5)) {
            _oldprice = newprice;
            _removeOrdersIn();
            _makeOrdersIn();
            _count = 0;
        }
    }
    
    function makeOrders() public onlyOwner accept {
        _makeOrdersIn();
    }
    
    function _makeOrdersIn() private {
        if (_oldprice == 0) { return; }
        if (_oldprice >= 9) { return; }
        uint128 nowPrice = _oldprice + _zone;
        uint128 nowOrder = _FlexWallet[0].balance / _div + _volume * 15 / 10000;
        _deployOrder(Order(0, nowPrice), nowOrder);
        _price.push(Order(0, nowPrice));
        int128 nowPrice_t = int128(_oldprice) - int128(_zone);
        if (nowPrice_t < 0){
            return;
        }
        nowPrice = uint128(nowPrice_t);
        nowOrder = _FlexWallet[1].balance / _div  + _volume * 15 / 10000;
        nowOrder *= _pairdecimals;
        nowOrder /= nowPrice;
        _deployOrder(Order(1, nowPrice), nowOrder);
        _price.push(Order(1, nowPrice));
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
    
    function setZone(uint128 zone) public onlyOwner accept {
        _zone = zone;
    }
    
    function setDivisor(uint128 div) public onlyOwner accept {
        _div = div;
    }
    
    function setNotify(address notify) public onlyOwner accept {
        _notify = notify;
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
        
    function getPriceAddr(uint128 price) public view returns(address) {
        return preparePriceXchg(price);
    }
    
    function getPriceData(uint128 price) public pure returns(TvmCell) {
        return preparePriceXchgData(price);
    }
    
    function getPriceStateInit(uint128 price) public view returns(TvmCell) {
       return tvm.buildStateInit(m_PriceSaltCodeAddr, preparePriceXchgData(price));
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

