// The 'nft.aleo' program.
program nft.aleo;

/**
* Each NFT is stored as a record onchain.
* The total number of mintable NFTs is determined by the number of initialized nfts
* The actual image is stored on Arweave and retrievable through the transaction ID which is a SHA-256 signature
**/
record nft:
    owner as address.private;
    gates as u64.private;
    symbol as u128.private; // The ASCII symbol encoded as a u128 -> 16 bytes, 16 ascii characters
    data1 as u128.private; // Part 1 of the Arweave Transaction ID, a SHA-256 signature
    data2 as u128.private; // Part 2 of the Arweave Transaction ID, a SHA-256 signature

// An interface representing the SHA-256 signature from the Arweave transaction id
interface nft_data:
    value1 as u128; // Part 1 of the Arweave Transaction ID, a SHA-256 signature
    value2 as u128; // Part 2 of the Arweave Transaction ID, a SHA-256 signature

mapping nft_totals:
     // The data hashed into a field from the nft_data interface.
    key data as field.public;
    // The amount of image left to be minted. Should probably only be 1 unless multiple editions are allowed
    value amount as u8.public;

mapping nft_owner_data1:
    key address as address.public;
    value amount as u8.public;

mapping nft_owner_data2:
    key address as address.public;
    value amount as u8.public;

// Load the data into the mapping
// Enables someone to mint an NFT with provided Arweave transaction id
function initialize:
    input r0 as u128.private;
    input r1 as u128.private;

    // Safety check on owner
    assert.eq self.caller aleo1y9mnptjc23wxtnr6gnjac0efu4fq859dsjk8mmryj3rg0feq0qzs8awmhn;

    cast r0 r1 into r2 as nft_data;
    hash.bhp256 r2 into r3;

    finalize r3;

finalize initialize:
    input r0 as field.public;

    increment nft_totals[r0] by 1u8;

// Anyone with an NFT can mint an NFT with rank - 1 and selecting the new owner
// Minting an NFT lowers the amount_remaining that can be minted by 1
function mint:
    input r0 as address.private;
    input r1 as u128.private;
    input r2 as u128.private;
    
    cast r0 0u64 86795840032555669230657698889553936384u128 r1 r2 into r3 as nft.record; // 86795840032555669230657698889553936384 -> "ALEO" padded by 0s

    cast r1 r2 into r4 as nft_data;
    hash.bhp256 r4 into r5;

    output r3 as nft.record;

    finalize r5;

finalize mint:
    input r0 as field.public;

    decrement nft_totals[r0] by 1u8;

// Privately transfer the NFT to a new owner
// Does not change the NFT in any way.
function transfer_private:
    input r0 as nft.record;
    input r1 as address.private;

    assert.eq r0.owner self.caller; // not sure if this check is done automatically

    cast r1 r0.gates 86795840032555669230657698889553936384u128 r0.data1 r0.data2 into r2 as nft.record;

    output r2 as nft.record;


function convert_private_to_public:
    input r0 as nft.record;

    assert.eq r0.owner self.caller; // not sure if this check is done automatically

    finalize r0.owner r0.data1 r0.data2;

finalize convert_private_to_public:
    input r0 as address.public;
    input r1 as u128.public;
    input r2 as u128.public;

    increment nft_owner_data1[r0] by r1;
    increment nft_owner_data2[r0] by r2;

function convert_public_to_private:
    input r0 as u128.private;
    input r1 as u128.private;

    cast self.caller 0u64 86795840032555669230657698889553936384u128 r0 r1 into r2 as nft.record;

    output r2 as nft.record;

    finalize self.caller r0 r1;

// This isn't safe until we make sure we can assert that the old values are completely zeroed out
// Something like "assert.eq nft_owner_data1[r0] r1"
finalize convert_public_to_private;
    input r0 as address.public;
    input r1 as u128.public;
    input r2 as u128.public;

    decrement nft_owner_data1[r0] by r1;
    decrement nft_owner_data2[r0] by r2;

function transfer_public:
    input r0 as address.private;
    input r1 as u128.private;
    input r2 as u128.private;

    finalize self.caller r0 r1 r2

// This isn't safe until we make sure we can assert that the old values are completely zeroed out
// Something like "assert.eq nft_owner_data1[r0] r1"
finalize transfer_public:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u128.public;
    input r3 as u128.public;

    decrement nft_owner_data1[r0] by r2;
    decrement nft_owner_data2[r0] by r3;
    increment nft_owner_data1[r1] by r2;
    increment nft_owner_data2[r1] by r3;