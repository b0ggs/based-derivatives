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
import { Address } from "~~/components/scaffold-eth";
import { useDeployedContractInfo, useScaffoldContractRead, useScaffoldContractWrite } from "~~/hooks/scaffold-eth";
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
  // tophat: {
  //   name: "Top Hat",
  //   width: 131,
  //   height: 151,
  //   src: "/tophat-trim.png",
  // },
  black: {
    name: "Top Hat - Black",
    width: 200,
    height: 200,
    src: "https://i.imgur.com/ln8ND8J.png",
  },
  // sunglasses: {
  //   name: "Sunglasses - Deal With It",
  //   width: 930,
  //   height: 600,
  //   src: "sunglasses.png",
  // },
};

type RemixNftType = ReturnType<typeof mapOwnedNft>;

const Remix: NextPage = () => {
  const { address: connectedAddress } = useAccount();
  const { remixState } = useRemix();
  const [selectedNft, setSelectedNft] = useState<RemixNftType | undefined>();
  const [ownedNfts, setOwnedNfts] = useState<RemixNftType[]>([]);
  const [isMinting, setIsMinting] = useState(false);
  const [selectedAccessory, setSelectedAccessory] = useState<AccessoryType | undefined>();
  const { data: deployedContractData /*, isLoading: deployedContractLoading */ } =
    useDeployedContractInfo("BasedDerivatives");
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
    args: [0n],
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

  console.log("remixState:", {
    remixState,
  });

  const onMint = async (e: React.MouseEvent) => {
    setIsMinting(true);
    e.preventDefault();
    const el = document.getElementById("remix-container");
    if (!el) {
      throw new Error("Could not find remix-container element.");
    }

    const cid = await elementToNft(el);
    const accessoryId = accessoryData?.[0];

    if (accessoryId === undefined) {
      throw new Error("Could not get accessoryId from accessoryData");
    }

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
        height: remixState.ogHeight,
        width: remixState.ogWidth,
      };
      const accessoryMintData = {
        accessoryId,
        imageURL: selectedAccessory.src,
        height: remixState.height,
        width: remixState.width,
        x: remixState.x,
        y: remixState.y,
        isVisible: true,
      };
      // console.log("mintBasedDerivative:", {
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
        const fetchPage = async (address: string, pageKey: string | undefined) => {
          const data = await getNFTsForOwner(address, pageKey);
          const nftList = data.ownedNfts
            .map(mapOwnedNft)
            .filter(nft => !!nft.name && nft.address !== "0x744f1532597e943D0604e56cee2A9D68d543B2e3");
          return { nftList, pageKey: data.pageKey };
        };

        let nftList: RemixNftType[] = [];
        let currentPageKey: string | undefined | null = undefined;
        do {
          const rv = await fetchPage(connectedAddress, currentPageKey);
          nftList = nftList.concat(rv.nftList);
          currentPageKey = rv.pageKey;
        } while (currentPageKey);

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
            <NFTSelector nfts={ownedNfts} onSelect={handleSelectedNft} />
            <div className="mb-4">
              <select
                id="accessory-dropdown"
                className={cx("w-full p-2 rounded mt-4", { "cursor-not-allowed": !selectedNft })}
                disabled={!selectedNft}
                onChange={handleAccessoryChange}
              >
                <option value="">Select Accessory</option>
                <option value="black">Top Hat - Black</option>
                {/* <option value="sunglasses">Sunglasses - Deal With It</option> */}
              </select>
            </div>
            <div>
              <button
                className={cx("w-full p-2 mb-4 rounded", {
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
              {connectedAddress &&
              <a
                className="pt-4 link link-primary"
                href={`https://testnets.opensea.io/${connectedAddress}`}
                rel="noopener noreferrer"
              >
                View on OpenSea
              </a>}
              {deployedContractData && (
                <div className="relative bottom-0 bg-base-100 border-base-300 border shadow-md shadow-secondary rounded px-6 lg:px-8 space-y-1 py-4 mt-4">
                  <div className="flex flex-col gap-1">
                    <span className="font-bold">Base →D[erivatives]</span>
                    <Address address={deployedContractData.address} />
                  </div>
                </div>
              )}

              {/* <p className="mt-2">Cost: 0.01 ETH</p> */}
            </div>
            {/* </div> */}
          </div>
        </div>

        <div className="col-span-9">
          {!selectedNft && (
            <div className="flex flex-col items-center justify-center h-full">
              Start by selecting an NFT to remix from the dropdown on the left.
            </div>
          )}
          {selectedNft && (
            <RemixImage
              backgroundUrl={mapToFallbackSrc(selectedNft?.cachedUrl || selectedNft?.originalUrl || "")}
              accessoryUrl={selectedAccessory?.src}
            />
          )}
        </div>
      </div>
    </div>
  );
};

export default Remix;
