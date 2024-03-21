# Base →D\[erivatives\]

Base →D\[erivatives\] is an art project that explores the concepts of composability and remix culture in the world of NFTs. It allows users to create unique derivative NFTs by combining their existing NFTs with various accessories, while tracking the provenance of each change made to the derivative.

## Features

- **NFT Remixing**: Users can select any existing NFTs they own and add accessories to create a new, unique derivative NFT.

- **Accessory System**: The smart contract supports the use of other NFTs as accessories. These accessories are whitelisted. They can be configured to pay royalties to the accessory owners when used in a derivative. For example, an artist may be commissioned to create a hat accessory and if a user adds it to their derivative NFT a royalty may be passed to the artist. Accessories can also be gated. For example, a user may need to own a certain ERC-20/ERC-1155/ERC-721 token in order to use an accessory.

- **On-chain SVGs and IPFS**: The project utilizes on-chain SVGs and IPFS to enable users to edit their minted derivatives without the need for reminting. Users can move, add, or remove accessories from their derivatives at any time.

- **Provenance Tracking**: Base →D\[erivatives\] keeps track of all changes made to each derivative NFT, providing a clear history of its evolution.

- **Limited Supply**: The number of Base →D\[erivatives\] will be limited, making it an exclusive art project focused on remix culture.

- **Accessory Parameters**: Accessories can have various parameters, such as a limited total supply, requiring payment in any ERC-20 token, or being gated by ERC-20, ERC-1155, or ERC-721 token holdings. This allows for the creation of rare and exclusive accessories.

- **Royalty Payments**: The contract includes a `Payout` struct and handles the distribution of royalty payments to accessory owners and the beneficiary address. This ensures that creators of accessories are fairly compensated when their work is used in derivative NFTs.

- **Ownership Verification**: The contract includes functions to verify the ownership of the original NFT used in the derivative, ensuring that only the owner can create or modify the derivative. This provides an additional layer of security and prevents unauthorized modifications.

- **Metadata Generation**: The contract uses the `SVGBuilder` library to generate the metadata and SVG images for the derivative NFTs. This allows for dynamic and customizable metadata that reflects the unique combinations of accessories used in each derivative.

- **Payment Handling**: The contract supports payments in any ERC-20 token and includes functions to calculate the total fee for accessories and handle the payment distribution. 

- **Customization**: The contract includes functions to toggle the visibility of accessories and update the preview image URL, allowing users to customize their derivatives even after minting. This gives users the freedom to adjust their creations as desired.

## How It Works

1. Users visit the Base →D\[erivatives\] dApp and connect their wallet to view their existing NFTs.

2. They can then select an NFT and add accessories to it, creating a new derivative NFT.

3. Users can mint their derivative NFT, which will be stored on-chain using SVGs and IPFS.

4. After minting, users can revisit their derivative and make changes, such as moving, adding, or removing accessories, without the need for reminting.

5. If a user purchases a derivative from the secondary market, they can replace the original NFT image with their own, while the project tracks the provenance of all changes made to the derivative. Note that in order for an original NFT image to show, the user must own it in the same wallet. Therefore, changing the original image is essential for any secondary sales of the derivative NFT.

## Getting Started

To get started with Base →D\[erivatives\], simply visit our dApp at [base-derivatives.vercel.app](https://base-derivatives.vercel.app). The project is currently deployed on the Base Sepolia testnet, and the smart contract address is `0x1234567890abcdef`.

Please note that you will need a wallet connected to the Base Sepolia testnet to interact with the dApp. You will also need an NFT on Base Sepolia to interact.

## License

Base →D\[erivatives\] is released under the [MIT License](LICENSE).
