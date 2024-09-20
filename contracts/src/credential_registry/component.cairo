#[starknet::component]
pub mod CredentialRegistryComponent {
    use core::num::traits::zero::Zero;
    use kudos::credential_registry::ICredentialRegistry;
    use starknet::ContractAddress;

    #[storage]
    pub struct Storage {
        credentials: LegacyMap::<felt252, ContractAddress>,
        address_to_credential: LegacyMap::<ContractAddress, felt252>,
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

    pub mod Errors {
        pub const CREDENTIAL_DUPLICATE: felt252 = 'User already registered cred';
        pub const ADDRESS_DUPLICATE: felt252 = 'User already registered addr';
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

            self.emit(CredentialsRegistered { address, hash });
        }

        fn get_credential(
            self: @ComponentState<TContractState>, address: ContractAddress
        ) -> felt252 {
            self.address_to_credential.read(address)
        }

        fn get_credential_address(
            self: @ComponentState<TContractState>, hash: felt252
        ) -> ContractAddress {
            self.credentials.read(hash)
        }

        fn get_total_credentials(self: @ComponentState<TContractState>) -> u128 {
            self.total_credentials.read()
        }

        fn is_registered(self: @ComponentState<TContractState>, address: ContractAddress) -> bool {
            let credential = self.address_to_credential.read(address);
            if credential == 0 {
                return false;
            };

            let registered_address = self.get_credential_address(credential);
            if registered_address == starknet::contract_address_const::<0>() {
                return false;
            };

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
            assert(self.credentials.read(hash) == starknet::contract_address_const::<0>(), Errors::CREDENTIAL_DUPLICATE);

            self.credentials.write(hash, address);
        }
        fn _register_user(
            ref self: ComponentState<TContractState>, address: ContractAddress, hash: felt252
        ) {
            assert(
                self.address_to_credential.read(address) == 0,
                Errors::ADDRESS_DUPLICATE
            );

            self.address_to_credential.write(address, hash);
        }
    }
}
