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
    address m_FlexClient;
    TvmCell m_PriceSaltCode;
    TvmCell m_PriceCode;
    TvmCell m_PriceSaltCodeAddr;
    
    uint128 _numberOrders = 3;
    uint128 _stepPrice = 1e6;
    uint128[] fibNumber;
    uint128[] sumFib;
    Order[] _price;
    uint256 _user_id;
    uint128 _pairdecimals = 1e4;
    
    uint128 _time = 10;
    
    uint128 _ready = 0;
    uint128 _oldprice = 0;
    
    uint128 _count = 0;
    
    Wallet[] _FlexWallet;
    
    constructor() public onlyOwner accept {
    }
    
    function init() public onlyOwner accept {
        delete fibNumber;
        delete sumFib;
        uint128 sum = 2;
        fibNumber.push(1);
        fibNumber.push(1);
        sumFib.push(1);
        sumFib.push(2);
        for (uint128 i = 2; i < 20; i++){
            fibNumber.push(fibNumber[i - 1] + fibNumber[i - 2]);
            sum += fibNumber[i];
            sumFib.push(sum);
        }
        _oldprice = _innerPrice();
        _count = 4;
    }
        
    function _innerPrice() private view returns(uint128) {
        return (_FlexWallet[1].balance * _pairdecimals) / _FlexWallet[0].balance;
    }
         
    function setFlexClient (address client) public  onlyOwner accept {
    	m_FlexClient = client;
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
    	AFlexWallet(FlexWallet.wallet).details{value: 1 ton}(uint32(100));
    	
    } 
    
    function onTip3Transfer(uint128 balance, uint128 newtoken, uint128 ever_balance, Tip3Cfg config, optional(Tip3Creds) sender, Tip3Creds receiver, TvmCell payload, address answer) public accept functionID(0xca) {
        newtoken; ever_balance; config; sender; receiver; payload; answer;
        require(((_FlexWallet[0].wallet == msg.sender) || (_FlexWallet[0].wallet == msg.sender)),ERR_INVALID_SENDER);
        if (_FlexWallet[0].wallet == msg.sender) { _FlexWallet[0].balance = balance; }
        if (_FlexWallet[1].wallet == msg.sender) { _FlexWallet[1].balance = balance; }
        if ((_FlexWallet.length == 2) && (_ready == 1)) { refresh(); }
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
        if (_FlexWallet[0].wallet == msg.sender) { _FlexWallet[0].balance = balance; }
        if (_FlexWallet[1].wallet == msg.sender) { _FlexWallet[1].balance = balance; }
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
    
    function refreshBalance(address wallet) private view {
         if (_FlexWallet[0].wallet == wallet) { AFlexWallet(wallet).details{value: 1 ton}(100); } 
         if (_FlexWallet[1].wallet == wallet) { AFlexWallet(wallet).details{value: 1 ton}(100); } 
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
            for (uint128 i = _numberOrders; i >= 1; i--){
            uint128 nowPrice = _oldprice + _stepPrice * i;
            uint128 nowOrder = fibNumber[i - 1] * _FlexWallet[0].balance / 10;
            nowOrder /= sumFib[_numberOrders - 1];
            _deployOrder(Order(0, nowPrice), nowOrder);
            _price.push(Order(0, nowPrice));
        }
        for (uint128 i = _numberOrders; i >= 1; i--){
            int128 nowPrice_t = int128(_oldprice) - int128(_stepPrice) * int128(i);
            if (nowPrice_t < 0){
                continue;
            }
            uint128 nowPrice = uint128(nowPrice_t);
            uint128 nowOrder = fibNumber[i - 1] * _FlexWallet[1].balance / 10;
            nowOrder /= sumFib[_numberOrders - 1];
            nowOrder *= _pairdecimals;
            nowOrder /= nowPrice;
            _deployOrder(Order(1, nowPrice), nowOrder);
            _price.push(Order(1, nowPrice));
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
    
    function setConfig(uint128 step, uint128 number) public onlyOwner accept {
        _numberOrders = number;
        _stepPrice = step;
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
    
    function getInit() public view returns(uint128[], uint128[]) {
        return (fibNumber, sumFib);
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
    receive() external view {
        tvm.accept();
    	refreshBalance(msg.sender);
    }
    
    onBounce(TvmSlice body) external view {
        body;
        tvm.accept();
    	refreshBalance(msg.sender);
    }

    fallback() external view {
        tvm.accept();
    	refreshBalance(msg.sender);
    }
    
    /* Getters */   
}

