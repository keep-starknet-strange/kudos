# Kudos

[![Check Workflow Status](https://github.com/keep-starknet-strange/kudos/actions/workflows/check.yml/badge.svg)](https://github.com/keep-starknet-strange/kudos/actions/workflows/check.yml)

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

## Slack App

You'll know an app is the development version if the
name has the string `(local)` appended.

```bash
# Run app locally
$ slack run

Connected, awaiting events
```
