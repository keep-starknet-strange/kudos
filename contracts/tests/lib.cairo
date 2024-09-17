mod utils;
use kudos::credential_registry::{
    CredentialRegistryComponent, ICredentialRegistryDispatcher, ICredentialRegistryDispatcherTrait
};
use kudos::oz16::erc20::ERC20Component;
use kudos::oz16::{IERC20Dispatcher, IERC20DispatcherTrait};
use kudos::utils::constants::{
    CALLER, NAME, SYMBOL, DECIMALS, CREDENTIAL_HASH, CREDENTIAL_HASH_2, REGISTRATION_AMOUNT,
    ZERO_ADDRESS, RECEIVER, DUMMY, CREDENTIAL_HASH_BAD
};
use kudos::{Kudos, IKudosDispatcher, IKudosDispatcherTrait};
use snforge_std::{spy_events, EventSpyAssertionsTrait, start_cheat_caller_address};
use utils::{setup, setup_registered, test_amount, test_description};

#[test]
fn test_erc20_metadata() {
    let token = IERC20Dispatcher { contract_address: setup() };

    assert_eq!(token.name(), NAME());
    assert_eq!(token.symbol(), SYMBOL());
    assert_eq!(token.decimals(), DECIMALS);
    assert_eq!(token.total_supply(), 0);
}

#[test]
fn test_bad_erc20_metadata() {
    let token = IERC20Dispatcher { contract_address: setup() };

    assert!(token.name() != "WRONG_NAME");
    assert!(token.symbol() != "WRONG_SYMBOL");
    assert!(token.decimals() != 0);
}

#[test]
#[should_panic]
fn test_erc20_no_transfer() {
    let token = IERC20Dispatcher { contract_address: setup_registered() };
    start_cheat_caller_address(token.contract_address, CALLER());
    token.transfer(RECEIVER(), 1);
}

#[test]
#[should_panic]
fn test_erc20_no_transfer_from() {
    let token = IERC20Dispatcher { contract_address: setup_registered() };
    token.transfer_from(CALLER(), RECEIVER(), 1);
}

#[test]
fn test_register_sw_employee_mint() {
    let mut spy = spy_events();

    let token = IERC20Dispatcher { contract_address: setup_registered() };
    assert_eq!(token.balance_of(CALLER()), REGISTRATION_AMOUNT);
    assert_eq!(token.total_supply(), REGISTRATION_AMOUNT * 2);

    let expected_erc20_event = ERC20Component::Event::Transfer(
        ERC20Component::Transfer { from: ZERO_ADDRESS(), to: CALLER(), value: REGISTRATION_AMOUNT, }
    );
    spy.assert_emitted(@array![(token.contract_address, expected_erc20_event)]);
}


#[test]
fn test_register_sw_employee_registered() {
    let mut spy = spy_events();

    let registry = ICredentialRegistryDispatcher { contract_address: setup_registered() };
    assert_eq!(registry.get_credential(CALLER()), CREDENTIAL_HASH);
    assert_eq!(registry.get_credential_address(CREDENTIAL_HASH), CALLER());
    assert_eq!(registry.is_registered(CALLER()), true);
    assert_eq!(registry.get_total_credentials(), 2);

    let expected_cr_event = CredentialRegistryComponent::Event::CredentialsRegistered(
        CredentialRegistryComponent::CredentialsRegistered {
            address: CALLER(), hash: CREDENTIAL_HASH
        }
    );
    spy.assert_emitted(@array![(registry.contract_address, expected_cr_event)]);
}

#[test]
fn test_give_kudos() {
    let mut spy = spy_events();

    let kudos = IKudosDispatcher { contract_address: setup_registered() };
    start_cheat_caller_address(kudos.contract_address, CALLER());
    kudos.give_kudos(test_amount(), CREDENTIAL_HASH, CREDENTIAL_HASH_2, test_description());

    assert_eq!(kudos.get_total_given(CALLER()), test_amount());
    assert_eq!(kudos.get_total_received(RECEIVER()), test_amount());

    let expected_kudos_event = Kudos::Event::KudosGiven(
        Kudos::KudosGiven {
            sender: CALLER(),
            receiver: RECEIVER(),
            amount: test_amount(),
            description: test_description()
        }
    );
    spy.assert_emitted(@array![(kudos.contract_address, expected_kudos_event)]);
}

#[test]
#[should_panic(expected: 'Sender not registered')]
fn test_give_kudos_sender_unregistered() {
    let kudos = IKudosDispatcher { contract_address: setup_registered() };
    start_cheat_caller_address(kudos.contract_address, DUMMY());
    kudos.give_kudos(test_amount(), CREDENTIAL_HASH, CREDENTIAL_HASH_2, test_description());
}

#[test]
#[should_panic(expected: 'Receiver not registered')]
fn test_give_kudos_receiver_unregistered() {
    let kudos = IKudosDispatcher { contract_address: setup_registered() };
    start_cheat_caller_address(kudos.contract_address, CALLER());
    kudos.give_kudos(test_amount(), CREDENTIAL_HASH, CREDENTIAL_HASH_BAD, test_description());
}
