import * as htmlToImage from "html-to-image";
import storeFormNFT from "~~/utils/nftStorage";

const elementToNft = (el: HTMLElement, description: string) => {
  return htmlToImage
    .toBlob(el, { quality: 1.0 })
    .then(async blob => {
      if (!blob) {
        throw new Error("form blob is undefined");
      }
      console.log("Writing form NFT to nft.storage");
      const metadata = await storeFormNFT(blob, description);
      // console.log("nft.storage metadata", JSON.stringify(metadata, null, 2));
      console.log("Filing URI", metadata.url);
      return metadata.url;
    })
    .catch((err: Error) => {
      console.error("oops, something went wrong!", err);
      console.error("Error message:", err.message);
      return undefined;
    });
};

export default elementToNft;
