pragma ton-solidity >=0.47.0;

import "../structures/Tip3Structures.sol";
import "../structures/BindInfo.sol";

abstract contract AFlexWallet {
    function getDetails() public functionID(0x100)
        returns (
            string name, string symbol, uint8 decimals, uint128 balance,
            uint256 root_public_key, address root_address, uint256 wallet_pubkey,
            optional(address) owner_address,
            optional(uint256) lend_pubkey,
            lend_owner_array_record[] lend_owners,
            uint128 lend_balance,
            optional(BindInfo) binding,
            uint256 code_hash,
            uint16 code_depth,
            int8 workchain_id) {}
            
    function details(uint32 _answer_id) public functionID(0x14)
        returns (
            string name, string symbol, uint8 decimals, uint128 balance,
            uint256 root_public_key, address root_address, uint256 wallet_pubkey,
            optional(address) owner_address,
            optional(uint256) lend_pubkey,
            lend_owner_array_record[] lend_owners,
            uint128 lend_balance,
            optional(BindInfo) binding,
            uint256 code_hash,
            uint16 code_depth,
            int8 workchain_id) {}

    function cancelOrder(
        uint128 evers,
        address price,
        bool sell,
        optional(uint256) order_id
    ) public functionID(0x11) {}

    function makeOrder(
        uint32 _answer_id,
        optional(address) answer_addr,
        uint128 evers,
        uint128 lend_balance,
        uint32 lend_finish_time,
        uint128 price_num,
        TvmCell unsalted_price_code,
        TvmCell salt,
        FlexLendPayloadArgs args
    ) public functionID(0x10) {}
    
    function bind(
    	bool set_binding,
    	optional(BindInfo) binding,
    	bool set_trader,
    	optional(uint256) trader
    ) public functionID(0x13) {}
}
