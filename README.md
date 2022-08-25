# aleo-nft

We're creating the first NFT collection on Aleo on Testnet3 as soon as it becomes available.
Follow us on Twitter to learn about when we mint: https://twitter.com/demoxlabs

We wanted to create an NFT that inspires community participation.
Instead of a global mint, only accounts with an NFT can mint a new NFT and send it to someone new.

Each NFT is stored as a record with an Arweave transaction id that points to the actual image data.

Each NFT tracks its rank (how many parent NFTs it has) and how many NFTs can be further minted.
Right now, rank is set for 6 and mintable NFTs per NFT is 3. This limits the total supply to 3^6 => 729.

## Build Guide

To compile this Aleo program, run:
```bash
cd ./nft
aleo build
```

## Example Usage

### Initialize
The initialize function is used to load Arweave transaction ids into the global state.
This global state acts to limit the number of total number of NFTs as well. If an Arweave transaction id, hasn't been upload, an NFT won't be able to mint it.

`aleo run initialize 3u128 7u128`
`aleo run initialize 13u128 1u128`

### Premint
Since our unique minting mechanism requires an NFT to mint one, this method provides a way for a specific address to mint the root of the NFT minting tree.

`aleo run premint aleo1y9mnptjc23wxtnr6gnjac0efu4fq859dsjk8mmryj3rg0feq0qzs8awmhn 3u128 7u128`

`>>>`

```
{
  owner: aleo1y9mnptjc23wxtnr6gnjac0efu4fq859dsjk8mmryj3rg0feq0qzs8awmhn.private,
  gates: 0u64.private,
  rank: 6u8.private,
  remaining: 3u8.private,
  data1: 3u128.private,
  data2: 7u128.private,
  _nonce: 2546588301349859963165576196445211638510724205660741519656114746669343010757group.public
}
```

### Mint

Mint a new NFT to a new owner

```
aleo run mint '{
  owner: aleo1y9mnptjc23wxtnr6gnjac0efu4fq859dsjk8mmryj3rg0feq0qzs8awmhn.private,
  gates: 0u64.private,
  rank: 6u8.private,
  remaining: 3u8.private,
  data1: 3u128.private,
  data2: 7u128.private,
  _nonce: 2546588301349859963165576196445211638510724205660741519656114746669343010757group.public
}' aleo17xy970uqxfjekll5zw6mtqz90pmsewe3u3a2lf4tg8mc0wpt3sqq3psxyt 13u128 1u128
```


`>>>`

```
{
  owner: aleo1y9mnptjc23wxtnr6gnjac0efu4fq859dsjk8mmryj3rg0feq0qzs8awmhn.private,
  gates: 0u64.private,
  rank: 6u8.private,
  remaining: 2u8.private,
  data1: 3u128.private,
  data2: 7u128.private,
  _nonce: 1700985124319758542136781077875397883667997810952789373247295650239946998473group.public
}
{
  owner: aleo17xy970uqxfjekll5zw6mtqz90pmsewe3u3a2lf4tg8mc0wpt3sqq3psxyt.private,
  gates: 0u64.private,
  rank: 5u8.private,
  remaining: 3u8.private,
  data1: 13u128.private,
  data2: 1u128.private,
  _nonce: 8370187179893012466718275891148875112398415988754876165323561523459467494290group.public
}
```

### Transfer

Transfer an NFT to a new owner

```
aleo run transfer '{
  owner: aleo1y9mnptjc23wxtnr6gnjac0efu4fq859dsjk8mmryj3rg0feq0qzs8awmhn.private,
  gates: 0u64.private,
  rank: 6u8.private,
  remaining: 2u8.private,
  data1: 3u128.private,
  data2: 7u128.private,
  _nonce: 1700985124319758542136781077875397883667997810952789373247295650239946998473group.public
}' aleo17xy970uqxfjekll5zw6mtqz90pmsewe3u3a2lf4tg8mc0wpt3sqq3psxyt
```

`>>>`

```
{
  owner: aleo17xy970uqxfjekll5zw6mtqz90pmsewe3u3a2lf4tg8mc0wpt3sqq3psxyt.private,
  gates: 0u64.private,
  rank: 6u8.private,
  remaining: 2u8.private,
  data1: 3u128.private,
  data2: 7u128.private,
  _nonce: 6739890397851202927943691151822460561939708406123799701803330096383355445195group.public
}
```