export default_type="release"
export release_type=${2:-$default_type}

export default_wallet="./wallets/default"
export wallet_file=${1:-$default_wallet}.bin

echo "Using wallet file ${wallet_file} and ${release_type} type"
./build/${release_type}/bin/monero-wallet-cli --wallet-file=${wallet_file}
