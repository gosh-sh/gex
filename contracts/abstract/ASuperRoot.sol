pragma ton-solidity >=0.47.0;

import "../structures/FlexVersion.sol";

abstract contract ASuperRoot {
    function getDetails() public functionID(0x19) returns (
        uint256 pubkey,
        bool stop_trade_,
        bool abandon_ship_,
        bool update_started_,
        address owner,
        optional(address) update_team,
        TvmCell global_config_code,
        uint256 global_config_hash,
        uint8 workchain_id,
        optional(FlexVersion) version,
        optional(FlexVersion) beta_version,
        optional(address) deploying_cfg,
        optional(address) cur_cfg,
        optional(address) beta_cfg,
        optional(address) prev_super_root,
        optional(address) next_super_root,
        uint32 revision
    ) {}
}
