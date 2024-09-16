import json

from starknet_py.net.account.account import Account
from starknet_py.net.full_node_client import FullNodeClient
from starknet_py.net.models import StarknetChainId
from starknet_py.net.signer.stark_curve_signer import KeyPair
from starknet_py.utils.typed_data import TypedData

PRIVATE_KEY = 0xDEADBEEF
PUBLIC_KEY = 0x5eeb3e0d88756352e5b7015667431490b631ea109bb6e31d65bb3bef604c186
ADDRESS = "0xFE"
PIN = 1234

with open('src/tests/utils/sso_credentials_type.json') as f:
    sso_credential_type = json.load(f)

sso_credential_type['message']['name'] = 'Steve Jobs'
sso_credential_type['message']['email'] = 'steve.jobs@apple.com'

client = FullNodeClient(node_url="your.node.url")
account = Account(
    client=client,
    address=ADDRESS,
    key_pair=KeyPair(private_key=PRIVATE_KEY, public_key=PUBLIC_KEY),
    chain=StarknetChainId.SEPOLIA,
)

# SSO Credentials
signature = account.sign_message(typed_data=sso_credential_type)
verify_result = account.verify_message(typed_data=sso_credential_type, signature=signature)
data = TypedData.from_dict(sso_credential_type)
message_hash = data.message_hash(account.address)

print("1) Verify Results: ", verify_result)
print(f"\tMessage Hash: ", hex(message_hash))
print(f"\tSig R: ", hex(signature[0]))
print(f"\tSig S: ", hex(signature[1]))

# SSO Credentials w/ PIN
sso_credential_type['message']['pin'] = PIN
signature = account.sign_message(typed_data=sso_credential_type)
verify_result = account.verify_message(typed_data=sso_credential_type, signature=signature)
data = TypedData.from_dict(sso_credential_type)
message_hash = data.message_hash(account.address)

print(f"\n2) Verify Results: ", verify_result)
print(f"\tMessage Hash: ", hex(message_hash))
print(f"\tSig R: ", hex(signature[0]))
print(f"\tSig S: ", hex(signature[1]))
