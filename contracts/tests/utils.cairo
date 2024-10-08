use kudos::utils::constants::{
    NAME, SYMBOL, CALLER, RECEIVER, CREDENTIAL_HASH, CREDENTIAL_HASH_2, ONE
};
use kudos::{IKudosDispatcher, IKudosDispatcherTrait};
use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address};
use starknet::ContractAddress;

pub trait SerializedAppend<T> {
    fn append_serde(ref self: Array<felt252>, value: T);
}

impl SerializedAppendImpl<T, impl TSerde: Serde<T>, impl TDrop: Drop<T>> of SerializedAppend<T> {
    fn append_serde(ref self: Array<felt252>, value: T) {
        value.serialize(ref self);
    }
}

pub fn declare_deploy(contract_name: ByteArray, calldata: Array<felt252>) -> ContractAddress {
    let contract = declare(contract_name).unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@calldata).unwrap();
    contract_address
}

pub fn setup() -> ContractAddress {
    let mut calldata: Array<felt252> = array![];
    calldata.append_serde(NAME());
    calldata.append_serde(SYMBOL());

    declare_deploy("Kudos", calldata)
}

pub fn setup_registered() -> ContractAddress {
    let kudos_contract = IKudosDispatcher { contract_address: setup() };
    let contract_address = kudos_contract.contract_address;

    start_cheat_caller_address(contract_address, CALLER());
    kudos_contract.register_sw_employee(CREDENTIAL_HASH);

    start_cheat_caller_address(contract_address, RECEIVER());
    kudos_contract.register_sw_employee(CREDENTIAL_HASH_2);

    contract_address
}

pub fn test_amount() -> u256 {
    ONE * 25
}

pub fn test_description() -> felt252 {
    'reviewed my PR'
}
