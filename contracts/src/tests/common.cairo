use kudos::tests::utils::constants::PUBLIC_KEY;
use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};
use starknet::ContractAddress;

pub fn setup_account() -> ContractAddress {
    let account_mock = declare("AccountMock").unwrap().contract_class();
    let (contract_address, _) = account_mock.deploy(@array![PUBLIC_KEY]).unwrap();
    contract_address
}
