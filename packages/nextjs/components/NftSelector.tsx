import React from "react";
import cx from "classnames";
import { useAccount } from "wagmi";
import { mapOwnedNft } from "~~/utils/mapOwnedNft";

type NFT = ReturnType<typeof mapOwnedNft>;

interface NFTSelectorProps {
  nfts: NFT[];
  onSelect: (nft: NFT) => void;
}

const NFTSelector: React.FC<NFTSelectorProps> = ({ nfts, onSelect }) => {
  const { address: connectedAddress } = useAccount();
  const handleChange = (event: React.ChangeEvent<HTMLSelectElement>) => {
    const selectedNftId = event.target.value;
    const selectedNft = nfts.find(nft => nft.id === selectedNftId);

    if (selectedNft) {
      onSelect(selectedNft);
    }
  };

  return (
    <select
      className={cx("p-2 rounded w-full", { "cursor-not-allowed": !connectedAddress })}
      onChange={handleChange}
      disabled={!connectedAddress}
    >
      <option value="">Select an NFT</option>
      {nfts.map(nft => (
        <option key={nft.id} value={nft.id}>
          {nft.name}
        </option>
      ))}
    </select>
  );
};

export default NFTSelector;
