mod utils;
use kudos::credential_registry::{CredentialRegistryComponent, ICredentialRegistryDispatcher, ICredentialRegistryDispatcherTrait};
use kudos::oz16::erc20::ERC20Component;
use kudos::oz16::{IERC20Dispatcher, IERC20DispatcherTrait};
use kudos::utils::constants::{CALLER, NAME, SYMBOL, DECIMALS, CREDENTIAL_HASH, REGISTRATION_AMOUNT, ZERO_ADDRESS};
use kudos::{IKudosDispatcher, IKudosDispatcherTrait};
use snforge_std::{spy_events, EventSpyAssertionsTrait, start_cheat_caller_address};

#[test]
fn test_erc20_metadata() {
    let token = IERC20Dispatcher { contract_address: utils::setup() };

    assert_eq!(token.name(), NAME());
    assert_eq!(token.symbol(), SYMBOL());
    assert_eq!(token.decimals(), DECIMALS);
    assert_eq!(token.total_supply(), 0);
}

#[test]
fn test_bad_erc20_metadata() {
    let token = IERC20Dispatcher { contract_address: utils::setup() };

    assert!(token.name() != "WRONG_NAME");
    assert!(token.symbol() != "WRONG_SYMBOL");
    assert!(token.decimals() != 0);
}

#[test]
fn test_register_sw_employee_mint() {
    let kudos_contract = IKudosDispatcher { contract_address: utils::setup() };
    let contract_address = kudos_contract.contract_address;

    let mut spy = spy_events();

    start_cheat_caller_address(contract_address, CALLER());
    kudos_contract.register_sw_employee(CREDENTIAL_HASH);

    let token = IERC20Dispatcher { contract_address };
    assert_eq!(token.balance_of(CALLER()), REGISTRATION_AMOUNT);
    assert_eq!(token.total_supply(), REGISTRATION_AMOUNT);

    let expected_erc20_event = ERC20Component::Event::Transfer(ERC20Component::Transfer {
        from: ZERO_ADDRESS(),
        to: CALLER(),
        value: REGISTRATION_AMOUNT,
    });
    spy.assert_emitted(@array![(contract_address, expected_erc20_event)]);
}


#[test]
fn test_register_sw_employee_registered() {
    let kudos_contract = IKudosDispatcher { contract_address: utils::setup() };
    let contract_address = kudos_contract.contract_address;

    let mut spy = spy_events();

    start_cheat_caller_address(contract_address, CALLER());
    kudos_contract.register_sw_employee(CREDENTIAL_HASH);

    let registry = ICredentialRegistryDispatcher { contract_address };
    assert_eq!(registry.get_credential(CALLER()), CREDENTIAL_HASH);
    assert_eq!(registry.get_credential_address(CREDENTIAL_HASH), CALLER());
    assert_eq!(registry.is_registered(CALLER()), true);
    assert_eq!(registry.get_total_credentials(), 1);

    let expected_cr_event = CredentialRegistryComponent::Event::CredentialsRegistered(
        CredentialRegistryComponent::CredentialsRegistered {
            address: CALLER(), hash: CREDENTIAL_HASH
        }
    );
    spy.assert_emitted(@array![(contract_address, expected_cr_event)]);


}
