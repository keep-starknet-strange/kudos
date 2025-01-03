#[starknet::contract]
pub mod Kudos {
    use kudos::IKudos;
    use kudos::credential_registry::{ICredentialRegistry, CredentialRegistryComponent};
    use kudos::oz16::IERC20ReadOnly;
    use kudos::oz16::erc20::{ERC20Component, ERC20HooksEmptyImpl, ERC20Component::InternalTrait};
    use kudos::utils::constants::{
        REGISTRATION_AMOUNT, ONE, SECONDS_IN_30_DAYS, MONTHLT_MINT_AMOUNT
    };
    use starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map
    };
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};

    component!(
        path: CredentialRegistryComponent,
        storage: credential_registry,
        event: CredentialRegistryEvent
    );
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl CredentialRegistryImpl =
        CredentialRegistryComponent::CredentialRegistryImpl<ContractState>;

    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        credential_registry: CredentialRegistryComponent::Storage,
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        total_given: Map<ContractAddress, u256>,
        total_received: Map<ContractAddress, u256>,
        minted_balance: Map<ContractAddress, u256>,
        last_mint_timestamp: Map<ContractAddress, u64>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        #[flat]
        CredentialRegistryEvent: CredentialRegistryComponent::Event,
        #[flat]
        ERC20Event: ERC20Component::Event,
        KudosGiven: KudosGiven,
    }

    #[derive(Drop, starknet::Event)]
    pub struct KudosGiven {
        #[key]
        pub sender: ContractAddress,
        #[key]
        pub receiver: ContractAddress,
        pub description: felt252,
    }

    pub mod Errors {
        pub const SENDER_UNREGISTERED: felt252 = 'Sender not registered';
        pub const RECEIVER_UNREGISTERED: felt252 = 'Receiver not registered';
        pub const MINTER_UNREGISTERED: felt252 = 'Minter not registered';
        pub const MINTED_BALANCE_ZERO: felt252 = 'Minted balance is zero';
        pub const MINTED_BALANCE_IS_FULL: felt252 = 'Minted balance is full';
        pub const MINTED_AMOUNT_IS_ZERO: felt252 = 'Minted amount is zero';
        pub const MINTED_LESS_THAN_30_DAYS_AGO: felt252 = 'Minted less than 30 days ago';
    }

    #[constructor]
    fn constructor(ref self: ContractState, name: ByteArray, symbol: ByteArray) {
        self.erc20.initializer(name, symbol);
    }

    #[abi(embed_v0)]
    impl Kudos of IKudos<ContractState> {
        fn give_kudos(
            ref self: ContractState,
            sender_credentials: felt252,
            receiver_credentials: felt252,
            description: felt252,
        ) {
            let sender = get_caller_address();
            assert(self.credential_registry.is_registered(sender), Errors::SENDER_UNREGISTERED);

            let receiver = self.credential_registry.get_credential_address(receiver_credentials);
            assert(self.credential_registry.is_registered(receiver), Errors::RECEIVER_UNREGISTERED);

            let minted_balance = self.minted_balance.entry(sender).read();
            assert(minted_balance > 0, Errors::MINTED_BALANCE_ZERO);

            self.erc20.transfer(receiver, ONE);

            let total_given = self.total_given.entry(sender).read();
            self.total_given.entry(sender).write(total_given + ONE);

            let total_received = self.total_given.entry(receiver).read();
            self.total_received.entry(receiver).write(total_received + ONE);

            self.minted_balance.entry(sender).write(minted_balance - ONE);

            self.emit(KudosGiven { sender, receiver, description });
        }

        fn monthly_mint(ref self: ContractState) {
            let address = get_caller_address();
            assert(self.credential_registry.is_registered(address), Errors::MINTER_UNREGISTERED);

            let last_mint_timestamp = self.last_mint_timestamp.entry(address).read();
            let current_timestamp = get_block_timestamp();
            let time_since_last_mint = current_timestamp - last_mint_timestamp;
            assert(time_since_last_mint > SECONDS_IN_30_DAYS, Errors::MINTED_LESS_THAN_30_DAYS_AGO);

            let amount_to_mint = MONTHLT_MINT_AMOUNT - self.minted_balance.entry(address).read();
            assert(amount_to_mint > 0, Errors::MINTED_BALANCE_IS_FULL);

            self.erc20.mint(address, amount_to_mint);
            self.minted_balance.entry(address).write(MONTHLT_MINT_AMOUNT);
            self.last_mint_timestamp.entry(address).write(current_timestamp);
        }

        fn register_sw_employee(ref self: ContractState, credential_hash: felt252,) {
            let caller = get_caller_address();
            self.register_credentials(caller, credential_hash);
            let current_timestamp = get_block_timestamp();
            self.erc20.mint(caller, REGISTRATION_AMOUNT);
            self.minted_balance.entry(caller).write(REGISTRATION_AMOUNT);
            self.last_mint_timestamp.entry(caller).write(current_timestamp);
        }

        fn get_total_given(self: @ContractState, address: ContractAddress) -> u256 {
            self.total_given.entry(address).read()
        }

        fn get_total_received(self: @ContractState, address: ContractAddress) -> u256 {
            self.total_received.entry(address).read()
        }

        fn get_minted_balance(self: @ContractState, address: ContractAddress) -> u256 {
            self.minted_balance.entry(address).read()
        }

        fn get_last_mint_timestamp(self: @ContractState, address: ContractAddress) -> u64 {
            self.last_mint_timestamp.entry(address).read()
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
    }
}
