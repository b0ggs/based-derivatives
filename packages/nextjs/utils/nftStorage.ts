import { NFTStorage } from "nft.storage";

const API_KEY = process.env.NEXT_PUBLIC_NFT_STORAGE_API_KEY;

if (!API_KEY) {
  throw new Error("Env var NEXT_PUBLIC_NFT_STORAGE_API_KEY is missing");
}

export const storeNftImage = async (image: Blob) => {
  const client = new NFTStorage({ token: API_KEY });
  let cid;
  try {
    cid = await client.storeBlob(image);
  } catch (err: unknown) {
    console.error(err);
    return undefined;
  }
  return cid;
};
