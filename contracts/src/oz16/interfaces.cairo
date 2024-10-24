// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.16.0 (token/erc20/interface.cairo)

use starknet::ContractAddress;

#[starknet::interface]
pub trait IERC20<TState> {
    fn name(self: @TState) -> felt252;
    fn symbol(self: @TState) -> felt252;
    fn decimals(self: @TState) -> u8;
    fn total_supply(self: @TState) -> felt252;
    fn balance_of(self: @TState, account: ContractAddress) -> felt252;
    fn transfer(ref self: TState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn approve(ref self: TState, spender: ContractAddress, amount: u256) -> bool;
}


#[starknet::interface]
pub trait IERC20ReadOnly<TState> {
    fn name(self: @TState) -> felt252;
    fn symbol(self: @TState) -> felt252;
    fn decimals(self: @TState) -> u8;
    fn total_supply(self: @TState) -> u256;
    fn balance_of(self: @TState, account: ContractAddress) -> felt252;
}

#[starknet::interface]
pub trait IOwnable<TState> {
    fn owner(self: @TState) -> ContractAddress;
    fn transfer_ownership(ref self: TState, new_owner: ContractAddress);
    fn renounce_ownership(ref self: TState);
}
