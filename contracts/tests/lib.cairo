mod utils;

use kudos::oz16::{IERC20Dispatcher, IERC20DispatcherTrait};

#[test]
fn test_erc20_metadata() {
    let token = IERC20Dispatcher { contract_address: utils::setup() };

    assert_eq!(token.name(), utils::NAME());
    assert_eq!(token.symbol(), utils::SYMBOL());
    assert_eq!(token.decimals(), utils::DECIMALS);
    assert_eq!(token.total_supply(), 0);
}


#[test]
fn test_bad_erc20_metadata() {
    let token = IERC20Dispatcher { contract_address: utils::setup() };

    assert!(token.name() != "WRONG_NAME");
    assert!(token.symbol() != "WRONG_SYMBOL");
    assert!(token.decimals() != 0);
}
