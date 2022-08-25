// The 'nft.aleo' program.
program nft.aleo;

record nft:
    owner as address.private;
    gates as u64.private;
    rank as u8.private;
    remaining as u8.private;
    data1 as u128.private;
    data2 as u128.private;

interface nft_data:
    value1 as u128;
    value2 as u128;

mapping nft_totals:
     // The token owner.
    key data as field.public;
    // The token amount.
    value amount as u8.public;

//function premint:

function mint:
    input r0 as nft.record;
    input r1 as address.private;
    input r2 as u128.private;
    input r3 as u128.private;
    
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
