mod kudos;

mod credential_registry {
    pub mod component;
    mod interface;

    pub use interface::{
        ICredentialRegistry, ICredentialRegistryDispatcher, ICredentialRegistryDispatcherTrait
    };
}

mod tests {
    #[cfg(test)]
    pub(crate) mod common;
    #[cfg(test)]
    mod test_credential_registry;
    mod mocks {
        pub(crate) mod account_mock;
        pub(crate) mod credential_registry_mock;
    }
    pub(crate) mod utils {
        pub(crate) mod constants;
    }
}
