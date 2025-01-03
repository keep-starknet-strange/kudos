use starknet::{ContractAddress, contract_address_const};

pub fn CALLER() -> ContractAddress {
    contract_address_const::<'CALLER'>()
}

pub fn RECEIVER() -> ContractAddress {
    contract_address_const::<'RECEIVER'>()
}

pub fn DUMMY() -> ContractAddress {
    contract_address_const::<'DUMMY'>()
}

pub fn ZERO_ADDRESS() -> ContractAddress {
    contract_address_const::<0>()
}

//
// `erc20`
//

pub const DECIMALS: u8 = 18;
pub const ZERO: u256 = 0;
pub const ONE: u256 = 1_000_000_000_000_000_000;
pub const FIVE: u256 = 5_000_000_000_000_000_000;
pub const REGISTRATION_AMOUNT: u256 = FIVE;
pub const MONTHLT_MINT_AMOUNT: u256 = FIVE;
pub const SECONDS_IN_30_DAYS: u64 = 30 * 24 * 60 * 60;

pub fn NAME() -> ByteArray {
    "Kudos"
}

pub fn SYMBOL() -> ByteArray {
    "KUDOS"
}

//
// `credential_registry`
//

pub const CREDENTIAL_HASH: felt252 = 0xDEADBEEF;
pub const CREDENTIAL_HASH_2: felt252 = 0xBEEFDEAD;
pub const CREDENTIAL_HASH_BAD: felt252 = 0xBAD;
