// The 'leo_nft' program.
program leo_nft.aleo {
    struct ArweaveData {
        data1: u128, // Part 1 of the Arweave Transaction ID, a SHA-256 signature
        data2: u128, // Part 2 of the Arweave Transaction ID, a SHA-256 signature
    }

    record NFT {
        private owner: address,
        private symbol: u128, // The ASCII symbol encoded as a u128 -> 16 bytes, 16 ascii characters
        private data: ArweaveData
    }

    mapping nft_totals: field => u8;
    
    transition initialize(private arweaveData: ArweaveData, private amount: u8) {
        // assert self.caller == initializer set here
        let arweaveHash: field = BHP256::hash(arweaveData);
        return then finalize(arweaveHash, amount);
    }

    finalize initialize(
        public arweaveHash: field,
        public amount: u8
        )
    {
        Mapping::set(nft_totals, arweaveHash, amount);
    }
}
