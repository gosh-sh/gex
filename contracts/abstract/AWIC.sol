pragma ton-solidity >=0.47.0;

abstract contract AWIC {
    function getDetails() public functionID(0xe) returns (
        string symbol,
        int8 workchain_id,
        optional(address) deployer,
        optional(address) wrapper,
        optional(uint8) type_,
        optional(TvmCell) init_args,
        optional(address) next,
        bool unlisted
    ) {}
}
