address admin {

module LakeToken {
    use aptos_framework::coin;
    use std::signer;
    use std::string;

    struct LAKE{}

    struct CoinCapabilities<phantom LAKE> has key {
        mint_capability: coin::MintCapability<LAKE>,
        burn_capability: coin::BurnCapability<LAKE>,
        freeze_capability: coin::FreezeCapability<LAKE>,
    }

    const E_NO_ADMIN: u64 = 0;
    const E_NO_CAPABILITIES: u64 = 1;
    const E_HAS_CAPABILITIES: u64 = 2;

    public entry fun init_lake(account: &signer) {
        let (burn_capability, freeze_capability, mint_capability) = coin::initialize<LAKE>(
            account,
            string::utf8(b"LakeToken"),
            string::utf8(b"LAKE"),
            18,
            true,
        );

        assert!(signer::address_of(account) == @admin, E_NO_ADMIN);
        assert!(!exists<CoinCapabilities<LAKE>>(@admin), E_HAS_CAPABILITIES);

        move_to<CoinCapabilities<LAKE>>(account, CoinCapabilities<LAKE>{mint_capability, burn_capability, freeze_capability});
    }

    public entry fun mint<LAKE>(account: &signer, user: address, amount: u64) acquires CoinCapabilities {
        let account_address = signer::address_of(account);
        assert!(account_address == @admin, E_NO_ADMIN);
        assert!(exists<CoinCapabilities<LAKE>>(account_address), E_NO_CAPABILITIES);
        let mint_capability = &borrow_global<CoinCapabilities<LAKE>>(account_address).mint_capability;
        let coins = coin::mint<LAKE>(amount, mint_capability);
        coin::deposit(user, coins)
    }

    public entry fun burn<LAKE>(coins: coin::Coin<LAKE>) acquires CoinCapabilities {
        let burn_capability = &borrow_global<CoinCapabilities<LAKE>>(@admin).burn_capability;
        coin::burn<LAKE>(coins, burn_capability);
    }
}
}
