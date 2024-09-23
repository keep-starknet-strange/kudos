ACCOUNT_ADDRESS=0x5c4549135a90e405681b6856a47b4269d6c6da78958360592fed61f84bdbf82

echo "sncast invoke --contract-address $ACCOUNT_ADDRESS --function register_sw_employee --calldata "DEADBEEF""
sncast invoke --contract-address $ACCOUNT_ADDRESS --function register_sw_employee --calldata dead

echo "sncast invoke --contract-address $ACCOUNT_ADDRESS --function register_sw_employee --calldata "BEEF""
sncast invoke --contract-address $ACCOUNT_ADDRESS --function register_sw_employee --calldata beef
