# Kudos

[![Check Workflow Status](https://github.com/keep-starknet-strange/kudos/actions/workflows/check.yml/badge.svg)](https://github.com/keep-starknet-strange/kudos/actions/workflows/check.yml)
[![codecov](https://codecov.io/gh/keep-starknet-strange/kudos/blob/branch/main/graph/badge.svg)](https://codecov.io/gh/keep-starknet-strange/kudos)

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
***Code Coverage***

Check out the [installation](https://github.com/software-mansion/cairo-coverage#installation) section of `cairo-coverage` for the detailed installation instructions.

```bash
cd contracts && snforge test --coverage
```

***Deploy Contract to Testnet***

* define values in env.example