pragma ton-solidity >=0.53.0;

abstract contract ABroxusTokenWallet {
    function balance(uint32 answerId) public returns(uint128 value0) {}
    function transferToWallet(uint128 amount, address recipientTokenWallet, address remainingGasTo, bool notify, TvmCell payload) public {}
}