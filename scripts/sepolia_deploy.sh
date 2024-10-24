#!/bin/bash
# Abort the script on any error
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo $SCRIPT_DIR
PROJECT_ROOT=$SCRIPT_DIR/..
ONCHAIN_DIR=$PROJECT_ROOT/contracts

# Ensure tmp directory exists
mkdir -p $ONCHAIN_DIR/target/tmp

# Check for required commands
command -v starkli >/dev/null 2>&1 || { echo >&2 "starkli not found. Aborting."; exit 1; }
command -v scarb >/dev/null 2>&1 || { echo >&2 "scarb not found. Aborting."; exit 1; }

# Configurable environment variables
source $PROJECT_ROOT/.env
: "${RPC_URL:=https://starknet-sepolia.public.blastapi.io/rpc/v0_7}"
: "${ACCOUNT_PRIVATE_KEY:=ACCOUNT_PRIVATE_KEY is not set}"
: "${ACCOUNT_ADDRESS:?ACCOUNT_ADDRESS is not set}"
: "${TOKEN_NAME:?TOKEN_NAME is not set}"
: "${TOKEN_SYMBOL:?TOKEN_SYMBOL is not set}"
KUDOS_SIERRA_FILE=$ONCHAIN_DIR/target/dev/kudos_Kudos.contract_class.json
ACCOUNT_FILE=$ONCHAIN_DIR/target/tmp/starknet_accounts.json

starkli account fetch $ACCOUNT_ADDRESS \
      --rpc $RPC_URL \
      --network sepolia --force \
      --output $ACCOUNT_FILE \

echo "starkli account fetch $ACCOUNT_ADDRESS \
      --rpc $RPC_URL \
      --network sepolia --force \
      --output $ACCOUNT_FILE \
"

# Build the contract
echo "Building the contract..."
cd $ONCHAIN_DIR && scarb build

# Declaring the contract
echo "Declaring the contract..."

# Fetch account data and save it to a file
KUDOS_DECLARE_OUTPUT=$(starkli declare --private-key $ACCOUNT_PRIVATE_KEY --watch $KUDOS_SIERRA_FILE --rpc $RPC_URL --account $ACCOUNT_FILE)
echo "starkli declare --private-key $ACCOUNT_PRIVATE_KEY --watch $KUDOS_SIERRA_FILE --rpc $RPC_URL --account $ACCOUNT_FILE"
KUDOS_CONTRACT_CLASSHASH=$(echo $KUDOS_DECLARE_OUTPUT)
echo "Contract class hash: $KUDOS_CONTRACT_CLASSHASH"

# Deploying the contract
echo "Deploying the contract..."

# Deploy the contract
CALLDATA=$(echo -n $TOKEN_NAME $TOKEN_SYMBOL)
echo "CALLDATA  $CALLDATA"
echo "starkli deploy --rpc $RPC_URL --network sepolia --private-key $ACCOUNT_PRIVATE_KEY --fee-token STRK --account $ACCOUNT_FILE $KUDOS_CONTRACT_CLASSHASH $CALLDATA"

KUDOS_DEPLOY_OUTPUT=$(starkli deploy --rpc $RPC_URL --network sepolia --private-key $ACCOUNT_PRIVATE_KEY --fee-token STRK --account $ACCOUNT_FILE $KUDOS_CONTRACT_CLASSHASH $CALLDATA)
echo $KUDOS_DEPLOY_OUTPUT

# Extract the contract address using grep
KUDOS_CONTRACT_ADDRESS=$(echo "$KUDOS_DEPLOY_OUTPUT" | grep -oE '0x[0-9a-fA-F]{64}')

echo "Kudos contract address: $KUDOS_CONTRACT_ADDRESS"
if [ -z "$KUDOS_CONTRACT_ADDRESS" ]; then
  echo "Error: Failed to retrieve Kudos contract address."
  exit 1
fi
