#include "../modules/BurnerSchema.ligo"
#include "../modules/BurnerMethods.ligo"

function main(const action : burner_action; const s : burner_storage) : return is
  (case action of
  | Default -> list [
    Tezos.transaction(
      TezToTokenPayment(record [
        min_out = 1n;
        receiver = Tezos.self_address;
      ]),
      Tezos.amount,
      get_quipuswap_contract(s.pool_address)
    );
    Tezos.transaction(
      Burn(Tezos.self_address, 0n),
      0mutez,
      get_token_burn_contract(s.coin_address)
    )
  ]
  end, s)
