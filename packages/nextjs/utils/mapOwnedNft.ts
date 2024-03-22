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
    name,
    tokenId,
    tokenType,
    cachedUrl,
    originalUrl,
  };
}
