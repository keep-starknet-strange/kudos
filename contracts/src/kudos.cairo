#[starknet::contract]
pub mod Kudos {

    use kudos::IKudos;
    use kudos::credential_registry::{ICredentialRegistry, CredentialRegistryComponent};
    use kudos::oz16::IERC20ReadOnly;
    use kudos::oz16::erc20::{ERC20Component, ERC20HooksEmptyImpl, ERC20Component::InternalTrait};
    use kudos::oz16::ownable::OwnableComponent;
    use kudos::utils::constants::REGISTRATION_AMOUNT;
    use starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map
    };
    use starknet::{ContractAddress, get_caller_address};

    component!(
        path: CredentialRegistryComponent,
        storage: credential_registry,
        event: CredentialRegistryEvent
    );
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl CredentialRegistryImpl =
        CredentialRegistryComponent::CredentialRegistryImpl<ContractState>;

    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        credential_registry: CredentialRegistryComponent::Storage,
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        total_given: Map<ContractAddress, u256>,
        total_received: Map<ContractAddress, u256>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        #[flat]
        CredentialRegistryEvent: CredentialRegistryComponent::Event,
        #[flat]
        ERC20Event: ERC20Component::Event,
        KudosGiven: KudosGiven,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        CredentialRegistryEvent: CredentialRegistryComponent::Event,
    }

    #[derive(Drop, starknet::Event)]
    pub struct KudosGiven {
        #[key]
        pub sender: ContractAddress,
        #[key]
        pub receiver: ContractAddress,
        pub amount: u256,
        pub description: felt252,
    }

    pub mod Errors {
        pub const SENDER_UNREGISTERED: felt252 = 'Sender not registered';
        pub const RECEIVER_UNREGISTERED: felt252 = 'Receiver not registered';
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, name: ByteArray, symbol: ByteArray, owner: ContractAddress
    ) {
        self.erc20.initializer(name, symbol);
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl Kudos of IKudos<ContractState> {
        fn give_kudos(
            ref self: ContractState,
            amount: u256,
            sender_credentials: felt252,
            receiver_credentials: felt252,
            description: felt252,
        ) {
            let sender = get_caller_address();
            assert(self.credential_registry.is_registered(sender), Errors::SENDER_UNREGISTERED);

            let receiver = self.credential_registry.get_credential_address(receiver_credentials);
            assert(self.credential_registry.is_registered(receiver), Errors::RECEIVER_UNREGISTERED);

            self.erc20.transfer(receiver, amount);

            let total_given = self.total_given.entry(sender).read();
            self.total_given.entry(sender).write(total_given + amount);

            let total_received = self.total_given.entry(receiver).read();
            self.total_received.entry(receiver).write(total_received + amount);

            self.emit(KudosGiven { sender, receiver, amount, description });
        }

        fn register_sw_employee(ref self: ContractState, credential_hash: felt252,) {
            let caller = get_caller_address();
            self.register_credentials(caller, credential_hash);
            self.erc20.mint(caller, REGISTRATION_AMOUNT);
        }

        fn get_total_given(self: @ContractState, address: ContractAddress) -> u256 {
            self.total_given.entry(address).read()
        }

        fn get_total_received(self: @ContractState, address: ContractAddress) -> u256 {
            self.total_received.entry(address).read()
        }
    }

    #[abi(embed_v0)]
    impl ERC20ReadOnly of IERC20ReadOnly<ContractState> {
        fn name(self: @ContractState) -> ByteArray {
            self.erc20.name()
        }
        fn symbol(self: @ContractState) -> ByteArray {
            self.erc20.symbol()
        }
        fn decimals(self: @ContractState) -> u8 {
            self.erc20.decimals()
        }
        fn total_supply(self: @ContractState) -> u256 {
            self.erc20.total_supply()
        }
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.erc20.balance_of(account)
        }
        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            self.erc20.allowance(owner, spender)
        }
    }
}
