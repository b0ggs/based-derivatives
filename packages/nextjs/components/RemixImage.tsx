/* eslint-disable @next/next/no-img-element */
import { access } from "fs";
import React, { useEffect, useState } from "react";
import { Rnd } from "react-rnd";
import { useRemix } from "~~/hooks/useRemix";

function RemixImage({ backgroundUrl, accessoryUrl }: { backgroundUrl: string; accessoryUrl: string | undefined }) {
  const { setRemixState } = useRemix();
  const [aState, setAState] = useState({
    x: 0,
    y: 0,
    w: 200,
    h: 200,
    width: "200px",
    height: "200px",
  });

  const style = {
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    // border: "solid 1px #ddd",
    // background: "#f0f0f0",
  };

  useEffect(() => {
    setRemixState(prev => ({ ...prev, width: aState.w, height: aState.h }));
  }, [aState.w, aState.h, setRemixState]);

  return (
    <div className="relative">
      <div id="remix-container" className="w-fit">
        <img src={backgroundUrl} alt="" />
        <Rnd
          style={style}
          size={{ width: aState.width, height: aState.height }}
          position={{ x: aState.x, y: aState.y }}
          onDragStop={(e, d) => {
            console.log("position:", { x: d.x, y: d.y });
            setAState(prev => ({ ...prev, x: d.x, y: d.y }));
            setRemixState(prev => ({ ...prev, x: d.x, y: d.y }));
          }}
          onResizeStop={(e, direction, ref, delta, position) => {
            setAState({
              w: Number(ref.style.width.replace("px", "")),
              h: Number(ref.style.height.replace("px", "")),
              width: ref.style.width,
              height: ref.style.height,
              ...position,
            });
          }}
        >
          {accessoryUrl && <img src={accessoryUrl} alt="" className="z-10 w-full h-full" />}
        </Rnd>
      </div>
    </div>
  );
}

export default RemixImage;
