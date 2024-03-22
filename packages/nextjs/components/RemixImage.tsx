import React, { useState } from "react";

type Accessory = {
  name: string;
  width: number;
  height: number;
  src: string;
};

interface RemixProps {
  remixUrl: string | undefined;
  accessory: Accessory | undefined;
}

const RemixImage: React.FC<RemixProps> = ({ remixUrl, accessory }) => {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [size, setSize] = useState({ width: accessory?.width || 0, height: accessory?.height || 0 });

  const handleDragStart = (e: React.DragEvent<HTMLImageElement>) => {
    const img = e.currentTarget;
    const offsetX = e.clientX - img.offsetLeft;
    const offsetY = e.clientY - img.offsetTop;

    const onDrag = (ev: MouseEvent) => {
      setPosition({
        x: ev.clientX - offsetX,
        y: ev.clientY - offsetY,
      });
    };

    const onDragEnd = () => {
      document.removeEventListener("mousemove", onDrag);
      document.removeEventListener("mouseup", onDragEnd);
    };

    document.addEventListener("mousemove", onDrag);
    document.addEventListener("mouseup", onDragEnd);
  };

  const handleResize = (e: React.MouseEvent<HTMLDivElement, MouseEvent>) => {
    const newSize = {
      width: e.clientX - position.x,
      height: e.clientY - position.y,
    };
    setSize(newSize);
  };

  return (
    <div className="relative w-full h-96" style={{ backgroundImage: `url(${remixUrl})`, backgroundSize: "cover" }}>
      {accessory && (
        <img
          src={accessory.src}
          alt="Accessory"
          className="absolute cursor-move"
          style={{ left: position.x, top: position.y, width: size.width, height: size.height }}
          draggable
          onDragStart={handleDragStart}
        />
      )}
      <div className="absolute bottom-0 right-0 cursor-nw-resize" onMouseDown={handleResize}></div>
    </div>
  );
};

export default RemixImage;
