import { NFTStorage } from "nft.storage";

const API_KEY = process.env.NEXT_PUBLIC_NFT_STORAGE_API_KEY;

if (!API_KEY) {
  throw new Error("Env var NEXT_PUBLIC_NFT_STORAGE_API_KEY is missing");
}

const storeFormNFT = async (image: Blob, description: string) => {
  const nft = {
    image,
    name: "Based Derivative",
    description,
  };

  const client = new NFTStorage({ token: API_KEY });
  const metadata = await client.store(nft);
  return metadata;
};

export default storeFormNFT;
