// The 'leo_nft' program.
program leo_nft.aleo {
    // dummy address: aleo1zyqdn0yxmdn2e606x32y3m5f0mp8m05h7qslyl68678e7c0nqcysxx0v83
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
    mapping nft_owners: field => address;
    
    // Load the data into the mapping
    // Enables someone to mint an NFT with provided Arweave transaction id
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

    transition mint(private arweaveData: ArweaveData, private owner: address) -> NFT {
        let arweaveHash: field = BHP256::hash(arweaveData);
        return NFT {
            owner,
            symbol: 86795840032555669230657698889553936384u128, // 86795840032555669230657698889553936384 -> "ALEO" padded by 0s
            data: arweaveData
        } then finalize(arweaveHash);
    }

    finalize mint(public arweaveHash: field) {
        let amount: u8 = Mapping::get_or_init(nft_totals, arweaveHash, 0u8);
        Mapping::set(nft_totals, arweaveHash, amount - 1u8);
    }

    transition transfer_private(
        nft: NFT,
        private receiver: address
    ) -> NFT
    {
        return NFT {
            owner: receiver,
            symbol: nft.symbol,
            data: nft.data
        };
    }

    transition transfer_public(
        private receiver: address,
        private data: ArweaveData
    )
    {
        let arweaveHash: field = BHP256::hash(data);
        return then finalize(receiver, arweaveHash);
    }

    finalize transfer_public(
        public receiver: address,
        public arweaveHash: field
    )
    {
        assert_eq(self.caller, Mapping::get(nft_owners, arweaveHash));
        Mapping::set(nft_owners, arweaveHash, receiver);
    }

    transition convert_private_to_public(
        nft: NFT
    )
    {
        let arweaveHash: field = BHP256::hash(nft.data);
        return then finalize(nft.owner, arweaveHash);
    }

    finalize convert_private_to_public(
        public owner: address,
        public arweaveHash: field
    )
    {
        Mapping::set(nft_owners, arweaveHash, owner);
    }

    transition convert_public_to_private(
        private owner: address,
        private data: ArweaveData
    ) -> NFT
    {
        let arweaveHash: field = BHP256::hash(data);
        return NFT {
            owner,
            symbol: 86795840032555669230657698889553936384u128,
            data
        } then finalize(owner, arweaveHash);
    }

    finalize convert_public_to_private(
        public owner: address,
        public arweaveHash: field
    )
    {
        assert_eq(self.caller, Mapping::get(nft_owners, arweaveHash));
        Mapping::set(nft_owners, arweaveHash, aleo1zyqdn0yxmdn2e606x32y3m5f0mp8m05h7qslyl68678e7c0nqcysxx0v83);
    }
}
