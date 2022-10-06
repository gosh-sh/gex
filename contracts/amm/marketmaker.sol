// SPDX-License-Identifier: GPL-3.0-or-later
/*
 * AMM contracts
 *
 * Copyright (C) 2022 Serhii Horielyshev, GOSH pubkey 0xd060e0375b470815ea99d6bb2890a2a726c5b0579b83c742f5bb70e10a771a04
 */
pragma ton-solidity >=0.64.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Upgradable.sol";
import "./modifiers/modifiers.sol";

contract MarketMaker  is Modifiers, Upgradable{
    string constant version = "0.0.1";
    
    constructor() public accept {
    }

    function addTip3Wallet () public onlyOwner {
    }

    function deployClient() public onlyOwner {      
    }

    function updateConfig() public onlyOwner {
    }

    function init() public onlyOwner {
    }

    function removeOrders() public onlyOwner {
    }

    function setOrders() public onlyOwner {
    }

    function _setOrder() private senderIs(address(this)) {
    }
    
    function _updateOrders() private senderIs(address(this)) {
    }
    function sendMoney(uint128 count, address a1) public view onlyOwner minBalance(count) {
        a1.transfer(count, false, 3);
    }

    /* Setters */
    
    function onCodeUpgrade() internal override {
        
    }

    /* fallback/receive */
    receive() external {
    }
    
    /* Getters */   
}

