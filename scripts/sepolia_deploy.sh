#!/bin/bash
# Abort the script on any error
set -euo pipefail

# Check for required commands
command -v starkli >/dev/null 2>&1 || { echo >&2 "starkli not found. Aborting."; exit 1; }
command -v scarb >/dev/null 2>&1 || { echo >&2 "scarb not found. Aborting."; exit 1; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=$SCRIPT_DIR/..
ONCHAIN_DIR=$PROJECT_ROOT/contracts
KUDOS_SIERRA_FILE=$ONCHAIN_DIR/target/dev/kudos_Kudos.contract_class.json

# Ensure tmp directory exists
mkdir -p $TMP_DIR

# Set account file path within the project tmp directory
ACCOUNT_FILE=$TMP_DIR/starknet_accounts.json

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
# Define constructor parameters

# Deploy the contract
CALLDATA=$(echo -n $TOKEN_NAME $TOKEN_SYMBOL)
echo "starkli deploy --rpc $RPC_URL --network sepolia --private-key $ACCOUNT_PRIVATE_KEY --fee-token STRK --account $ACCOUNT_FILE $KUDOS_CONTRACT_CLASSHASH $CALLDATA"

KUDOS_DEPLOY_OUTPUT=$(starkli deploy --rpc $RPC_URL --network sepolia --private-key $ACCOUNT_PRIVATE_KEY --fee-token STRK --account $ACCOUNT_FILE $KUDOS_CONTRACT_CLASSHASH $CALLDATA)
echo $KUDOS_DEPLOY_OUTPUT

KUDOS_CONTRACT_ADDRESS=$(echo "$KUDOS_DEPLOY_OUTPUT" | grep -oP '(?<=Contract address: )\w+')

if [ -z "$KUDOS_CONTRACT_ADDRESS" ]; then
  echo "Error: Failed to retrieve Kudos contract address."
  exit 1
fi

# Export the contract address as an environment variable
export KUDOS_CONTRACT_ADDRESS=$KUDOS_CONTRACT_ADDRESS
echo "Environment variable KUDOS_CONTRACT_ADDRESS set to: $KUDOS_CONTRACT_ADDRESS"
