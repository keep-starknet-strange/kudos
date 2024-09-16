#[starknet::component]
pub mod CredentialRegistryComponent {
    use core::num::traits::zero::Zero;
    use kudos::credential_registry::ICredentialRegistry;
    use starknet::ContractAddress;
    use starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map
    };

    #[storage]
    pub struct Storage {
        credentials: Map::<felt252, ContractAddress>,
        user_to_credentials: Map::<ContractAddress, felt252>,
        total_credentials: u128,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        CredentialsRegistered: CredentialsRegistered,
    }

    #[derive(Drop, starknet::Event)]
    pub struct CredentialsRegistered {
        #[key]
        pub address: ContractAddress,
        pub hash: felt252,
    }

    pub mod CredentialRegistryErrors {
        pub const CREDENTIAL_REGISTERED: felt252 = 'User prev registered cred';
        pub const CREDENTIAL_INVALID: felt252 = 'User provided is invalid';
        pub const INVALID_SIGNATURE: felt252 = 'Invalid signature provided';
    }

    #[embeddable_as(CredentialRegistryImpl)]
    impl CredentialRegistry<
        TContractState, +HasComponent<TContractState>
    > of ICredentialRegistry<ComponentState<TContractState>> {
        fn register_credentials(
            ref self: ComponentState<TContractState>, address: ContractAddress, hash: felt252,
        ) {
            self._register_credential(hash, address);
            self._register_user(address, hash);

            let prev_total = self.total_credentials.read();
            self.total_credentials.write(prev_total + 1);

            self.emit(CredentialsRegistered { address, hash })
        }

        fn get_credential(
            self: @ComponentState<TContractState>, address: ContractAddress
        ) -> felt252 {
            self.user_to_credentials.entry(address).read()
        }

        fn get_credential_address(
            self: @ComponentState<TContractState>, hash: felt252
        ) -> ContractAddress {
            self.credentials.entry(hash).read()
        }

        fn get_total_credentials(self: @ComponentState<TContractState>) -> u128 {
            self.total_credentials.read()
        }

        fn is_registered(self: @ComponentState<TContractState>, address: ContractAddress) -> bool {
            let credential = self.user_to_credentials.entry(address).read();
            let registered_address = self.get_credential_address(credential);
            registered_address == address
        }
    }

    #[generate_trait]
    pub impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn _register_credential(
            ref self: ComponentState<TContractState>, hash: felt252, address: ContractAddress
        ) {
            assert(
                self.credentials.entry(hash).read().is_zero(),
                CredentialRegistryErrors::CREDENTIAL_REGISTERED
            );

            self.credentials.entry(hash).write(address);
        }
        fn _register_user(
            ref self: ComponentState<TContractState>, address: ContractAddress, hash: felt252
        ) {
            assert(
                self.user_to_credentials.entry(address).read().is_zero(),
                CredentialRegistryErrors::CREDENTIAL_REGISTERED
            );

            self.user_to_credentials.entry(address).write(hash);
        }
    }
}
