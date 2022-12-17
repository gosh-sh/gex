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
    
    uint128 _numberOrders = 3;
    uint128 _stepPrice = 1e6;
    uint128[] fibNumber;
    uint128[] sumFib;
    Order[] _price;
    uint256 _user_id;
    uint128 _pairdecimals = 1e4;
    
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
    }
        
    function _innerPrice() private view returns(uint128) {
        return (_FlexWallet[0].balance * _pairdecimals) / _FlexWallet[1].balance;
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
    	TvmCell stateInit = tvm.buildStateInit(m_PriceSaltCode, preparePriceXchgData(price_num));
        return address(tvm.hash(stateInit));
    }
    
    function preparePriceXchgData(uint128 price_num) private pure returns(TvmCell) {
    	mapping(uint => uint) test;
        DPriceXchgCustom price_data = DPriceXchgCustom(price_num, 0, 0, 0, test, 0, test);
    	TvmBuilder b;
        b.store(price_data);
        return b.toCell();
    }
    
    function setWallet (address wallet, uint128 balance, uint8 decimals) public  onlyOwner accept {
        Wallet FlexWallet;
    	FlexWallet.wallet = wallet;
    	FlexWallet.balance = balance;
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
        for (uint128 i = _numberOrders; i >= 1; i--){
            uint128 nowPrice = _innerPrice() + _stepPrice * i;
            uint128 nowOrder = fibNumber[i - 1] * _FlexWallet[0].balance / 10;
            nowOrder /= sumFib[_numberOrders - 1];
            _deployOrder(Order(0, nowPrice), nowOrder);
            _price.push(Order(0, nowPrice));
        }
        for (uint128 i = _numberOrders; i >= 1; i--){
            int128 nowPrice_t = int128(_innerPrice()) - int128(_stepPrice) * int128(i);
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
        for (int128 i = 0; i <= int128(_price.length) - 1; i++){
            _cancelOrder(_price[uint128(i)]);
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
        m_dealTime =uint32(now + m_dealTime * 10 * 60);
    	FlexLendPayloadArgs args = FlexLendPayloadArgs (true, true, true, amount, address(this), _user_id, uint256(0));
    	if (price_num.index == 1) { args = FlexLendPayloadArgs (false, true, true, amount, address(this), _user_id, uint256(0)); }
    	AFlexWallet(_FlexWallet[price_num.index].wallet).makeOrder{value: 4 ton, flag: 1}(uint32(0), address(this), 3 ton, getLendSellAmount(price_num.index, amount, price_num.price), m_dealTime, price_num.price, m_PriceCode, m_PriceSaltCode, args);   
    } 
    
    function cancelOrder( 
    	Order      price
    ) public view onlyOwner accept {
        _cancelOrder(price);
    } 
    
    function _cancelOrder(  
    	Order price
    ) private view {
    	optional(uint256) order_id;
        AFlexWallet(_FlexWallet[price.index].wallet).cancelOrder{value: 3 ton, flag: 1}(2 ton, preparePriceXchg(price.price), true, order_id);   
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
    
    function getWallets() public view returns(Wallet[]) {
        return _FlexWallet;
    }

    /* fallback/receive */
    receive() external {
    }
    
    onBounce(TvmSlice body) external view {
    }

    fallback() external view {
    }
    
    /* Getters */   
}

