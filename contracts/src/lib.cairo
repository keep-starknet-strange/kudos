mod interface;
pub mod kudos;
pub use interface::{IKudos, IKudosDispatcher, IKudosDispatcherTrait};

pub mod oz16 {
    pub mod erc20;

    mod interfaces;
    pub mod ownable;
    pub use interfaces::{
        IERC20, IERC20Dispatcher, IERC20DispatcherTrait, IOwnable, IOwnableDispatcher,
        IOwnableDispatcherTrait
    };
}

pub mod credential_registry {
    pub mod component;

    mod interface;
    pub use interface::{
        ICredentialRegistry, ICredentialRegistryDispatcher, ICredentialRegistryDispatcherTrait
    };
}
