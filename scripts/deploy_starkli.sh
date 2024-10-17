#!/bin/bash

ACCOUNT_NAME=kudos_acct
ACCOUNT_ADDRESS=0x005f5b3A56446089b4f07f5469a9feCA5Cb7A3e217538eBB1297c34Fd8755c83
ACCOUNT_PRIVATE_KEY=0x06d0f06604e9cbe45aceaa8682c0551ac683fb2a2dd32c5578392b1badbb4921
ACCOUNT_PUBLIC_KEY=Kuc28arUWEWAxJXY8Y4WPCv2UzVGRucKarBVz3DKqse
ACCOUNT_CLASS_HASH=0x036078334509b514626504edc9fb252328d1a240e4e948bef8d0c08dff45927f
ACCOUNT_PROFILE=argent
ACCOUNT_FILE=/Users/zackwilliams/.kudos/tmp/starknet_accounts.json
RPC_URL=https://starknet-sepolia.public.blastapi.io/rpc/v0_7

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

KUDOS_DECLARE_OUTPUT=$(starkli declare --private-key $ACCOUNT_PRIVATE_KEY --watch $KUDOS_SIERRA_FILE --rpc $RPC_URL --account $ACCOUNT_FILE)
echo "starkli declare --private-key $ACCOUNT_PRIVATE_KEY --watch $KUDOS_SIERRA_FILE --rpc $RPC_URL --account $ACCOUNT_FILE"
KUDOS_CONTRACT_CLASSHASH=$(echo $KUDOS_DECLARE_OUTPUT)
echo "Contract class hash: $KUDOS_CONTRACT_CLASSHASH"

# Deploying the contract
echo "Deploying the contract..."
# Define constructor parameters
TOKEN_NAME="0x0 0x324092063603 0x5"
TOKEN_SYMBOL="0x0 0x4932691 0x3"

# Deploy the contract
CALLDATA=$(echo -n $TOKEN_NAME $TOKEN_SYMBOL)
echo "starkli deploy --rpc $RPC_URL --network sepolia --private-key $ACCOUNT_PRIVATE_KEY --fee-token STRK --account $ACCOUNT_FILE $KUDOS_CONTRACT_CLASSHASH $CALLDATA"

KUDOS_DEPLOY_OUTPUT=$(starkli deploy --rpc $RPC_URL --network sepolia --private-key $ACCOUNT_PRIVATE_KEY --fee-token STRK --account $ACCOUNT_FILE $KUDOS_CONTRACT_CLASSHASH $CALLDATA)
echo $KUDOS_DEPLOY_OUTPUT