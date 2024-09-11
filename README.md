# Kudos

An internal application to delegate `kudos` on Starknet by using Google OAuth.

## API

REST API for handling:

- Slack hooks for kudos submission
- Credential registration
- Credential mapping
- Salt management
- Monitoring Starknet for successful tx submission

***Run API***

```bash
cd api && go run api.go
```

## Contracts

Starknet contracts to handle:

- registration of SSO credentials
- erc20 for kudos

***Test Contracts***

```bash
cd contracts && scarb test
```
