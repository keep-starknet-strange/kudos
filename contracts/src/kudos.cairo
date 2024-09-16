#[starknet::contract]
pub mod Kudos {
    use kudos::IKudos;
    use kudos::credential_registry::{ICredentialRegistry, CredentialRegistryComponent};
    use kudos::oz16::erc20::{ERC20Component, ERC20HooksEmptyImpl, ERC20Component::InternalTrait};
    use kudos::oz16::ownable::OwnableComponent;
    use kudos::utils::constants::REGISTRATION_AMOUNT;
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

    #[abi(embed_v0)]
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
    }

    // TODO: define contract errors

    // TODO:
    // - Create `KudosGiven` Event and emit it
    // - Test for even submission
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        #[flat]
        CredentialRegistryEvent: CredentialRegistryComponent::Event,
        #[flat]
        ERC20Event: ERC20Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, name: ByteArray, symbol: ByteArray, owner: ContractAddress
    ) {
        self.erc20.initializer(name, symbol);
        self.ownable.initializer(owner);
    }
    // TODO:
    // - define and implement IKudos interface including `give_kudos`
    // - allow the credential registry to `mint` to a recipient
    // - don't expose `transfer` only `transfer_from` and make sure only the credential registry can
    // call it - write tests to ensure this
    #[abi(embed_v0)]
    impl Kudos of IKudos<ContractState> {
        fn give_kudos(
            ref self: ContractState,
            amount: felt252,
            sender_credentials: felt252,
            receiver_credentials: felt252,
            description: felt252,
        ) {}

        fn register_sw_employee(ref self: ContractState, credential_hash: felt252,) {
            let caller = get_caller_address();
            self.register_credentials(caller, credential_hash);
            self.erc20.mint(caller, REGISTRATION_AMOUNT);
        }
    }
}
