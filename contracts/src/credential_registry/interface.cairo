use starknet::ContractAddress;

#[starknet::interface]
pub trait ICredentialRegistry<TState> {
    fn register_credentials(ref self: TState, address: ContractAddress, hash: felt252);
    fn get_credential(self: @TState, address: ContractAddress) -> felt252;
    fn get_credential_address(self: @TState, hash: felt252) -> ContractAddress;
    fn get_total_credentials(self: @TState) -> u128;
    fn is_registered(self: @TState, address: ContractAddress) -> bool;
}
