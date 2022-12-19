pragma ton-solidity >=0.53.0;

abstract contract AWrapper {
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

    function deployEmptyWallet(
        uint32 _answer_id,
        uint256 pubkey,
        optional(address) owner,
        uint128 evers) public functionID(0xb) returns(address value0) {}

    function getWalletAddress(uint256 pubkey, optional(address) owner) public functionID(0x300) returns(address value0) {}
 }