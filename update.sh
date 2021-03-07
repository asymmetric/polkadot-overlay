#!/usr/bin/env bash
set -ex

echo "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" > "hash"

# get latest version
curl -s https://api.github.com/repos/paritytech/polkadot/releases/latest | jq -r .tag_name > latest-version

# try (and fail) building, to get SRI hash of cargo deps
(set +e; nix build |& tee out)

# parse output, get hash, save
awk '/got: / {print $2}' out > "hash"

function clean() { rm -rf out; }
trap clean EXIT
