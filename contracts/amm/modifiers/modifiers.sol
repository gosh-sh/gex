// SPDX-License-Identifier: GPL-3.0-or-later
/*
 * GOSH contracts
 *
 * Copyright (C) 2022 Serhii Horielyshev, GOSH pubkey 0xd060e0375b470815ea99d6bb2890a2a726c5b0579b83c742f5bb70e10a771a04
 */
pragma ton-solidity >=0.64.0;

import "errors.sol";

abstract contract AFlexWallet {
    function cancelOrder(
        uint128 evers,
        address price,
        bool sell,
        optional(uint256) order_id
    ) public functionID(0x11) {}

    function makeOrder(
        uint32 _answer_id,
        optional(address) answer_addr,
        uint128 evers,
        uint128 lend_balance,
        uint32 lend_finish_time,
        uint128 price_num,
        TvmCell unsalted_price_code,
        TvmCell salt,
        FlexLendPayloadArgs args
    ) public functionID(0x10) {}
}

//Structs
struct FlexLendPayloadArgs {
    bool sell;               ///< Sell order if true, buy order if false.
    bool immediate_client;   ///< Should this order try to be executed as a client order first
                                ///<  (find existing corresponding orders).
    bool  post_order;         ///< Should this order be enqueued if it doesn't already have corresponding orders.
    uint128  amount;             ///< Amount of major tokens to buy or sell.
    address  client_addr;        ///< Client contract address. PriceXchg will execute cancels from this address,
                                ///<  send notifications and return the remaining native funds (evers) to this address.
    uint256  user_id;            ///< User id. It is trader wallet's pubkey. Receiving wallet credentials will be { pubkey: user_id, owner: client_addr }.
    uint256  order_id;           ///< Order id for client purposes.
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
