#[starknet::interface]
pub trait IKudos<T> {
    fn give_kudos(ref self: T) -> ();
}

#[starknet::contract]
pub mod Kudos {
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::token::erc20::{ERC20Component, ERC20HooksEmptyImpl};
    use starknet::ContractAddress;
    use kudos::CredentialRegistry::component::CredentialRegistryComponent;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    component!(path: CredentialRegistryComponent, storage: credential_registry, event: CredentialRegistryEvent);

    // Ownable Mixin
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    // ERC20 Mixin
    #[abi(embed_v0)]
    impl ERC20MixinImpl = ERC20Component::ERC20MixinImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;
    impl CredentialRegistryImpl = CredentialRegistryComponent::CredentialRegistryImpl<ContractState>;
    impl CredentialRegistryInternalImpl = CredentialRegistryComponent::InternalImpl<ContractState>;
    // TODO: Embed the credential registry component

    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        #[substorage(v0)]
        credential_registry: CredentialRegistryComponent::Storage,
    }

    // TODO: define contract errors
    pub mod KudosErrors{
        pub const INSUFFICIENT_FUNDS: felt252 = 'insufficient funds';
        pub const UNREGISTERED_SENDER: felt252 = 'unregistered sender';
        pub const UNREGISTERED_RECIEVER: felt252 = 'unregistered reciever';
    }
    // TODO:
    // - Create `KudosGiven` Event and emit it
    // - Test for even submission
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        KudosGiven: KudosGiven,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        ERC20Event: ERC20Component::Event,
    }

    #[derive(Drop, starknet::Event)]
    struct KudosGiven {
        amount: felt252,
        reciever: ByteArray,
        sender: felt252,
        description: ByteArray,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: ByteArray,
        symbol: ByteArray,
        initial_supply: u256,
        recipient: ContractAddress,
        owner: ContractAddress
    ) {
        self.ownable.initializer(owner);
        self.erc20.initializer(name, symbol);
    }

    #[starknet::interface]
    trait Kudos of IKudos<TContractState> {
        fn give_kudos(ref self: ContractState, new_kudos: KudosGiven) {
            new_kudos.recipient
        }

    }
    // TODO:
// - define and implement IKudos interface including `give_kudos`
// - allow the credential registry to `mint` to a recipient
// - don't expose `transfer` only `transfer_from` and make sure only the credential registry can
// call it - write tests to ensure this
// lets say we have a trait congragulate that accepts a person struct and broadcast and event with that person object

}
