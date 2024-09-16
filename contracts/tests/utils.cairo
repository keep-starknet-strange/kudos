use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};
use starknet::{ContractAddress, contract_address_const};

pub const DECIMALS: u8 = 18;

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

pub fn NAME() -> ByteArray {
    "Kudos"
}


pub fn SYMBOL() -> ByteArray {
    "KUDOS"
}

pub fn setup() -> ContractAddress {
    let mut calldata: Array<felt252> = array![];
    calldata.append_serde(NAME());
    calldata.append_serde(SYMBOL());
    calldata.append_serde(OWNER());

    declare_deploy("Kudos", calldata)
}

pub fn declare_deploy(contract_name: ByteArray, calldata: Array<felt252>) -> ContractAddress {
    let contract = declare(contract_name).unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@calldata).unwrap();
    contract_address
}

pub trait SerializedAppend<T> {
    fn append_serde(ref self: Array<felt252>, value: T);
}

impl SerializedAppendImpl<T, impl TSerde: Serde<T>, impl TDrop: Drop<T>> of SerializedAppend<T> {
    fn append_serde(ref self: Array<felt252>, value: T) {
        value.serialize(ref self);
    }
}
