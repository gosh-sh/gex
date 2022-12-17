pragma ton-solidity >=0.47.0;

struct FlexVersion {
  uint32 wallet;   ///< Version of token wallets contracts
  uint32 exchange; ///< Version of exchange contracts (Flex root, pair, price)
  uint32 user;     ///< Version of user contracts (FlexClient)
}
