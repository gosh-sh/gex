// SPDX-License-Identifier: GPL-3.0-or-later
/*
 * GOSH contracts
 *
 * Copyright (C) 2022 Serhii Horielyshev, GOSH pubkey 0xd060e0375b470815ea99d6bb2890a2a726c5b0579b83c742f5bb70e10a771a04
 */
pragma ton-solidity >=0.61.2;

abstract contract Errors {
    string constant versionErrors = "0.0.1";
    
    uint constant ERR_NOT_OWNER = 200;
    uint constant ERR_LOW_VALUE = 201;
    uint constant ERR_INVALID_SENDER = 202;
    uint constant ERR_LOW_BALANCE = 203;
}
