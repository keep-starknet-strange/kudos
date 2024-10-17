#!/bin/bash
#
# This script deploys the Kudos contract to the StarkNet devnet locally

set -e  # Exit immediately if a command exits with a non-zero status.

# Print the current working directory for debugging
echo "Current working directory: $(pwd)"

RPC_URL=https://starknet-sepolia.public.blastapi.io/rpc/v0_7
echo "${RPC_URL}"

ACCOUNT_NAME=kudos_acct2
ACCOUNT_ADDRESS=0x005f5b3A56446089b4f07f5469a9feCA5Cb7A3e217538eBB1297c34Fd8755c83
ACCOUNT_PRIVATE_KEY=0x06d0f06604e9cbe45aceaa8682c0551ac683fb2a2dd32c5578392b1badbb4921
ACCOUNT_PUBLIC_KEY=Kuc28arUWEWAxJXY8Y4WPCv2UzVGRucKarBVz3DKqse
ACCOUNT_CLASS_HASH=0x036078334509b514626504edc9fb252328d1a240e4e948bef8d0c08dff45927f
ACCOUNT_TYPE=argent
ACCOUNT_FILE=$TMP_DIR/starknet_accounts.json
SCARB_MANIFEST_PATH=/Users/zackwilliams/Development/kudos/contracts/Scarb.toml


echo "import account...."
echo "sncast account import \
    --url $RPC_URL \
    --name $ACCOUNT_NAME \
    --address $ACCOUNT_ADDRESS \
    --private-key $ACCOUNT_PRIVATE_KEY \
    --type $ACCOUNT_TYPE \
    --add-profile $ACCOUNT_NAME"

# Uncomment the following line to actually run the account import
# sncast account import \
#     --url $RPC_URL \
#     --name $ACCOUNT_NAME \
#     --address $ACCOUNT_ADDRESS \
#     --private-key $ACCOUNT_PRIVATE_KEY \
#     --type $ACCOUNT_TYPE \
#     --add-profile $ACCOUNT_NAME

# Define constructor parameters
TOKEN_NAME="0x0 0x324092063603 0x5"
TOKEN_SYMBOL="0x0 0x4932691 0x3"

# Deploy the contract
CALLDATA=$(echo -n $TOKEN_NAME $TOKEN_SYMBOL)

# Declare the contract
sncast --account $ACCOUNT_NAME \
    declare \
    --url $RPC_URL \
    --fee-token strk \
    --contract-name Kudos2 \


echo "sncast --account $ACCOUNT_NAME \
    declare \
    --url $RPC_URL \
    --fee-token strk \
    --contract-name Kudos2 \ "

# Deploy the contract
echo "sncast deploy --class-hash 0x00103e59a45d084bb4d37a32d7a5dcb6a5525b1d8f0511b411e3340ed03c8aae --constructor-calldata $CALLDATA  --fee-token strk --url $RPC_URL"

sncast deploy \
  --class-hash 0x00103e59a45d084bb4d37a32d7a5dcb6a5525b1d8f0511b411e3340ed03c8aae \
  --account $ACCOUNT_NAME \
  --constructor-calldata $CALLDATA \
  --fee-token strk \
  --url $RPC_URL
/Users/zackwilliams/Development/kudos/contracts/Scarb.toml