"use client";

import { ChangeEvent, useEffect, useState } from "react";
import cx from "classnames";
import type { NextPage } from "next";
import {
  useAccount,
  /*, useContractReads*/
} from "wagmi";
import NFTSelector from "~~/components/NftSelector";
import RemixImage from "~~/components/RemixImage";
import { useScaffoldContractRead, useScaffoldContractWrite } from "~~/hooks/scaffold-eth";
import { useRemix } from "~~/hooks/useRemix";
import { getNFTsForOwner } from "~~/utils/alchemy";
import elementToNft from "~~/utils/elementToNft";
import { mapOwnedNft } from "~~/utils/mapOwnedNft";

const mapToFallbackSrc = (url: string) => {
  return url.replace("https://ipfs.io", "https://nftstorage.link");
};

const cidToUrl = (cid: string) => {
  return `https://${cid}.ipfs.nftstorage.link/`;
};

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
  black: {
    name: "Top Hat - Black",
    width: 200,
    height: 200,
    src: "https://i.imgur.com/ln8ND8J.png",
  },
};

type RemixNftType = ReturnType<typeof mapOwnedNft>;

const Remix: NextPage = () => {
  const { address: connectedAddress } = useAccount();
  const { remixState } = useRemix();
  const [selectedNft, setSelectedNft] = useState<RemixNftType | undefined>();
  const [ownedNfts, setOwnedNfts] = useState<RemixNftType[]>([]);
  const [isMinting, setIsMinting] = useState(false);
  const [selectedAccessory, setSelectedAccessory] = useState<AccessoryType | undefined>();
  const handleAccessoryChange = (e: ChangeEvent<HTMLSelectElement>) => {
    console.info("Selected", accessoryMap[e.target.value]);
    setSelectedAccessory(accessoryMap[e.target.value]);
  };
  const {
    writeAsync: remixNft,
    isLoading,
    isMining,
  } = useScaffoldContractWrite({
    contractName: "BasedDerivatives",
    functionName: "mintBasedDerivative",
    blockConfirmations: 1,
    args: [
      {
        collection: "0x0",
        tokenId: 0n,
        ercType: 0,
        imageURL: "https://example.com",
        height: 0,
        width: 0,
      },
      [
        {
          accessoryId: 0n,
          imageURL: "https://accessory.com",
          height: 0,
          width: 0,
          x: 0,
          y: 0,
          isVisible: true,
        },
      ],
      "https://ipfs.link",
    ],
    onBlockConfirmation: txnReceipt => {
      console.log("Minting complete");
      console.log("Transaction blockHash", txnReceipt.blockHash);
    },
  });

  const { data: accessoryCount } = useScaffoldContractRead({
    contractName: "BasedDerivatives",
    functionName: "accessoryCount",
  });

  const { data: accessoryData } = useScaffoldContractRead({
    contractName: "BasedDerivatives",
    functionName: "accessoryData",
    args: [2n],
  });

  // const accessoryDataCalls = accessoryCount
  //   ? Array.from(Array(accessoryCount).keys()).map(index => ({
  //       addressOrName: deployedContracts[84532].BasedDerivatives.address,
  //       contractInterface: deployedContracts[84532].BasedDerivatives.abi,
  //       functionName: "accessoryData",
  //       args: [BigInt(index)],
  //     }))
  //   : [];

  // const { data: accessoryData } = useContractReads({
  //   contracts: accessoryDataCalls,
  // });

  if (accessoryData) {
    console.log("Number of accessories:", accessoryCount);
    console.log("AccessoryData", {
      accessoryId: accessoryData[0],
      totalSupply: accessoryData[1],
      amountMinted: accessoryData[2],
      amountPerTokenId: accessoryData[3],
      traitType: accessoryData[4],
      value: accessoryData[5],
    });
  }

  // if (selectedNft) {
  //   console.log("Serializing:", {
  //     selectedNft: JSON.stringify(selectedNft, null, 2),
  //     tokenId: selectedNft.tokenId,
  //     bigTokenId: BigInt(Number(selectedNft.tokenId)),
  //   });
  // }
  // console.log("REMIX STATE:", {
  //   remixState,
  // });

  const onMint = async (e: React.MouseEvent) => {
    setIsMinting(true);
    e.preventDefault();
    const el = document.getElementById("remix-container");
    if (!el) {
      throw new Error("Could not find remix-container element.");
    }

    const cid = await elementToNft(el);

    if (cid && selectedNft && selectedAccessory) {
      const previewUrl = cidToUrl(cid);
      // console.info("NFT CID:", { cid, previewUrl });
      const imageUrl = selectedNft.cachedUrl || selectedNft.originalUrl;

      if (!imageUrl) {
        throw new Error("No image found for remix NFT");
      }

      const ercType = Number(selectedNft.tokenType.replace("ERC", ""));

      if (Number.isNaN(ercType)) {
        throw new Error("Could not convert ercType");
      }

      const ogImageData = {
        collection: selectedNft.address,
        tokenId: BigInt(Number(selectedNft.tokenId)),
        ercType,
        imageURL: imageUrl,
        height: 512,
        width: 768,
      };
      const accessoryMintData = {
        accessoryId: 2n,
        imageURL: selectedAccessory.src,
        height: remixState.height,
        width: remixState.width,
        x: remixState.x,
        y: remixState.y,
        isVisible: true,
      };

      // console.log("MINT SERIALIZED:", {
      //   selectedNft,
      //   ogImageData,
      //   accessoryMintData,
      //   previewUrl,
      // });

      remixNft({
        args: [ogImageData, [accessoryMintData], previewUrl],
      })
        .then(transactionId => {
          if (transactionId) {
            console.log("Mint TransactionId:", transactionId);
            alert("Mint Complete...");
          } else {
            alert("Mint Failed or canceled ...");
          }
        })
        .catch((err: Error) => {
          console.error(err);
          alert(`Mint Failed: [${err.name}] - ${err.message}`);
        })
        .finally(() => {
          setIsMinting(false);
        });
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
    console.info("Selected NFT:", nft);
    setSelectedNft(nft);
  };

  const enableMinting = selectedNft && selectedAccessory && !isMinting && !isLoading && !isMining;

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
            <NFTSelector nfts={ownedNfts} onSelect={handleSelectedNft} />
            <div className="mb-4">
              <select
                id="accessory-dropdown"
                className={cx("w-full p-2 rounded mt-4", { "cursor-not-allowed": !selectedNft })}
                onChange={handleAccessoryChange}
                disabled={!selectedNft}
              >
                <option value="">Select Accessory</option>
                <option value="tophat">Top Hat</option>
                <option value="black">Top Hat - Black</option>
              </select>
            </div>
            <div>
              <button
                className={cx("w-full p-2 rounded", {
                  "animate-pulse-fast": isMinting,
                  btn: !enableMinting,
                  "btn btn-primary": enableMinting,
                  "cursor-not-allowed": !enableMinting,
                })}
                onClick={onMint}
                disabled={!enableMinting}
              >
                Mint
              </button>
              {/* <p className="mt-2">Cost: 0.01 ETH</p> */}
            </div>
            {/* </div> */}
          </div>
        </div>

        <div className="col-span-9 h-screen border-solid border-gray-400 border-2">
          <RemixImage
            backgroundUrl={mapToFallbackSrc(selectedNft?.cachedUrl || selectedNft?.originalUrl || "")}
            accessoryUrl={selectedAccessory?.src}
          />
        </div>
      </div>
    </div>
  );
};

export default Remix;
