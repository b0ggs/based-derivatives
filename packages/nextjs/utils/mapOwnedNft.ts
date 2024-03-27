type OwnedNft = {
  contract: {
    address: string;
    name: string;
    symbol: string;
  };
  tokenId: string;
  tokenType: string;
  name: string;
  image: {
    cachedUrl?: string | null;
    originalUrl: string | null;
  };
};

//
// map alchemy data to internal format
//
export function mapOwnedNft(nft: OwnedNft) {
  const {
    contract: { address },
    image: { cachedUrl, originalUrl },
    tokenId,
    tokenType,
    name,
  } = nft;

  return {
    id: `${address}/${tokenId}`,
    address,
    name,
    tokenId,
    tokenType,
    cachedUrl,
    originalUrl,
  };
}
