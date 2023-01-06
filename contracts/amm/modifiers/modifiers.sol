// SPDX-License-Identifier: GPL-3.0-or-later
/*
 * GOSH contracts
 *
 * Copyright (C) 2022 Serhii Horielyshev, GOSH pubkey 0xd060e0375b470815ea99d6bb2890a2a726c5b0579b83c742f5bb70e10a771a04
 */
pragma ton-solidity >=0.64.0;

import "errors.sol";
import "../../abstract/AFlexClient.sol";
import "../../abstract/AFlexWallet.sol";
import "../../abstract/AWrapper.sol";
import "../../abstract/ABroxusTokenWallet.sol";

//Structs
struct Wallet {
    address wallet;
    uint128 balance;
    uint8 decimals;
}

struct Order {
    uint128 index;
    uint128 price;
}

struct Deal {
    uint128 amount;
    uint128 price;
}

struct DPriceXchgCustom {
    uint128 price_num_;    
    uint128 sells_amount_; 
    uint128 buys_amount_; 
    uint32 len0;
    mapping(uint => uint) map0;
    uint32 len1;
    mapping(uint => uint) map1;
}

abstract contract Modifiers is Errors {    
    string constant versionModifiers = "0.0.1";
    
    //Deploy constants

    
    modifier onlyOwner {
        require(msg.pubkey() == tvm.pubkey(), ERR_NOT_OWNER);
        _;
    }

    modifier accept() {
        tvm.accept();
        _;
    }
    
    modifier minValue(uint128 val) {
        require(msg.value >= val, ERR_LOW_VALUE);
        _;
    }
    
    modifier senderIs(address sender) {
        require(msg.sender == sender, ERR_INVALID_SENDER);
        _;
    }
    
    modifier minBalance(uint128 val) {
        require(address(this).balance > val + 1 ton, ERR_LOW_BALANCE);
        _;
    }
}
