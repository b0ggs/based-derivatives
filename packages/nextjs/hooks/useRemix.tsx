import React, { ReactNode, createContext, useContext, useState } from "react";

export type RemixState = {
  x: number;
  y: number;
  width: number;
  height: number;
};

export interface RemixContextProps {
  remixState: RemixState;
  setRemixState: React.Dispatch<React.SetStateAction<RemixState>>;
}

const RemixContext = createContext<RemixContextProps>({
  remixState: {
    x: 0,
    y: 0,
    width: 0,
    height: 0,
  },
  setRemixState: () => null,
});

export const useRemix = () => useContext(RemixContext);

export const RemixProvider = ({ children }: { children: ReactNode }) => {
  const [remixState, setRemixState] = useState({
    x: 0,
    y: 0,
    width: 0,
    height: 0,
  });

  return <RemixContext.Provider value={{ remixState, setRemixState }}>{children}</RemixContext.Provider>;
};
