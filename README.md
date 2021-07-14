# Description

This project is aimed bring fresh financial abstractions to the network and open up new economical opportunities for the community members who eager for yield mechanics. Farming rewards the token stakers and vaults provides.

The current implementation supports only [FA1.2](https://gitlab.com/tzip/tzip/-/blob/master/proposals/tzip-7/tzip-7.md) tokens.

# Contracts

The architecture design is driven by the goal to maximize simplicity, decentralization, and scalability.

The system involves 4 contract types:
1. PAUL  - the FA1.2 token to be harvested;
2. Staking  -  contract for staking PAUL tokens;
3. Farming  - contract for yield farming;
4. Burner - proxy to exchange baker's XTZ and burn PAUL tokens;
5. Vault - contract for auto reinvestment;
6. Referral - referral system contract.


The flow is self-evident. The user provides liquidity to Quipuswap by interacting with Dex and receiving its shares. Then he stakes the FA1.2 token in the Farming contract that also exposes FA1.2 standard entrypoints; the user receives farming pool shares. He can claim a reward, withdraw the stake or simply transfer his shares to another user. The user doesn't interact with the Burner directly.

## Staking

The staking contract for FA1.2 tokens implements the FA1.2 standard for pool shares. It supports 4 functions: stake, earn, unstake, and implements the PAUL distribution logic.

## Farming

The main farming contract deployed for each whitelisted token and that implements the FA1.2 standard for pool shares. It supports 4 functions: stake, earn, unstake, and burn and implements the PAUL distribution logic.

## Burner
The Quipuswap liquidity providers earn not only the swap fees but baker's rewards that are distributed once per constant period. The Burner is used to exchange bakers rewards for PAUL and burn the tokens to cause deflation.

## Vault

The vault contract is designed to implement auto reinvestments and implements the FA1.2 standard for pool shares. It supports 4 functions: stake, earn, unstake, swap and implements the PAUL distribution logic.

## Referral
The referral contract that stores and updates all info related to the project`s referral system.