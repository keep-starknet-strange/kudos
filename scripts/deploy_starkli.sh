#!/bin/bash

RPC_HOST="localhost"
RPC_PORT=5050
RPC_URL=http://$RPC_HOST:$RPC_PORT

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=$SCRIPT_DIR/../

# Load env variable from `.env` only if they're not already set
if [ -z "$STARKNET_KEYSTORE" ] || [ -z "$STARKNET_ACCOUNT" ]; then
  source $PROJECT_ROOT/.env
fi

# Check if required env variables are set, if not exit
# if [ -z "$STARKNET_KEYSTORE" ]; then
#   echo "Error: STARKNET_KEYSTORE is not set."
#   exit 1
# elif [ -z "$STARKNET_ACCOUNT" ]; then
#   echo "Error: STARKNET_ACCOUNT is not set."
#   exit 1
# fi

# TODO: Host & ...
display_help() {
  echo "Usage: $0 [option...]"
  echo
  echo "   -h, --help                               display help"

  echo
  echo "Example: $0 --host 0x0"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--help") set -- "$@" "-h" ;;
    --*) unrecognized_options+=("$arg") ;;
    *) set -- "$@" "$arg"
  esac
done

# Check if unknown options are passed, if so exit
if [ ! -z "${unrecognized_options[@]}" ]; then
  echo "Error: invalid option(s) passed ${unrecognized_options[*]}" 1>&2
  exit 1
fi

# Parse command line arguments
while getopts ":h" opt; do
  case ${opt} in
    h )
      display_help
      exit 0
      ;;
    \? )
      echo "Invalid Option: -$OPTARG" 1>&2
      display_help
      exit 1
      ;;
    : )
      echo "Invalid Option: -$OPTARG requires an argument" 1>&2
      display_help
      exit 1
      ;;
  esac
done

ONCHAIN_DIR=$PROJECT_ROOT/contracts
USERNAME_STORE_SIERRA_FILE=$ONCHAIN_DIR/target/dev/kudos_Kudos.contract_class.json

# Build the contract
echo "Building the contract..."
cd $ONCHAIN_DIR && scarb build


# Declaring the contract
echo "Declaring the contract..."

USERNAME_STORE_DECLARE_OUTPUT=$(starkli declare --private-key $ACCOUNT_PRIVATE_KEY --watch $USERNAME_STORE_SIERRA_FILE --rpc $RPC_URL --account /Users/zackwilliams/Development/kudos/test.json --casm-hash 0x045e53856dbfc9a9d343a1cc1724d13f5d8bdc9c6a68465485a3e58203b22549 2>&1)
echo starkli declare --private-key $ACCOUNT_PRIVATE_KEY --watch $USERNAME_STORE_SIERRA_FILE --rpc $RPC_URL --account /Users/zackwilliams/Development/kudos/test.json --casm-hash 0x045e53856dbfc9a9d343a1cc1724d13f5d8bdc9c6a68465485a3e58203b22549

USERNAME_STORE_CONTRACT_CLASSHASH=$(echo $USERNAME_STORE_DECLARE_OUTPUT | tail -n 1 | awk '{print $NF}')
echo "Contract class hash: $USERNAME_STORE_CONTRACT_CLASSHASH"

# Deploying the contract
echo "Deploying the contract..."
echo "starkli deploy --network sepolia --keystore $STARKNET_KEYSTORE --account $STARKNET_ACCOUNT --watch $USERNAME_STORE_CONTRACT_CLASSHASH"
starkli deploy --network sepolia --keystore $STARKNET_KEYSTORE --account $STARKNET_ACCOUNT --watch $USERNAME_STORE_CONTRACT_CLASSHASH