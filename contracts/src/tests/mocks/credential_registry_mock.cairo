#[starknet::contract]
pub(crate) mod CredentialRegistryMock {
    use kudos::credential_registry::component::CredentialRegistryComponent;

    component!(
        path: CredentialRegistryComponent,
        storage: credential_registry,
        event: CredentialRegistryEvent
    );

    #[abi(embed_v0)]
    impl CredentialRegistryImpl =
        CredentialRegistryComponent::CredentialRegistryImpl<ContractState>;
    impl CredentialRegistryInternalImpl = CredentialRegistryComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        credential_registry: CredentialRegistryComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        CredentialRegistryEvent: CredentialRegistryComponent::Event
    }
}
