mod interface;
mod kudos;
pub use interface::{IKudos, IKudosDispatcher, IKudosDispatcherTrait};
pub use kudos::Kudos;

pub mod credential_registry {
    mod component;

    mod interface;
    pub use component::CredentialRegistryComponent;
    pub use interface::{
        ICredentialRegistry, ICredentialRegistryDispatcher, ICredentialRegistryDispatcherTrait
    };

    #[cfg(test)]
    mod tests {
        mod mock_credential_registry;
        mod test_credential_registry;
    }
}

pub mod oz16 {
    pub mod erc20;

    mod interfaces;
    pub mod ownable;
    pub use interfaces::{
        IERC20, IERC20Dispatcher, IERC20DispatcherTrait, IOwnable, IOwnableDispatcher,
        IOwnableDispatcherTrait
    };
}

pub mod utils {
    pub mod constants;
}
