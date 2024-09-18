use CredentialRegistryComponent::InternalTrait;
use kudos::credential_registry::ICredentialRegistry;
use kudos::credential_registry::component::{
    CredentialRegistryComponent, CredentialRegistryComponent::InternalImpl
};
use kudos::utils::constants::{CALLER, CREDENTIAL_HASH, ZERO_ADDRESS};
use super::mock_credential_registry::CredentialRegistryMock;

//
// Setup
//

type ComponentState =
    CredentialRegistryComponent::ComponentState<CredentialRegistryMock::ContractState>;

impl ComponentStateDefault of Default<ComponentState> {
    fn default() -> ComponentState {
        CredentialRegistryComponent::component_state_for_testing()
    }
}

#[test]
fn test_initial_values() {
    let mut registry: ComponentState = Default::default();

    assert!(registry.get_credential(CALLER()) == 0);
    assert!(registry.get_credential_address(CREDENTIAL_HASH) == ZERO_ADDRESS());
    assert!(registry.is_registered(CALLER()) == false);
    assert!(registry.get_total_credentials() == 0);
}

#[test]
fn test_register_credential() {
    let mut registry: ComponentState = Default::default();
    registry._register_credential(CREDENTIAL_HASH, CALLER());
    registry._register_user(CALLER(), CREDENTIAL_HASH);

    assert!(registry.get_credential(CALLER()) == CREDENTIAL_HASH);
    assert!(registry.is_registered(CALLER()) == true);
    assert!(registry.get_credential_address(CREDENTIAL_HASH) == CALLER());
}

#[test]
fn test_register_credential_address_zero() {
    let mut registry: ComponentState = Default::default();
    registry._register_credential(CREDENTIAL_HASH, ZERO_ADDRESS());
    registry._register_user(ZERO_ADDRESS(), CREDENTIAL_HASH);

    assert!(registry.get_credential(ZERO_ADDRESS()) == CREDENTIAL_HASH);
    assert!(registry.is_registered(ZERO_ADDRESS()) == false);
    assert!(registry.get_credential_address(CREDENTIAL_HASH) == ZERO_ADDRESS());
}

#[test]
#[should_panic(expected: 'User already registered cred')]
fn test_double_register_credential() {
    let mut registry: ComponentState = Default::default();
    registry._register_credential(CREDENTIAL_HASH, CALLER());
    registry._register_credential(CREDENTIAL_HASH, CALLER());
}

#[test]
#[should_panic(expected: 'User already registered addr')]
fn test_double_register_user() {
    let mut registry: ComponentState = Default::default();
    registry._register_user(CALLER(), CREDENTIAL_HASH);
    registry._register_user(CALLER(), CREDENTIAL_HASH);
}
