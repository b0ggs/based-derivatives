import C from "~~/constants";

export type AlchemyNftData = {
  contract: {
    address: string;
    name: string;
    symbol: string;
  };
  tokenId: string;
  tokenType: string;
  name: string;
  description: string;
  tokenUri: string;
  image: {
    cachedUrl?: string | null;
    pngUrl: string | null;
    originalUrl: string | null;
  };
  raw: {
    metadata: {
      attributes: {
        trait_type: string;
        value: string;
      }[];
    };
  };
};

export type AlchemyResponse = {
  ownedNfts: AlchemyNftData[];
  totalCount: number;
  pageKey: string | null;
};

const requestOptions = {
  method: "GET",
  headers: { Accept: "application/json" },
};

const apiKey = process.env.NEXT_PUBLIC_ALCHEMY_API_KEY;
const baseURL = `${C.ALCHEMY_BASEURL}/nft/v3/${apiKey}/getNFTsForOwner`;

export async function getNFTsForOwner(owner: string) {
  const pageSize = 100;
  const fetchURL = `${baseURL}?owner=${owner}&withMetadata=true&pageSize=${pageSize}`;

  return fetch(fetchURL, requestOptions).then(response => response.json() as Promise<AlchemyResponse>);
  // .then(metadata => {
  //   console.log(JSON.stringify(metadata, null, 2)))
  //.catch(err => console.error(err))
}
