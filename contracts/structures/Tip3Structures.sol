pragma ton-solidity >=0.47.0;

struct lend_pubkey_array_record {
  uint256      lend_pubkey;           ///< Lend ownership public key.
  uint32       lend_finish_time; ///< Lend ownership finish time.
}

struct addr_std_fixed {
    int8 workchain_id;
    uint256 addr;
}

struct lend_owner_key {
  addr_std_fixed dest;    ///< Destination contract address.
}

struct lend_owner_array_record {
  lend_owner_key lend_key;         ///< Lend ownership key (destination address + user id).
  uint128        lend_balance;     ///< Lend ownership balance.
  uint32         lend_finish_time; ///< Lend ownership finish time.
}

struct user_ids_record {
    uint64 first;
    uint256 second;
}

struct Allowance{
    address spender;
    uint128 remainingTokens;
}

struct restriction_info {
  address flex;                     ///< Flex root address
  uint256 unsalted_price_code_hash; ///< PriceXchg code hash (unsalted)
}

struct Tip3Creds {
  uint256 pubkey;
  optional(address) owner;
}

struct Tip3Cfg {
    string name;
    string symbol;
    uint8 decimals;
    uint256 root_public_key;
    address root_address;
}

struct FlexLendPayloadArgs {
  bool      sell;               ///< Sell order if true, buy order if false.
  bool      immediate_client;   ///< Should this order try to be executed as a client order first
                                ///<  (find existing corresponding orders).
  bool      post_order;         ///< Should this order be enqueued if it doesn't already have corresponding orders.
  uint128   amount;             ///< Amount of major tokens to buy or sell.
  address   client_addr;        ///< Client contract address. PriceXchg will execute cancels from this address,
                                ///<  send notifications and return the remaining native funds (evers) to this address.
  uint256   user_id;            ///< User id. It is trader wallet's pubkey. Receiving wallet credentials will be { pubkey: user_id, owner: client_addr }.
  uint256   order_id;           ///< Order id for client purposes.
}

struct FlexTransferPayloadArgs {
  bool       sender_sell;       ///< Sender is seller in deal (selling major tokens)
  bool       sender_taker;      ///< Sender is a taker in deal (and pays fees)
  uint256    sender_user_id;    ///< Sender user id for client purposes.
  uint256    receiver_user_id;  ///< Receiver user id for client purposes.
  uint256    receiver_order_id; ///< Receiver order id for client purposes.
  address    another_tip3_root; ///< Address of another tip3 root (Wrapper) in trading pair.
  uint128    price_num;         ///< Price numerator
  uint128    price_denum;       ///< Price denominator
  uint128    taker_fee;         ///< Tokens taken (fee) from taker
  uint128    maker_vig;         ///< Tokens given (vig) to maker
  address    pair;              ///< Address of XchgPair contract.
  Tip3Cfg major_tip3cfg;     ///< Configuration of the major tip3 token.
  Tip3Cfg minor_tip3cfg;     ///< Configuration of the minor tip3 token.
}
