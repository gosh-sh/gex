pragma ton-solidity >=0.47.0;

struct PriceTuple {
    uint128 num;
    uint128 denum;
}

abstract contract AFlex {
    function getDetails() public functionID(0x15) returns(
        TvmCell xchg_pair_code,
        uint256 unsalted_price_code_hash,
        optional(address) first_pair,
        optional(address) last_pair,
        uint32 pairs_count
    ) {}
    function calcLendTokensForOrder(bool sell, uint128 major_tokens, PriceTuple price) public functionID(0x17) returns(uint128 value0) {}

}