"use client";

import { ChangeEvent, useEffect, useState } from "react";
import type { NextPage } from "next";
import { useAccount } from "wagmi";
import AccessoryImage from "~~/components/AccessoryImage";
import ImageWithFallback from "~~/components/ImageWithFallback";
// import { useScaffoldContractWrite } from "~~/hooks/scaffold-eth";
import NFTSelector from "~~/components/NftSelector";
import { getNFTsForOwner } from "~~/utils/alchemy";
import elementToNft from "~~/utils/elementToNft";
import { mapOwnedNft } from "~~/utils/mapOwnedNft";

const mapToFallbackSrc = (url: string) => {
  return url.replace("https://ipfs.io", "https://nftstorage.link");
};

// import CompositeImage from "~~/components/CompositeImage";

// import { getMetadata } from "~~/utils/scaffold-eth/getMetadata";
// export const metadata = getMetadata({
//   title: "Remix NFTs",
//   description: "Remix your NFTs with our accessories",
// });
type AccessoryType = {
  name: string;
  width: number;
  height: number;
  src: string;
};

const accessoryMap: { [key: string]: AccessoryType } = {
  tophat: {
    name: "Top Hat",
    width: 131,
    height: 151,
    src: "/tophat-trim.png",
  },
};

const Remix: NextPage = () => {
  const { address: connectedAddress } = useAccount();
  const [ownedNfts, setOwnedNfts] = useState<ReturnType<typeof mapOwnedNft>[]>([]);
  // const [contractAddress, setContractAddress] = useState<string | undefined>();
  const [remixUrl, setRemixUrl] = useState<string | undefined>();
  //"https://ipfs.io/ipfs/bafybeifwjhl3vdm2vgmaeoxwesafffvnnlbq4ob6ewkj3eraec7qmoukaq/15.png",
  //);
  const [selectedAccessory, setSelectedAccessory] = useState<AccessoryType | undefined>();
  const handleAccessoryChange = (e: ChangeEvent<HTMLSelectElement>) => {
    console.info("Selected", accessoryMap[e.target.value]);
    setSelectedAccessory(accessoryMap[e.target.value]);
  };
  // const {
  //   writeAsync: remixNft,
  //   isLoading,
  //   isMining,
  // } = useScaffoldContractWrite({
  //   contractName: "BasedDerivatives",
  //   functionName: "mintBasedDerivative",
  //   args: [0n, ""],
  //   blockConfirmations: 1,
  //   onBlockConfirmation: txnReceipt => {
  //     console.log("Transaction blockHash", txnReceipt.blockHash);
  //   },
  // });
  const onMint = async (e: React.MouseEvent) => {
    e.preventDefault();
    const el = document.getElementById("remix-container");
    if (!el) {
      throw new Error("Could not find remix-container element.");
    }

    const metadataUrl = await elementToNft(el, "NFT Remix");

    if (metadataUrl) {
      // remixNft({
      //   args: [{
      //   }, {
      //   }],
      // }).then(transactionId => {
      // })
      // fileForm1099DA({
      //   args: [formId, metadataUrl.toString()],
      // })
      //   .then(transactionId => {
      //     if (transactionId) {
      //       setMintingComplete(true);
      //       onMint?.();
      //     } else {
      //       throw new TransactionRejected("Rejected fileForm1099DA transaction");
      //     }
      //   })
      //   .catch((error: Error) => {
      //     console.error("fileForm1099DA error:", error);
      //     setMintingComplete(false);
      //   });
    }
  };

  const handleSelectedNft = (nft: ReturnType<typeof mapOwnedNft>) => {
    setRemixUrl(nft.cachedUrl || nft.originalUrl || undefined);
  };

  //
  // On connected wallet, get all of the owned NFTs
  //
  useEffect(() => {
    let active = true;
    const fetchNFts = async () => {
      if (connectedAddress) {
        console.info(`Retrieving NFTs for ${connectedAddress}`);
        const data = await getNFTsForOwner(connectedAddress);
        const nftList = data.ownedNfts.map(mapOwnedNft).filter(nft => !!nft.name);
        if (active) {
          setOwnedNfts(nftList);
        }
      }
    };

    fetchNFts();

    return () => {
      active = false;
    };
  }, [connectedAddress]);

  return (
    <div className="container mx-auto px-4 mt-8">
      <div className="grid grid-cols-12 gap-4">
        <div className="col-span-3">
          <div className="mb-4">
            <div className="hidden mb-4">
              <input className="w-full p-2 mb-2 rounded bg-gray-800" placeholder="Search by Address" />
              <button className="w-full bg-blue-600 p-2 rounded">Search</button>
            </div>
            {/* <button className="mb-2 w-full bg-gray-800 p-2 rounded">☰ Owned NFTs</button> */}
            {/* <div className="bg-gray-800 p-2 rounded"> */}
            <NFTSelector nfts={ownedNfts} onSelect={handleSelectedNft} />
            <div className="mb-4">
              {/* <label htmlFor="accessory-dropdown" className="block mb-2">
              Accessory
            </label> */}
              <select
                id="accessory-dropdown"
                className="w-full dark:bg-gray-800 p-2 rounded mt-4"
                onChange={handleAccessoryChange}
              >
                <option value="">Select Accessory</option>
                <option value="tophat">Top Hat</option>
                <option value="tophat">Other Top Hat</option>
              </select>
            </div>
            <div>
              <button className="w-full bg-green-600 p-2 rounded" onClick={onMint}>
                Mint
              </button>
              <p className="mt-2">Cost: 0.01 ETH</p>
            </div>
            {/* </div> */}
          </div>
        </div>

        <div className="col-span-9 h-screen border-solid border-gray-400 border-2">
          <div
            id="remix-container"
            className="relative w-full h-full"
            style={{ backgroundImage: `url(${mapToFallbackSrc(remixUrl || "")})`, backgroundSize: "cover" }}
          >
            {selectedAccessory && <AccessoryImage {...selectedAccessory} />}
          </div>
          {/* <div className="col-span-6">
          <div className="w-full h-96 bg-gray-800 rounded flex items-center justify-center text-gray-400 overflow-clip">
            <div>
              {!remixUrl && <span>NFT to REMIX shows up here</span>}
              {remixUrl && (
                <ImageWithFallback
                  src={remixUrl}
                  alt="remix"
                  width="0"
                  height="0"
                  sizes="100vw"
                  className="w-full h-auto relative"
                  fallbackSrc={mapToFallbackSrc(remixUrl)}
                />
              )}
              {selectedAccessory && <AccessoryImage {...selectedAccessory} />}
            </div>
          </div>*/}
        </div>

        <div className="col-span-3 hidden">
          <div className="mb-4">
            {/* <label htmlFor="accessory-dropdown" className="block mb-2">
              Accessory
            </label> */}
            <select
              id="accessory-dropdown"
              className="w-full dark:bg-gray-800 p-2 rounded"
              onChange={handleAccessoryChange}
            >
              <option value="">Select Accessory</option>
              <option value="tophat">Top Hat</option>
              <option value="tophat">Other Top Hat</option>
            </select>
          </div>
          <div>
            <button className="w-full bg-green-600 p-2 rounded" onClick={onMint}>
              Mint
            </button>
            <p className="mt-2">Cost: 0.01 ETH</p>
          </div>
        </div>
      </div>
    </div>
  );
};

//             {remixUrl && <CompositeImage imageUrl={remixUrl} accessoryUrl={accessoryUrl} alt="selected accessory" />}

export default Remix;
