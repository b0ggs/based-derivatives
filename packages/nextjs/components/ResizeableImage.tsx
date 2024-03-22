import React, { CSSProperties, useRef, useState } from "react";

interface ResizableImageProps {
  url: string;
  style: CSSProperties;
}

const ResizableImage: React.FC<ResizableImageProps> = ({ url, style }) => {
  const [size, setSize] = useState({ width: 200, height: 200 }); // Default size
  const resizingRef = useRef(false);
  const lastMousePositionRef = useRef({ x: 0, y: 0 });

  const startResizing = (e: React.MouseEvent<HTMLDivElement, MouseEvent>) => {
    resizingRef.current = true;
    lastMousePositionRef.current = { x: e.clientX, y: e.clientY };
    document.addEventListener("mousemove", resize);
    document.addEventListener("mouseup", stopResizing);
  };

  const resize = (e: MouseEvent) => {
    if (resizingRef.current) {
      const deltaX = e.clientX - lastMousePositionRef.current.x;
      const deltaY = e.clientY - lastMousePositionRef.current.y;
      setSize(prevSize => ({
        width: Math.max(100, prevSize.width + deltaX),
        height: Math.max(100, prevSize.height + deltaY),
      }));
      lastMousePositionRef.current = { x: e.clientX, y: e.clientY };
    }
  };

  const stopResizing = () => {
    resizingRef.current = false;
    document.removeEventListener("mousemove", resize);
    document.removeEventListener("mouseup", stopResizing);
  };

  const combinedStyles = { ...style, width: size.width, height: size.height };
  return (
    <div style={combinedStyles} className="relative border border-gray-400 overflow-auto">
      <div id="remix-container">
        <img src={url} alt="Resizable" className="w-full h-full"/>
        <div className="absolute bottom-0 right-0 cursor-nwse-resize bg-gray-500 w-5 h-5" onMouseDown={startResizing} />
      </div>
    </div>
  );
};

export default ResizableImage;
