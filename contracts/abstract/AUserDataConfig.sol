pragma ton-solidity >=0.47.0;

import "../structures/FlexVersion.sol";
import "../structures/BindInfo.sol";

abstract contract AUserDataConfig {
    function getDetails() public returns (
        FlexVersion triplet,
        BindInfo binding,
        TvmCell flex_client_stub,
        TvmCell flex_client_code,
        TvmCell auth_index_code,
        TvmCell user_id_index_code
    ) {}

    function getFlexClientAddr(uint256 pubkey) public returns (address value0) {}
    function deployFlexClient(uint32 _answer_id, uint256 pubkey, uint128 deploy_evers) public returns (address value0) {}
}
