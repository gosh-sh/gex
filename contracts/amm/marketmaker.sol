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
    TvmCell m_WalletCode;
    address _FlexWallet1;
    address _FlexWallet2;
    
    constructor() public accept {
    }

    function deployFirstWallet() public onlyOwner accept {
    
    }
    
    function deploySecondWallet() public onlyOwner accept {
    
    }
    
    function deployOrder() public onlyOwner accept {
//        _deployOrder();
    } 
    
    function _deployOrder(
    	bool    sell,
    	bool    immediate_client,
    	bool    post_order,
    	uint128 price_num,
    	uint128 amount,
    	uint128 lend_amount,
    	uint32  lend_finish_time,
    	uint128 evers,
    	TvmCell    unsalted_price_code,
    	TvmCell    price_salt,
    	address my_tip3_addr,
    	uint256 user_id,
    	uint256 order_id) private {
    	FlexLendPayloadArgs args = FlexLendPayloadArgs (sell, immediate_client, post_order, amount, address(this), user_id, order_id);
    	AFlexWallet(my_tip3_addr).makeOrder(uint32(0), address(this), uint128(0), lend_amount, lend_finish_time, price_num, unsalted_price_code, price_salt, args);   
    } 
    
    function cancelOrder() public onlyOwner accept {
//        _cancelOrder();
    } 
    
    function _cancelOrder(    
    	uint128      evers,
    	address      price,
    	bool         sell,
    	optional(uint256) order_id,
    	address my_tip3_addr
    ) private {
        AFlexWallet(my_tip3_addr).cancelOrder(evers, price, sell, order_id);   
    }

    
    function sendMoney(uint128 count, address a1) public view onlyOwner minBalance(count) {
        a1.transfer(count, false, 3);
    }

    /* Setters */
    
    function onCodeUpgrade() private {
        
    }
    
    function setWalletCode(TvmCell code)  public onlyOwner accept {
    	m_WalletCode = code;
    }

    /* fallback/receive */
    receive() external {
    }
    
    /* Getters */   
}

