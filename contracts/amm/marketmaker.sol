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

struct Wallet {
    address wallet;
    uint128 balance;
    uint8 decimals;
}

struct Order {
    address wallet;
    uint128 price;
}

contract MarketMaker  is Modifiers {
    string constant version = "0.0.1";
    Wallet _FlexWallet1;
    Wallet _FlexWallet2;
    TvmCell m_PriceCode;
    
    uint128 _numberOrders = 3;
    uint128 _stepPrice;
    uint128[] fibNumber;
    uint128[] sumFib;
    Order[] _price;
    
    constructor() public onlyOwner accept {
        init();
    }
    
    function init() private {
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
        return (_FlexWallet1.balance * _FlexWallet1.decimals) / _FlexWallet2.balance;
    }
         
    function setFirstWallet (address wallet, uint128 balance, uint8 decimals) public  onlyOwner accept {
    	_FlexWallet1.wallet = wallet;
    	_FlexWallet1.balance = balance;
    	_FlexWallet1.decimals = decimals;
    } 
    
    function setSecondWallet (address wallet, uint128 balance, uint8 decimals) public  onlyOwner accept {
    	_FlexWallet2.wallet = wallet;
    	_FlexWallet2.balance = balance;
    	_FlexWallet2.decimals = decimals;
    } 
    
    function getPriceSalt() private view returns(TvmCell) {
        return m_PriceCode;
    }
    
    function makeOrders() public onlyOwner accept {
        for (uint128 i = _numberOrders; i >= 1; i--){
            uint128 nowPrice = _innerPrice() + _stepPrice * i;
            uint128 nowOrder = fibNumber[i - 1] * _FlexWallet1.balance / 10;
            nowOrder /= sumFib[_numberOrders - 1];
            _deployOrder(Order(_FlexWallet1.wallet, nowPrice), nowOrder);
            _price.push(Order(_FlexWallet1.wallet, nowPrice));
        }
        for (uint128 i = _numberOrders; i >= 1; i--){
            int128 nowPrice_t = int128(_innerPrice()) - int128(_stepPrice) * int128(i);
            if (nowPrice_t < 0){
                continue;
            }
            uint128 nowPrice = uint128(nowPrice_t);
            uint128 nowOrder = fibNumber[i - 1] * _FlexWallet2.balance / 10;
            nowOrder /= sumFib[_numberOrders - 1];
            _deployOrder(Order(_FlexWallet2.wallet, nowPrice), nowOrder);
            _price.push(Order(_FlexWallet2.wallet, nowPrice));
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
        m_dealTime =uint32(now + m_dealTime * 60 * 60);
    	FlexLendPayloadArgs args = FlexLendPayloadArgs (true, false, false, amount, address(this), uint256(0), uint256(0));
    	uint128 lend_amount = price_num.price * amount;
    	AFlexWallet(price_num.wallet).makeOrder(uint32(0), address(this), uint128(0), lend_amount, m_dealTime, price_num.price, m_PriceCode, getPriceSalt(), args);   
    } 
    
    function cancelOrder( 
    	Order      price
    ) public view onlyOwner accept {
        _cancelOrder(price);
    } 
    
    function _cancelOrder(  
    	Order price
    ) private pure {
    	optional(uint256) order_id;
        AFlexWallet(price.wallet).cancelOrder(5 ton, price.wallet/*TRWETWEGVWEVEV*/, true, order_id);   
    }

    
    function sendMoney(uint128 count, address a1) public view onlyOwner minBalance(count) {
        a1.transfer(count, false, 3);
    }

    /* Setters */
    
    function setPriceCode(TvmCell code) public onlyOwner accept {
        m_PriceCode = code;
    }
    
    function setConfig(uint128 step, uint128 number) public onlyOwner accept {
        _numberOrders = number;
        _stepPrice = step;
    }
    
    function onCodeUpgrade() private {
        
    }

    /* fallback/receive */
    receive() external {
    }
    
    /* Getters */   
}

