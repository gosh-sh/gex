pragma ton-solidity >=0.47.0;

struct BurnInfo {
  uint256 out_pubkey;
  optional(address) out_owner;
  address wallet;
  optional(TvmCell) notify;
}
