#!/bin/bash
#
# This script deploys the Kudos contract to the StarkNet devnet locally

set -e  # Exit immediately if a command exits with a non-zero status.

# Print the current working directory for debugging
echo "Current working directory: $(pwd)"

RPC_HOST="localhost"
RPC_PORT=5050
RPC_URL=http://$RPC_HOST:$RPC_PORT

echo "${RPC_URL}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WORK_DIR="$(dirname "$SCRIPT_DIR")"

OUTPUT_DIR=$HOME/.kudos
TIMESTAMP=$(date +%s)
LOG_DIR=$OUTPUT_DIR/logs/$TIMESTAMP
TMP_DIR=$OUTPUT_DIR/tmp/$TIMESTAMP

mkdir -p $LOG_DIR
mkdir -p $TMP_DIR

if [[ $1 == "--clean" ]]; then
    rm -rf $OUTPUT_DIR/logs/*
    rm -rf $OUTPUT_DIR/tmp/*
fi

ACCOUNT_NAME=kudos_acct
ACCOUNT_ADDRESS=0x5c4549135a90e405681b6856a47b4269d6c6da78958360592fed61f84bdbf82
ACCOUNT_PRIVATE_KEY=0xce8226b9a31822c1530c153555d4b1ab
ACCOUNT_PROFILE=starknet-devnet
ACCOUNT_FILE=$TMP_DIR/starknet_accounts.json


# # Create the accounts file if it doesn't exist
# if [ ! -f "$ACCOUNT_FILE" ]; then
#     echo "Creating accounts file..."
#     sncast --accounts-file $ACCOUNT_FILE account create --name $ACCOUNT_NAME --type argent --add-profile $ACCOUNT_PROFILE --url $RPC_URL --class-hash 0x29927c8af6bccf3f6fda035981e765a7bdbf18a2dc0d630494f8758aa908e2b
#     echo "accounts file created"
# fi

# # Add account only if it doesn't already exist
# if ! sncast --accounts-file $ACCOUNT_FILE account list | grep -q "$ACCOUNT_NAME"; then
#     sncast --accounts-file $ACCOUNT_FILE account add --name $ACCOUNT_NAME --address $ACCOUNT_ADDRESS --type argent --private-key $ACCOUNT_PRIVATE_KEY --url $RPC_URL --add-profile starknet-devnet
# else
#     echo "Account '$ACCOUNT_NAME' already exists. Skipping addition."
# fi
echo "sncast --url $RPC_URL --accounts-file $ACCOUNT_FILE account add --name $ACCOUNT_NAME --address $ACCOUNT_ADDRESS --private-key $ACCOUNT_PRIVATE_KEY"


sncast --url $RPC_URL --accounts-file $ACCOUNT_FILE account add --name $ACCOUNT_NAME --address $ACCOUNT_ADDRESS --private-key $ACCOUNT_PRIVATE_KEY

CONTRACT_DIR="$WORK_DIR/contracts/src"
KUDOS_CLASS_NAME="Kudos"

# Declare the contract

echo "sncast --url $RPC_URL --accounts-file $ACCOUNT_FILE --account $ACCOUNT_NAME --wait --json declare --contract-name $KUDOS_CLASS_NAME"

KUDOS_CLASS_DECLARE_RESULT=$(cd $CONTRACT_DIR &&  sncast --url $RPC_URL --accounts-file $ACCOUNT_FILE --account $ACCOUNT_NAME --wait --json declare --contract-name $KUDOS_CLASS_NAME | tail -n 1)
echo $KUDOS_CLASS_DECLARE_RESULT
KUDOS_CLASS_HASH=0x07731dced1a83098d7d197cddfa603eba26e0ec86005e37dfa26d96c8571e145
echo "Declared class \"$KUDOS_CLASS_NAME\" with hash $KUDOS_CLASS_HASH"

# Define constructor parameters
TOKEN_NAME=420
TOKEN_SYMBOL=69

# Deploy the contract
CALLDATA=$(echo -n $TOKEN_NAME $TOKEN_SYMBOL)

echo "Deploying contract \"$KUDOS_CLASS_NAME\"..."

echo "sncast --accounts-file $ACCOUNT_FILE --account $ACCOUNT_NAME --wait --json deploy --class-hash $KUDOS_CLASS_HASH --constructor-calldata $CALLDATA"
KUDOS_CONTRACT_DEPLOY_RESULT=$(sncast --accounts-file $ACCOUNT_FILE --account $ACCOUNT_NAME --wait --json deploy --class-hash $KUDOS_CLASS_HASH --constructor-calldata $CALLDATA | tail -n 1)
KUDOS_CONTRACT_ADDRESS=$(echo $KUDOS_CONTRACT_DEPLOY_RESULT | jq -r '.contract_address')
echo "Deployed contract \"$KUDOS_CLASS_NAME\" with address $KUDOS_CONTRACT_ADDRESS"