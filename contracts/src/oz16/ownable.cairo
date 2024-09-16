// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.16.0 (access/ownable/ownable.cairo)

/// # Ownable Component
///
/// The Ownable component provides a basic access control mechanism, where
/// there is an account (an owner) that can be granted exclusive access to
/// specific functions.
///
/// The initial owner can be set by using the `initializer` function in
/// construction time. This can later be changed with `transfer_ownership`.
///
/// The component also offers functionality for a two-step ownership
/// transfer where the new owner first has to accept their ownership to
/// finalize the transfer.
#[starknet::component]
pub mod OwnableComponent {
    use core::num::traits::Zero;
    use kudos::oz16::IOwnable;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    pub struct Storage {
        pub Ownable_owner: ContractAddress,
        pub Ownable_pending_owner: ContractAddress
    }

    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event {
        OwnershipTransferred: OwnershipTransferred,
        OwnershipTransferStarted: OwnershipTransferStarted
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct OwnershipTransferred {
        #[key]
        pub previous_owner: ContractAddress,
        #[key]
        pub new_owner: ContractAddress,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct OwnershipTransferStarted {
        #[key]
        pub previous_owner: ContractAddress,
        #[key]
        pub new_owner: ContractAddress,
    }

    pub mod Errors {
        pub const NOT_OWNER: felt252 = 'Caller is not the owner';
        pub const NOT_PENDING_OWNER: felt252 = 'Caller is not the pending owner';
        pub const ZERO_ADDRESS_CALLER: felt252 = 'Caller is the zero address';
        pub const ZERO_ADDRESS_OWNER: felt252 = 'New owner is the zero address';
    }

    #[embeddable_as(OwnableImpl)]
    impl Ownable<
        TContractState, +HasComponent<TContractState>
    > of IOwnable<ComponentState<TContractState>> {
        /// Returns the address of the current owner.
        fn owner(self: @ComponentState<TContractState>) -> ContractAddress {
            self.Ownable_owner.read()
        }

        /// Transfers ownership of the contract to a new address.
        ///
        /// Requirements:
        ///
        /// - `new_owner` is not the zero address.
        /// - The caller is the contract owner.
        ///
        /// Emits an `OwnershipTransferred` event.
        fn transfer_ownership(
            ref self: ComponentState<TContractState>, new_owner: ContractAddress
        ) {
            assert(!new_owner.is_zero(), Errors::ZERO_ADDRESS_OWNER);
            self.assert_only_owner();
            self._transfer_ownership(new_owner);
        }

        /// Leaves the contract without owner. It will not be possible to call `assert_only_owner`
        /// functions anymore. Can only be called by the current owner.
        ///
        /// Requirements:
        ///
        /// - The caller is the contract owner.
        ///
        /// Emits an `OwnershipTransferred` event.
        fn renounce_ownership(ref self: ComponentState<TContractState>) {
            self.assert_only_owner();
            self._transfer_ownership(Zero::zero());
        }
    }

    #[generate_trait]
    pub impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        /// Sets the contract's initial owner.
        ///
        /// This function should be called at construction time.
        fn initializer(ref self: ComponentState<TContractState>, owner: ContractAddress) {
            self._transfer_ownership(owner);
        }

        /// Panics if called by any account other than the owner. Use this
        /// to restrict access to certain functions to the owner.
        fn assert_only_owner(self: @ComponentState<TContractState>) {
            let owner = self.Ownable_owner.read();
            let caller = get_caller_address();
            assert(!caller.is_zero(), Errors::ZERO_ADDRESS_CALLER);
            assert(caller == owner, Errors::NOT_OWNER);
        }

        /// Transfers ownership of the contract to a new address and resets
        /// the pending owner to the zero address.
        ///
        /// Internal function without access restriction.
        ///
        /// Emits an `OwnershipTransferred` event.
        fn _transfer_ownership(
            ref self: ComponentState<TContractState>, new_owner: ContractAddress
        ) {
            self.Ownable_pending_owner.write(Zero::zero());

            let previous_owner: ContractAddress = self.Ownable_owner.read();
            self.Ownable_owner.write(new_owner);
            self
                .emit(
                    OwnershipTransferred { previous_owner: previous_owner, new_owner: new_owner }
                );
        }

        /// Sets a new pending owner.
        ///
        /// Internal function without access restriction.
        ///
        /// Emits an `OwnershipTransferStarted` event.
        fn _propose_owner(ref self: ComponentState<TContractState>, new_owner: ContractAddress) {
            let previous_owner = self.Ownable_owner.read();
            self.Ownable_pending_owner.write(new_owner);
            self
                .emit(
                    OwnershipTransferStarted {
                        previous_owner: previous_owner, new_owner: new_owner
                    }
                );
        }
    }
}
