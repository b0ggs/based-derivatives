import React from "react";
import { mapOwnedNft } from "~~/utils/mapOwnedNft";

// interface NFT {
//   id: string;
//   name: string;
//   // Add other properties as needed
// }
type NFT = ReturnType<typeof mapOwnedNft>;

interface NFTSelectorProps {
  nfts: NFT[];
  onSelect: (nft: NFT) => void;
}

const NFTSelector: React.FC<NFTSelectorProps> = ({ nfts, onSelect }) => {
  const handleChange = (event: React.ChangeEvent<HTMLSelectElement>) => {
    const selectedNftId = event.target.value;
    const selectedNft = nfts.find(nft => nft.id === selectedNftId);

    if (selectedNft) {
      onSelect(selectedNft);
    }
  };

  return (
    <select className="p-2 rounded w-full" onChange={handleChange}>
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