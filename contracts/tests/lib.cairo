mod utils;
use kudos::credential_registry::{
    CredentialRegistryComponent, ICredentialRegistryDispatcher, ICredentialRegistryDispatcherTrait
};
use kudos::oz16::erc20::ERC20Component;
use kudos::oz16::{IERC20Dispatcher, IERC20DispatcherTrait};
use kudos::utils::constants::{
    CALLER, NAME, SYMBOL, DECIMALS, CREDENTIAL_HASH, CREDENTIAL_HASH_2, REGISTRATION_AMOUNT,
    ZERO_ADDRESS, RECEIVER, DUMMY, CREDENTIAL_HASH_BAD, SECONDS_IN_30_DAYS, FIVE, ZERO
};
use kudos::{Kudos, IKudosDispatcher, IKudosDispatcherTrait};
use snforge_std::{
    spy_events, EventSpyAssertionsTrait, start_cheat_caller_address,
    start_cheat_block_timestamp_global, stop_cheat_block_timestamp_global
};
use starknet::get_block_timestamp;
use utils::{setup, setup_registered, test_description, one, send_5_kudos};

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
    kudos.give_kudos(CREDENTIAL_HASH, CREDENTIAL_HASH_2, test_description());

    assert_eq!(kudos.get_total_given(CALLER()), one());
    assert_eq!(kudos.get_total_received(RECEIVER()), one());

    let expected_kudos_event = Kudos::Event::KudosGiven(
        Kudos::KudosGiven {
            sender: CALLER(), receiver: RECEIVER(), description: test_description()
        }
    );
    spy.assert_emitted(@array![(kudos.contract_address, expected_kudos_event)]);
}

#[test]
#[should_panic(expected: 'Sender not registered')]
fn test_give_kudos_sender_unregistered() {
    let kudos = IKudosDispatcher { contract_address: setup_registered() };
    start_cheat_caller_address(kudos.contract_address, DUMMY());
    kudos.give_kudos(CREDENTIAL_HASH, CREDENTIAL_HASH_2, test_description());
}

#[test]
#[should_panic(expected: 'Receiver not registered')]
fn test_give_kudos_receiver_unregistered() {
    let kudos = IKudosDispatcher { contract_address: setup_registered() };
    start_cheat_caller_address(kudos.contract_address, CALLER());
    kudos.give_kudos(CREDENTIAL_HASH, CREDENTIAL_HASH_BAD, test_description());
}

#[test]
#[should_panic(expected: 'Minted balance is zero')]
fn test_give_kudos_minted_balance_zero() {
    let kudos = IKudosDispatcher { contract_address: setup_registered() };
    start_cheat_caller_address(kudos.contract_address, CALLER());
    send_5_kudos(kudos);

    kudos.give_kudos(CREDENTIAL_HASH, CREDENTIAL_HASH_2, test_description());
}

#[test]
fn test_monthly_mint_full_amount() {
    let kudos = IKudosDispatcher { contract_address: setup_registered() };

    start_cheat_caller_address(kudos.contract_address, CALLER());
    send_5_kudos(kudos);

    let thirty_days_pass = get_block_timestamp() + SECONDS_IN_30_DAYS + 1;
    start_cheat_block_timestamp_global(block_timestamp: thirty_days_pass);
    assert(kudos.get_minted_balance(CALLER()) == ZERO, 'Minted balance is not zero');

    kudos.monthly_mint();

    assert(kudos.get_minted_balance(CALLER()) == FIVE, 'Minted balance is not five');

    stop_cheat_block_timestamp_global()
}

#[test]
#[should_panic(expected: 'Minted balance is full')]
fn test_monthly_mint_with_a_full_balance() {
    let kudos = IKudosDispatcher { contract_address: setup_registered() };

    start_cheat_caller_address(kudos.contract_address, CALLER());

    let thirty_days_pass = get_block_timestamp() + SECONDS_IN_30_DAYS + 1;
    start_cheat_block_timestamp_global(block_timestamp: thirty_days_pass);
    assert(kudos.get_minted_balance(CALLER()) == FIVE, 'Minted balance is not five');

    kudos.monthly_mint();

    stop_cheat_block_timestamp_global()
}

#[test]
#[should_panic(expected: 'Minter not registered')]
fn test_monthly_mint_minter_unregistered() {
    let kudos = IKudosDispatcher { contract_address: setup_registered() };
    start_cheat_caller_address(kudos.contract_address, DUMMY());
    kudos.monthly_mint();
}
