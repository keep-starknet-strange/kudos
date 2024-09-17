use kudos::tests::common::setup_account;
use kudos::tests::mocks::credential_registry_mock::CredentialRegistryMock;
use kudos::tests::utils::constants::{BAD_SIGNATURE, GOOD_SIGNATURE, GOOD_SIGNATURE_W_PIN};
use snforge_std::{
    declare, ContractClassTrait, spy_events, EventSpyAssertionsTrait, start_cheat_caller_address,
    DeclareResultTrait
};
use starknet::ContractAddress;

type ComponentState =
    CredentialRegistryComponent::ComponentState<CredentialRegistryMock::ContractState>;