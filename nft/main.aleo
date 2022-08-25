// The 'nft.aleo' program.
program nft.aleo;

/**
* Each NFT is stored as a record onchain.
* The total number of mintable NFTs is determined by remaining^rank: 3^6 => 729 max potential total supply (assuming one root)
* The actual image is stored on Arweave and retrievable through the transaction ID which is a SHA-256 signature
**/
record nft:
    owner as address.private;
    gates as u64.private;
    rank as u8.private; // Decreases on every mint, only so many ranks are allowed limiting total supply
    remaining as u8.private; // How many more NFTs this owner can mint
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

// Only the initial owner of the collection can mint the root level NFTs
function premint:
    input r0 as address.private;
    input r1 as u128.private;
    input r2 as u128.private;

    // Safety check on owner
    assert.eq self.caller aleo1y9mnptjc23wxtnr6gnjac0efu4fq859dsjk8mmryj3rg0feq0qzs8awmhn;

    // The 6u8 (rank) determines the max rank, each regular mint decreases the rank by 1
    // underflow of the rank prevents minting more.
    // The 3u8 (remaining) determines the number of NFTs each owner can mint
    // underflow of the remaining prevents minting more.
    cast r0 0u64 6u8 3u8 r1 r2 into r3 as nft.record;
    
    cast r1 r2 into r4 as nft_data;
    hash.bhp256 r4 into r5;

    output r3 as nft.record;
    finalize r5;

finalize premint:
    input r0 as field.public;

    decrement nft_totals[r0] by 1u8;

// Anyone with an NFT can mint an NFT with rank - 1 and selecting the new owner
// Minting an NFT lowers the amount_remaining that can be minted by 1
function mint:
    input r0 as nft.record;
    input r1 as address.private;
    input r2 as u128.private;
    input r3 as u128.private;

    assert.neq r0.owner r1; // Make it slightly tougher for the same person to mint a bunch of NFTs to themself
    
    sub r0.remaining 1u8 into r4;
    cast r0.owner r0.gates r0.rank r4 r0.data1 r0.data2 into r5 as nft.record;

    sub r0.rank 1u8 into r6;
    cast r1 0u64 r6 3u8 r2 r3 into r7 as nft.record;

    cast r2 r3 into r8 as nft_data;
    hash.bhp256 r8 into r9;

    output r5 as nft.record;
    output r7 as nft.record;

    finalize r9;

finalize mint:
    input r0 as field.public;

    decrement nft_totals[r0] by 1u8;

// Privately transfer the NFT to a new owner
// Does not change the NFT in any way.
function transfer:
    input r0 as nft.record;
    input r1 as address.private;

    assert.eq r0.owner self.caller; // not sure if this check is done automatically

    cast r1 r0.gates r0.rank r0.remaining r0.data1 r0.data2 into r2 as nft.record;

    output r2 as nft.record;