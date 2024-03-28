import Link from "next/link";
import type { NextPage } from "next";
import { BugAntIcon, MagnifyingGlassIcon } from "@heroicons/react/24/outline";

const Home: NextPage = () => {
  return (
    <>
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          <h1 className="text-center mb-8">
            <span className="block text-4xl font-bold">Base →D[erivatives]</span>
          </h1>
          <p className="text-center text-lg">Remix your NFT&apos;s</p>
          <p className="text-center text-lg">Turn this:</p>
        </div>
        <img src="/1099-da.png" alt="1099-da" className="w-[25%] h-[25%]" />
        <div className="px-5">
          <p className="text-center text-lg">Into this:</p>
        </div>
        <img src="/1099-da-remixed.png" alt="1099-da-remixed" className="w-[25%] h-[25%]" />
        <Link href="/remix" className="mt-4">
          <button className="btn btn-primary">Launch App</button>
        </Link>
        <div className="hidden flex-grow bg-base-300 w-full mt-16 px-8 py-12">
          <div className="flex justify-center items-center gap-12 flex-col sm:flex-row">
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
              <BugAntIcon className="h-8 w-8 fill-secondary" />
              <p>
                Tinker with your smart contract using the{" "}
                <Link href="/debug" passHref className="link">
                  Debug Contract
                </Link>{" "}
                tab.
              </p>
            </div>
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
              <MagnifyingGlassIcon className="h-8 w-8 fill-secondary" />
              <p>
                Explore your local transactions with the{" "}
                <Link href="/blockexplorer" passHref className="link">
                  Block Explorer
                </Link>{" "}
                tab.
              </p>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
