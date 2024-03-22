import React, { useState } from "react";
import Image from "next/image";
import ImageWithFallback from "~~/components/ImageWithFallback";
import AccessoryImage from "~~/components/AccessoryImage";

const mapToFallbackSrc = (url: string) => {
  return url.replace("https://ipfs.io", "https://nftstorage.link");
};

// Define a type for the component props
interface CompositeImageProps {
  imageUrl: string;
  accessoryUrl?: string;
  alt: string;
}

const CompositeImage = ({ imageUrl, accessoryUrl, alt }: CompositeImageProps) => {
  // Define a type for the position state
  // interface Position {
  //   x: number;
  //   y: number;
  // }

  // const [position, setPosition] = useState<Position>({ x: 0, y: 0 });
  // const [dragging, setDragging] = useState<boolean>(false);

  // // eslint-disable-next-line @typescript-eslint/no-unused-vars
  // const startDrag = (e: React.MouseEvent<HTMLImageElement, MouseEvent>) => {
  //   setDragging(true);
  // };

  // const onDrag = (e: React.MouseEvent<HTMLImageElement, MouseEvent>) => {
  //   if (dragging) {
  //     setPosition({
  //       x: position.x + e.movementX,
  //       y: position.y + e.movementY,
  //     });
  //   }
  // };

  // const endDrag = () => {
  //   setDragging(false);
  // };

  return (
    <div>
      <ImageWithFallback
        src={imageUrl}
        alt={alt}
        width="0"
        height="0"
        sizes="100vw"
        className="w-full h-auto"
        fallbackSrc={mapToFallbackSrc(imageUrl)}
      />
      {/* <img src={imageUrl} alt="Main" style={{ width: "100%", height: "auto" }} /> */}
      {/* <ResizableImage
        url={topHatUrl}
        style={{ position: "absolute", left: position.x, top: position.y, cursor: "grab" }}
        onMouseDown={startDrag}
        onMouseMove={onDrag}
        onMouseUp={endDrag}
        onMouseLeave={endDrag}
      /> */}

      {accessoryUrl && (
        <AccessoryImage imageUrl={accessoryUrl} />
        // <Image
        //   src={accessoryUrl}
        //   alt="Top Hat"
        //   style={{ position: "absolute", left: position.x, top: position.y, cursor: "grab" }}
        //   width={200}
        //   height={200}
        //   onMouseDown={startDrag}
        //   onMouseMove={onDrag}
        //   onMouseUp={endDrag}
        //   onMouseLeave={endDrag}
        // />
      )}
    </div>
  );
};

export default CompositeImage;
