#[starknet::component]
pub mod CredentialRegistryComponent {
    use core::num::traits::zero::Zero;
    use kudos::credential_registry::interface::ICredentialRegistry;
    use openzeppelin::account::interface::{AccountABIDispatcherTrait, AccountABIDispatcher};
    use starknet::storage::Map;
    use starknet::{ContractAddress, contract_address_const, get_caller_address};

    #[storage]
    struct Storage {
        credentials: Map::<felt252, ContractAddress>,
        user_to_credentials: Map::<ContractAddress, felt252>,
        credentials_w_pin: Map::<felt252, ContractAddress>,
        user_to_credentials_w_pin: Map::<ContractAddress, felt252>,
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
        pub hash_w_pin: felt252
    }

    pub mod CredentialRegistryErrors {
        pub const CREDENTIAL_REGISTERED: felt252 = 'User prev registered cred';
        pub const CREDENTIAL_W_PIN_REGISTERED: felt252 = 'User prev registered cred_w_pin';
        pub const CREDENTIAL_INVALID: felt252 = 'User provided is invalid';
        pub const INVALID_SIGNATURE: felt252 = 'Invalid signature provided';
    }

    #[embeddable_as(CredentialRegistryImpl)]
    impl CredentialRegistry<
        TContractState, +HasComponent<TContractState>
    > of ICredentialRegistry<ComponentState<TContractState>> {
        fn register_credentials(
            ref self: ComponentState<TContractState>,
            hash: felt252,
            signature: Array<felt252>,
            hash_w_pin: felt252,
            signature_w_pin: Array<felt252>
        ) {
            assert(hash != hash_w_pin, CredentialRegistryErrors::CREDENTIAL_INVALID);
            let address = get_caller_address();

            self._register_credentials(hash, address, signature);
            self._register_credential_w_pin(hash_w_pin, address, signature_w_pin);

            let prev_total = self.total_credentials.read();
            self.total_credentials.write(prev_total + 1);

            // TODO: mint $KUDOS here

            self.emit(CredentialsRegistered { address, hash, hash_w_pin })
        }

        fn get_credential(
            self: @ComponentState<TContractState>, address: ContractAddress
        ) -> felt252 {
            self.user_to_credentials.read(address)
        }

        fn get_credential_address(
            self: @ComponentState<TContractState>, hash: felt252
        ) -> ContractAddress {
            self.credentials.read(hash)
        }

        fn get_credential_w_pin(
            self: @ComponentState<TContractState>, address: ContractAddress
        ) -> felt252 {
            self.user_to_credentials_w_pin.read(address)
        }

        fn get_credential_address_w_pin(
            self: @ComponentState<TContractState>, hash: felt252
        ) -> ContractAddress {
            self.credentials_w_pin.read(hash)
        }

        fn get_total_credentials(self: @ComponentState<TContractState>) -> u128 {
            self.total_credentials.read()
        }

        fn is_registered(self: @ComponentState<TContractState>, address: ContractAddress) -> bool {
            self.user_to_credentials.read(address).is_non_zero()
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
                self.credentials.read(hash) == contract_address_const::<0>(),
                CredentialRegistryErrors::CREDENTIAL_REGISTERED
            );

            let account = AccountABIDispatcher { contract_address };
            assert(
                account.is_valid_signature(hash, signature) == starknet::VALIDATED,
                CredentialRegistryErrors::INVALID_SIGNATURE
            );

            self.credentials.write(hash, contract_address);
            self.user_to_credentials.write(contract_address, hash);
        }

        fn _register_credential_w_pin(
            ref self: ComponentState<TContractState>,
            hash: felt252,
            contract_address: ContractAddress,
            signature: Array<felt252>
        ) {
            assert(
                self.credentials_w_pin.read(hash) == contract_address_const::<0>(),
                CredentialRegistryErrors::CREDENTIAL_W_PIN_REGISTERED
            );

            let account = AccountABIDispatcher { contract_address };
            assert(
                account.is_valid_signature(hash, signature) == starknet::VALIDATED,
                CredentialRegistryErrors::INVALID_SIGNATURE
            );

            self.credentials_w_pin.write(hash, contract_address);
            self.user_to_credentials_w_pin.write(contract_address, hash);
        }
    }
}
