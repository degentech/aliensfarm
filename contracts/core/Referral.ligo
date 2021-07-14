#include "../modules/ReferralSchema.ligo"
#include "../modules/ReferralMethods.ligo"

function main(const action : referral_actions; const s : referral_storage) : referral_return is
  case action of
  | SetReferrer(params)                  -> set_referrer(params.0, params.1, s)
  | GetReferralInfo(params)              -> get_referral_info(params, s)
  | ChangeCommission(params)             -> change_commission(params, s)
  | AddRemoveFarm(params)                -> add_remove_farm(params.0, params.1, s)
  | ChangeAdmin(params)                  -> change_admin(params, s)
  end
