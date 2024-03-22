// import deployedContracts from "~~/contracts/deployedContracts";
// import scaffoldConfig from "~~/scaffold.config";

// type ValidChain = keyof typeof deployedContracts;

// const ALCHEMY_GOERLI = "https://goerli.g.alchemy.com";
// const ALCHEMY_BASE_GOERLI = "https://base-goerli.g.alchemy.com";
// const ALCHEMY_BASE_MAINNET = "https://base-mainnet.g.alchemy.com";
const ALCHEMY_BASE_SEPOLIA = "https://base-sepolia.g.alchemy.com";
// const HARDHAT_NETWORK = "http://localhost:8545";
// const DEFAULT_CHAIN_ID: ValidChain = scaffoldConfig.targetNetworks[0].id;

// const mapAlchemyUrl = (chainId: ValidChain) => {
//   const target = scaffoldConfig.targetNetworks.find(t => chainId === t.id);
//   if (!target) {
//     throw new Error(`Could not find chain ${chainId}`);
//   }

//   switch (target.id) {
//     case 31337: {
//       throw new Error("Hardhat not supported");
//       return HARDHAT_NETWORK;
//     }
//     // case 5:
//     //   return ALCHEMY_GOERLI;
//     // case 8453:
//     //   return ALCHENY_BASE_MAINNET;
//     // case 84531:
//     //   return ALCHEMY_BASE_GOERLI;
//   }
//   // switch (chainId) {
//   //   // case 5:
//   //   //   return ALCHEMY_GOERLI;
//   //   case 8453:
//   //     return ALCHENY_BASE_MAINNET;
//   //   case 84531:
//   //     return ALCHEMY_BASE_GOERLI;
//   // }
// };

const C = {
  // ALCHEMY_BASEURL: mapAlchemyUrl(DEFAULT_CHAIN_ID),
  ALCHEMY_BASEURL: ALCHEMY_BASE_SEPOLIA,
};

export default C;
