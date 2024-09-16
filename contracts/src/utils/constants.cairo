use starknet::{ContractAddress, contract_address_const};

pub fn CALLER() -> ContractAddress {
    contract_address_const::<'CALLER'>()
}

pub fn RECEIVER() -> ContractAddress {
    contract_address_const::<'RECEIVER'>()
}

pub fn SENDER() -> ContractAddress {
    contract_address_const::<'SENDER'>()
}

pub fn OWNER() -> ContractAddress {
    contract_address_const::<'OWNER'>()
}

pub fn ZERO_ADDRESS() -> ContractAddress {
    contract_address_const::<0>()
}

//
// `erc20`
//

pub const DECIMALS: u8 = 18;
pub const REGISTRATION_AMOUNT: u256 = 1_000_000_000_000_000_000_000_000;

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
