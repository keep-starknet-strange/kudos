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
ACCOUNT_ADDRESS=0x328ced46664355fc4b885ae7011af202313056a7e3d44827fb24c9d3206aaa0
ACCOUNT_PRIVATE_KEY=0x856c96eaa4e7c40c715ccc5dacd8bf6e
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
echo "sncast --accounts-file $ACCOUNT_FILE account add --url $RPC_URL --name $ACCOUNT_NAME --address $ACCOUNT_ADDRESS --private-key $ACCOUNT_PRIVATE_KEY"


sncast --accounts-file $ACCOUNT_FILE account add --url $RPC_URL --class-hash 0x61dac032f228abef9c6626f995015233097ae253a7f72d68552db02f2971b8f --name $ACCOUNT_NAME --address $ACCOUNT_ADDRESS --private-key $ACCOUNT_PRIVATE_KEY --type oz

CONTRACT_DIR="$WORK_DIR/contracts/src"
KUDOS_CLASS_NAME="Kudos"

# Declare the contract

echo "sncast --accounts-file $ACCOUNT_FILE --account $ACCOUNT_NAME --wait --json declare --contract-name $KUDOS_CLASS_NAME --url $RPC_URL --version v3"

KUDOS_CLASS_DECLARE_RESULT=$(cd $CONTRACT_DIR && sncast --accounts-file $ACCOUNT_FILE --account $ACCOUNT_NAME --wait --json declare --contract-name $KUDOS_CLASS_NAME --url $RPC_URL --version v3| tail -n 1)
echo $KUDOS_CLASS_DECLARE_RESULT
KUDOS_CLASS_HASH=$(echo $KUDOS_CLASS_DECLARE_RESULT | jq -r '.class_hash')
echo "Declared class \"$KUDOS_CLASS_NAME\" with hash $KUDOS_CLASS_HASH"

# Define constructor parameters
TOKEN_NAME="KudosToken"
TOKEN_SYMBOL="KUDOS"

# Deploy the contract
CALLDATA=$(echo -n $TOKEN_NAME $TOKEN_SYMBOL)
echo "Deploying contract \"$KUDOS_CLASS_NAME\"..."
KUDOS_CONTRACT_DEPLOY_RESULT=$(sncast --accounts-file $ACCOUNT_FILE --account $ACCOUNT_NAME --wait --json deploy --class-hash $KUDOS_CLASS_HASH --constructor-calldata $CALLDATA | tail -n 1)
KUDOS_CONTRACT_ADDRESS=$(echo $KUDOS_CONTRACT_DEPLOY_RESULT | jq -r '.contract_address')
echo "Deployed contract \"$KUDOS_CLASS_NAME\" with address $KUDOS_CONTRACT_ADDRESS"
