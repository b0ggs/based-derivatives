import { storeNftImage } from "./nftStorage";
import * as htmlToImage from "html-to-image";

const elementToNft = (el: HTMLElement) => {
  return htmlToImage
    .toBlob(el, { quality: 1.0 })
    .then(async blob => {
      if (!blob) {
        throw new Error("form blob is undefined");
      }
      console.log("Writing form NFT to nft.storage");
      return await storeNftImage(blob);
    })
    .catch((err: Error) => {
      console.error("oops, something went wrong!", err);
      console.error("Error message:", err.message);
      return undefined;
    });
};

export default elementToNft;
