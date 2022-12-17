pragma ton-solidity >=0.47.0;

import "../structures/FlexVersion.sol";

abstract contract AGlobalConfig {
    function getDetails() public returns (
        FlexVersion version,
        address wrappers_cfg,
        address flex,
        address user_cfg,
        string description
    ) {}
}
