#include "../modules/DexSchema.ligo"

type burn_type is Burn of address * nat
type use_type is dex_action

type burner_storage is record [
  pool_address    : address; 
  coin_address    : address; 
]

type burner_action is
| Default

type return is list(operation) * burner_storage
