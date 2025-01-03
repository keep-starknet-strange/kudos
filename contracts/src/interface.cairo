use starknet::ContractAddress;

#[starknet::interface]
pub trait IKudos<TState> {
    fn give_kudos(
        ref self: TState,
        sender_credentials: felt252,
        receiver_credentials: felt252,
        description: felt252,
    );
    fn register_sw_employee(ref self: TState, credential_hash: felt252,);
    fn get_total_given(self: @TState, address: ContractAddress) -> u256;
    fn get_total_received(self: @TState, address: ContractAddress) -> u256;
    fn monthly_mint(ref self: TState, address: ContractAddress);
    fn get_minted_balance(self: @TState, address: ContractAddress) -> u256;
    fn get_last_mint_timestamp(self: @TState, address: ContractAddress) -> u64;
}
