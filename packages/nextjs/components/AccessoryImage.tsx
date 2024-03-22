import React, { useState } from "react";
import Image from "next/image";
import cx from "classnames";
import { Resizable } from "re-resizable";
import Draggable from "react-draggable";

type AccessoryImageProps = {
  src: string;
  width: number;
  height: number;
};

const AccessoryImage: React.FC<AccessoryImageProps> = ({ src, width, height }) => {
  const nodeRef = React.useRef(null);
  const [isDragging, setIsDragging] = useState(false);
  const [isResizing, setIsResizing] = useState(false);
  const [imgState, setImgState] = useState({ width, height });
  const [selected, setSelected] = useState(false);

  const handleDrag = () => {
    setIsDragging(true);
    setIsResizing(false);
  };

  const handleResizeStart = () => {
    setIsResizing(true);
    setIsDragging(false);
  };

  const handleMouseOver = () => {
    if (!isDragging) {
      setIsResizing(true);
    }
  };

  const handleMouseOut = () => {
    if (!isDragging) {
      setIsResizing(false);
    }
  };

  const handleBlur = () => {
    setSelected(false);
  };

  const handleFocus = () => {
    setSelected(true);
  };

  console.log({
    isDragging,
    isResizing,
  });

  // defaultSize={{
  //   width: 131,
  //   height: 151,
  // }}
  // style={{
  //   background: `url(${imageUrl})`,
  //   backgroundSize: "contain",
  //   backgroundRepeat: "no-repeat",
  // }}

  return (
    <Draggable nodeRef={nodeRef} disabled={isResizing} onMouseDown={handleFocus} onStop={handleBlur}>
      <Resizable
        handleStyles={{
          topRight: isResizing ? { border: "2px dashed gray" } : {},
          bottomRight: isResizing ? { border: "2px dashed gray" } : {},
          bottomLeft: isResizing ? { border: "2px dashed gray" } : {},
          topLeft: isResizing ? { border: "2px dashed gray" } : {},
        }}
        size={{ width: imgState.width, height: imgState.height }}
        onResizeStop={(e, direction, ref, d) => {
          setImgState({
            width: imgState.width + d.width,
            height: imgState.height + d.height,
          });
        }}
        lockAspectRatio={false}
      >
        <Image
          ref={nodeRef}
          src={src}
          alt="Accessory"
          layout="fill"
          className={cx({ "border-solid border-red-500 border-2": selected })}
        />
      </Resizable>
    </Draggable>
  );
  // return (
  //   <Draggable onStart={handleDrag} onStop={() => setIsDragging(false)}>
  //     <div className="w-[131px] h-[151px]">
  //     <Image
  //       src={imageUrl}
  //       alt="Accessory"
  //       layout="fill"
  //       objectFit="contain"
  //       onMouseOver={handleMouseOver}
  //       onMouseOut={handleMouseOut}
  //       className="border-solid border-red-500 border-2"
  //     />
  //     </div>
  //   </Draggable>
  // );
};

// className={`overflow-hidden ${isResizing ? "border-dashed border-2 border-gray-400" : ""}`}
/* <Draggable onStart={handleDrag} onStop={() => setIsDragging(false)}>
<Resizable
  size={{ width: 131, height: 151 }}
  onResizeStart={handleResizeStart}
  onResizeStop={() => setIsResizing(false)}
  enable={
    isResizing
      ? {
          top: true,
          right: true,
          bottom: true,
          left: true,
          topRight: true,
          bottomRight: true,
          bottomLeft: true,
          topLeft: true,
        }
      : {}
  }
  handleStyles={{
    topRight: isResizing ? { border: "2px dashed gray" } : {},
    bottomRight: isResizing ? { border: "2px dashed gray" } : {},
    bottomLeft: isResizing ? { border: "2px dashed gray" } : {},
    topLeft: isResizing ? { border: "2px dashed gray" } : {},
  }}
>
  <div>
    <Image src={imageUrl} alt="Accessory" layout="fill" objectFit="contain"  onMouseOver={handleMouseOver} onMouseOut={handleMouseOut} className="border-solid border-red-500 border-2"/>
  </div>
</Resizable>
</Draggable> */

export default AccessoryImage;
