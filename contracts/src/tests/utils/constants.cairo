use starknet::{ContractAddress, contract_address_const};

pub(crate) const PRIVATE_KEY: felt252 = 0xDEADBEEF;
pub(crate) const PUBLIC_KEY: felt252 =
    0x5eeb3e0d88756352e5b7015667431490b631ea109bb6e31d65bb3bef604c186;
pub(crate) const MSG_HASH: felt252 =
    0x492f5c648d6e2c5592504078f28ae39fae7b702a6d6977e7024adbaf1c7ec66;

pub(crate) fn CALLER() -> ContractAddress {
    contract_address_const::<'CALLER'>()
}

pub(crate) fn RECEIVER() -> ContractAddress {
    contract_address_const::<'RECEIVER'>()
}

pub(crate) fn KUDOS() -> ContractAddress {
    contract_address_const::<'KUDOS'>()
}

pub(crate) fn KUDIS() -> ContractAddress {
    contract_address_const::<'KUDIS'>()
}

pub(crate) fn BAD_SIGNATURE() -> (felt252, Array<felt252>) {
    (0x1, array![0x2, 0x3])
}

/// Signatures were computed using starknet.py
pub(crate) fn GOOD_SIGNATURE() -> (felt252, Array<felt252>) {
    let msg_hash = 0x492f5c648d6e2c5592504078f28ae39fae7b702a6d6977e7024adbaf1c7ec66;
    (
        msg_hash,
        array![
            0x7a5ec675936dddddb949162f4b7f73f5c6e532ecff47249bb0e096047a33a2,
            0x110cfbb7bb5ae0b416d250d7ff715c55c41dd33564595d96f998fcc15f94338
        ]
    )
}

pub(crate) fn GOOD_SIGNATURE_W_PIN() -> (felt252, Array<felt252>) {
    let msg_hash = 0x5265a44510b3d941cd17945b82b72aa79557062c786c900e30189de0f79d749;
    (
        msg_hash,
        array![
            0xfb4c5230c78b66e8f78b558f891c090bba36b1bcef67fb91e503be43cb509b,
            0x612435be895bd326dbcf5fd43f8952b144c163b324563b948a4186f516c43c3
        ]
    )
}
