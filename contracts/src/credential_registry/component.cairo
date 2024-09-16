#[starknet::component]
pub mod CredentialRegistryComponent {
    use core::num::traits::zero::Zero;
    use kudos::credential_registry::interface::ICredentialRegistry;
    use starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map
    };
    use starknet::{ContractAddress, contract_address_const, get_caller_address};

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
            ref self: ComponentState<TContractState>, hash: felt252, signature: Array<felt252>,
        ) {
            let address = get_caller_address();

            self._register_credentials(hash, address, signature);

            let prev_total = self.total_credentials.read();
            self.total_credentials.write(prev_total + 1);

            // TODO: mint $KUDOS here

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
            self.user_to_credentials.entry(address).read().is_non_zero()
        }
    }

    #[generate_trait]
    pub impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn _register_credentials(
            ref self: ComponentState<TContractState>,
            hash: felt252,
            contract_address: ContractAddress,
            signature: Array<felt252>
        ) {
            assert(
                self.credentials.entry(hash).read() == contract_address_const::<0>(),
                CredentialRegistryErrors::CREDENTIAL_REGISTERED
            );

            self.credentials.entry(hash).write(contract_address);
            self.user_to_credentials.entry(contract_address).write(hash);
        }
    }
}
