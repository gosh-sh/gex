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
import "marketmaker.sol";

contract StockNotify is Modifiers {
    string constant version = "0.0.1";
    optional(address) m_amm;
    TvmCell m_PriceSaltCodeAddr;

    constructor () public {
        require(msg.pubkey() == tvm.pubkey(), 101);
		tvm.accept();
    }

    function upgrade(TvmCell state) public virtual {
        require(msg.pubkey() == tvm.pubkey(), 101);
        TvmCell newcode = state.toSlice().loadRef();
        tvm.accept();
        tvm.commit();
        tvm.setcode(newcode);
        tvm.setCurrentCode(newcode);
        onCodeUpgrade();
    }

    function onCodeUpgrade() internal {
        tvm.resetStorage();
    }

    function checkAndTransfer() internal view inline  {
        if (address(this).balance > 101 ever)
            m_amm.get().transfer(100 ever);
    }

    function onXchgDealCompleted(
        bool       seller_is_taker, ///< Seller is a taker in deal
        address    pair,            ///< Address of XchgPair contract
        address    tip3root_major,  ///< Address of RootTokenContract for the major tip3 token
        address    tip3root_minor,  ///< Address of RootTokenContract for the minor tip3 token
        Tip3Cfg major_tip3cfg,   ///< Major tip3 configuration
        Tip3Cfg minor_tip3cfg,   ///< Minor tip3 configuration
        uint128    price_num,       ///< Token price numerator
        uint128    price_denum,     ///< Token price denominator
        uint128    amount           ///< Amount of major tip3 tokens in the deal
    ) public view functionID(10) senderIs(preparePriceXchg(price_num)) accept {
        seller_is_taker; pair; tip3root_major; tip3root_minor; major_tip3cfg; minor_tip3cfg; price_denum;
        MarketMaker(m_amm.get()).notifyDeal{value: 0.03 ever}(price_num, amount, now);
    }

    function onXchgOrderAdded(
      bool    sell,           ///< Is it a sell order
      address tip3root_major, ///< Address of RootTokenContract for the major tip3 token
      address tip3root_minor, ///< Address of RootTokenContract for the minor tip3 token
      uint128 price_num,      ///< Token price numerator
      uint128 price_denum,    ///< Token price denominator
      uint128 amount,         ///< Amount of major tip3 tokens added in the order
      uint128 sum_amount      ///< Summarized amount of major tokens rest in all orders for this price (sell or buy only)
    ) public view functionID(11) senderIs(preparePriceXchg(price_num)) accept {
        sell; tip3root_major; tip3root_minor; price_denum; amount; sum_amount;
        checkAndTransfer();
    }

    function onXchgOrderCanceled(
      bool    sell,           ///< Is it a sell order
      address tip3root_major, ///< Address of RootTokenContract for the major tip3 token
      address tip3root_minor, ///< Address of RootTokenContract for the minor tip3 token
      uint128 price_num,      ///< Token price numerator
      uint128 price_denum,    ///< Token price denominator
      uint128 amount,         ///< Amount of major tip3 tokens canceled
      uint128 sum_amount      ///< Summarized amount of major tokens rest in all orders for this price (sell or buy only)
    ) public view functionID(12) senderIs(preparePriceXchg(price_num)) accept {
        sell; tip3root_major; tip3root_minor; price_denum; amount; sum_amount;
        checkAndTransfer();
    }
    
    function preparePriceXchgData(uint128 price_num) private pure returns(TvmCell) {
    	mapping(uint => uint) test;
        DPriceXchgCustom price_data = DPriceXchgCustom(price_num, 0, 0, 0, test, 0, test);
        TvmBuilder b;
        b.store(false);
        b.store(price_data);
        return b.toCell();
    }
    
    function preparePriceXchg(uint128 price_num) private view returns(address) {
    	TvmCell stateInit = tvm.buildStateInit(m_PriceSaltCodeAddr, preparePriceXchgData(price_num));
        return address(tvm.hash(stateInit));
    }
    
    function setAmm(address amm) public onlyOwner accept {
        m_amm = amm;
    }
    
    function setPriceCodeAddr(TvmCell code) public onlyOwner accept {
        m_PriceSaltCodeAddr = code;
    }
}

