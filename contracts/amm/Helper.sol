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
    function getData(
        uint32 _answer_id,
        uint256 pubkey,
        optional(address) owner,
        uint128 evers) public pure returns(TvmCell) {
        TvmCell payload = tvm.encodeBody(AWrapper.deployEmptyWallet, _answer_id, pubkey, owner, evers);
        return payload;
    }
    
    function getDeposit(uint128 m_amount, address wrapperWallet, address m_userMsig, TvmCell value0) public pure returns(TvmCell) {
        return tvm.encodeBody(ABroxusTokenWallet.transferToWallet,
                                            m_amount,
                                            wrapperWallet,
                                            m_userMsig,
                                            true,
                                            value0);
    }
    
    function getCorrectData(TvmCell a) public pure returns(TvmCell){
        TvmSlice data = a.toSlice();
        (uint16 _w1, uint8 _w2) = data.size();
        bool _s1 = data.decode(bool);
        uint128 _s2 = data.decode(uint128);
        _w1; _w2; _s1; _s2;
        TvmBuilder p;
        p.store(data);
        return p.toCell();
    }
    
    function getCorrectDataFull(TvmCell a, uint128 price) public pure returns(TvmCell){
        TvmSlice data = a.toSlice();
        (uint16 _w1, uint8 _w2) = data.size();
        bool _s1 = data.decode(bool);
        uint128 _s2 = data.decode(uint128);
        _w1; _w2; _s1; _s2;
        TvmBuilder b;
        b.store(false, price, data);
        return b.toCell();
    }
    
    receive() external {
    }
    
    function onCodeUpgrade() private {
    }
}

