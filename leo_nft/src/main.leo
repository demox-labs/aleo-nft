// The 'leo_nft' program.
program leo_nft.aleo {
    // dummy address, ie the aleo address equivalent of 0: aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc
    struct TokenId {
        data1: u128, // Part 1 of the image data -- i.e., a way to link this nft to image or aws
        data2: u128,
    }

    // base uri ascii bits. Include as many data pieces as necessary to encapsulate the uri. Padded with 0s at the end.
    struct BaseURIBits {
        data1: u128, // Part 1 of the base uri in bits. Bits should be the representation of the hexadecimal bytes for the ASCII text of the URL
        data2: u128,
        data3: u128
    }

    struct SymbolBits {
        data: u128 // The sybmol's ascii text represented in bits, and the u128 value of the bitstring.
    }

    record NFT {
        private owner: address,
        private data: TokenId,
        private edition: scalar, // which edition of the nft this particular one is -- will be 0 for unique NFTs
    }

    // 'https://opensea.io/assets/ethereum/' in ascii bits is
    // 01101000 01110100 01110100 01110000 01110011 00111010 00101111 00101111 01101111 01110000 01100101 01101110 01110011 01100101 01100001 00101110 01101001 01101111 00101111 01100001 01110011 01110011 01100101 01110100 01110011 00101111 01100101 01110100 01101000 01100101 01110010 01100101 01110101 01101101 00101111
    // converted to u128s (with padded 0s for the third u128):
    // 138844379665950632631524487595232157998u128
    // 140146245502826949739664710348378042981u128
    // 156086589137666824969765175673495748608u128

    transition getBaseURIBits() -> BaseURIBits {
        return BaseURIBits {
            data1: 138844379665950632631524487595232157998u128,
            data2: 140146245502826949739664710348378042981u128,
            data3: 156086589137666824969765175673495748608u128
        };
    }

    // ALEO as ascii = 1634493807
    // 1634493807 in bits = 01100001011011000110010101101111
    // padded with 0s on the end becomes 129497940969554608957604870006507569152
    // which is ALEO in ASCII bit represntation padded by 0s
    transition getSymbolBits() -> SymbolBits {
        return SymbolBits {
            data: 129497940969554608957604870006507569152u128
        };
    }

    mapping nft_totals: field => u8;
    mapping nft_owners: field => address;
    
    // Load the data into the mapping
    // Enables someone to mint an NFT with provided image data
    transition initialize(private tokenId: TokenId, private edition: scalar, private amount: u8) {
        // assert self.caller == YOUR_PUBLIC_ADDRESS
        let tokenHash: field = BHP256::hash(tokenId);
        let tokenEditionHash: field = BHP256::commit(tokenHash, edition);
        return then finalize(tokenEditionHash, amount);
    }

    finalize initialize(
        public tokenEditionHash: field,
        public amount: u8
        )
    {
        nft_totals.set(tokenEditionHash, amount);
    }

    // TODO: add edition
    transition mint(private tokenId: TokenId, private edition: scalar, private owner: address) -> NFT {
        let tokenHash: field = BHP256::hash(tokenId);
        let tokenEditionHash: field = BHP256::commit(tokenHash, edition);
        return NFT {
            owner,
            data: tokenId,
            edition
        } then finalize(tokenEditionHash);
    }

    finalize mint(public tokenEditionHash: field) {
        let amount: u8 = nft_totals.get(tokenEditionHash);
        nft_totals.set(tokenEditionHash, amount - 1u8);
    }

    transition transfer_private(
        nft: NFT,
        private receiver: address
    ) -> NFT
    {
        return NFT {
            owner: receiver,
            data: nft.data,
            edition: nft.edition
        };
    }

    transition transfer_public(
        private receiver: address,
        private data: TokenId,
        private edition: scalar
    )
    {
        let tokenHash: field = BHP256::hash(data);
        let tokenEditionHash: field = BHP256::commit(tokenHash, edition);
        return then finalize(receiver, tokenEditionHash);
    }

    finalize transfer_public(
        public receiver: address,
        public tokenEditionHash: field
    )
    {
        assert_eq(self.caller, nft_owners.get(tokenEditionHash));
        nft_owners.set(tokenEditionHash, receiver);
    }

    transition convert_private_to_public(
        nft: NFT
    )
    {
        let tokenHash: field = BHP256::hash(nft.data);
        let tokenEditionHash: field = BHP256::commit(tokenHash, nft.edition);
        return then finalize(nft.owner, tokenEditionHash);
    }

    finalize convert_private_to_public(
        public owner: address,
        public tokenEditionHash: field
    )
    {
        nft_owners.set(tokenEditionHash, owner);
    }

    transition convert_public_to_private(
        private owner: address,
        private data: TokenId,
        private edition: scalar
    ) -> NFT
    {
        let tokenHash: field = BHP256::hash(data);
        let tokenEditionHash: field = BHP256::commit(tokenHash, edition);
        return NFT {
            owner,
            data,
            edition
        } then finalize(owner, tokenEditionHash);
    }

    finalize convert_public_to_private(
        public owner: address,
        public tokenEditionHash: field
    )
    {
        assert_eq(self.caller, nft_owners.get(tokenEditionHash));
        // mapping::remove is not implemented yet, so instead we set the owner to be a dummy address that cannot publicly transfer or convert to private
        nft_owners.set(tokenEditionHash, aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc);
    }
}
