use kudos::credential_registry::ICredentialRegistry;

use kudos::credential_registry::component::{
    CredentialRegistryComponent, CredentialRegistryComponent::InternalImpl
};
use super::mocks::mock_credential_registry::CredentialRegistryMock;

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

    assert!(registry.get_total_credentials() == 0);
}
