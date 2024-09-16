#[starknet::interface]
pub trait IKudos<TState> {
    fn give_kudos(
        ref self: TState,
        amount: felt252,
        sender_credentials: felt252,
        receiver_credentials: felt252,
        description: felt252,
    );
}
