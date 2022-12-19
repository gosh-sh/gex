pragma ton-solidity >=0.53.0;

struct WalletArgs {
    uint256 pubkey;
    optional(address) owner;
    uint128 evers;
    uint128 keep_evers;
}

abstract contract AWrapperEver {
    function getDetails() public functionID(0x100) returns(
        bytes name,
        bytes symbol,
        uint8 decimals,
        uint256 root_pubkey,
        uint128 total_granted,
        TvmCell wallet_code,
        optional(address) external_wallet,
        address reserve_wallet,
        address super_root,
        optional(address) cloned,
        uint8 type_id
        ) {}

    function onEverTransfer(uint128 tokens, WalletArgs args) public functionID(0xca) {}

}