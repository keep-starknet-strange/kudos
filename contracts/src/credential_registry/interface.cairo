use starknet::ContractAddress;

#[starknet::interface]
pub trait ICredentialRegistry<TState> {
    fn register_credentials(
        ref self: TState,
        hash: felt252,
        signature: Array<felt252>,
        hash_w_pin: felt252,
        signature_w_pin: Array<felt252>
    );
    fn get_credential(self: @TState, address: ContractAddress) -> felt252;
    fn get_credential_address(self: @TState, hash: felt252) -> ContractAddress;
    fn get_credential_w_pin(self: @TState, address: ContractAddress) -> felt252;
    fn get_credential_address_w_pin(self: @TState, hash: felt252) -> ContractAddress;
    fn get_total_credentials(self: @TState) -> u128;
    fn is_registered(self: @TState, address: ContractAddress) -> bool;
}
