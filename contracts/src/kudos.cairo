#[starknet::contract]
pub mod Kudos {
    // use kudos::token::{IERC20, IERC20Metadata};
    use kudos::IKudos;
    use kudos::oz16::erc20::{ERC20Component, ERC20HooksEmptyImpl};
    use kudos::oz16::ownable::OwnableComponent;
    use starknet::ContractAddress;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    // TODO: Embed the credential registry component

    #[storage]
    struct Storage {
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
    enum Event {
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
    }
}
