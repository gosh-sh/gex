// SPDX-License-Identifier: GPL-3.0-or-later
/*
 * AMM contracts
 *
 * Copyright (C) 2022 Serhii Horielyshev, GOSH pubkey 0xd060e0375b470815ea99d6bb2890a2a726c5b0579b83c742f5bb70e10a771a04
 */
pragma ever-solidity >=0.64.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
pragma AbiHeader time;
import "./modifiers/modifiers.sol";

contract StockNotify is Modifiers {
    string constant version = "0.0.1";

    constructor() public accept {
    }

    /* fallback/receive */
    receive() external {
    }
    
    function onCodeUpgrade() private {
    }
}

