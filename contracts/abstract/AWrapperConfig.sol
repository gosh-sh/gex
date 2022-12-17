pragma ton-solidity >=0.47.0;

abstract contract AWrapperConfig {
    function getDetails() public returns (
        uint32 token_version,
        address[] wrapper_deployers,
        optional(address) first_wic,
        optional(address) last_wic,
        uint32 wic_count,
        uint256 salted_wic_hash
    ) {}

    function getConfig () public returns (
        address super_root,
        TvmCell wic_code
    ) {}
}
