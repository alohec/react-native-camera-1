import Foundation
import Accelerate
import HSCameraUtils

class HSImageBufferResizer {
  private let size: Size<Int>
  private let isGrayscale: Bool
  private let bufferInfo: HSBufferInfo
  
  private var destinationDataPointer: UnsafeMutableRawPointer
  private var temporaryBufferDataPointer: UnsafeMutableRawPointer?
  private var pixelBufferPool: CVPixelBufferPool?
  
  private func createPool(size: Size<Int>) -> CVPixelBufferPool? {
    guard let pool = pixelBufferPool else {
      pixelBufferPool = createCVPixelBufferPool(
        size: size,
        pixelFormatType: kCVPixelFormatType_32BGRA
      )
      return pixelBufferPool
    }
    return pool
  }
  
  public init?(
    size: Size<Int>,
    bufferInfo: HSBufferInfo,
    isGrayscale: Bool = false
  ) {
    let totalBytes = size.height * size.width * bufferInfo.bytesPerPixel
    guard let data = malloc(totalBytes) else {
      return nil
    }
    self.size = size
    self.isGrayscale = isGrayscale
    self.bufferInfo = bufferInfo
    self.destinationDataPointer = data
    guard let pool = createPool(size: size) else {
      return nil
    }
    self.pixelBufferPool = pool
  }
  
  deinit {
    free(destinationDataPointer)
    free(temporaryBufferDataPointer)
  }
  
  public func resize(
    imageBuffer: HSImageBuffer
  ) -> HSImageBuffer? {
    var sourceBuffer = imageBuffer.makeVImageBuffer()
    let destBytesPerRow = size.width * bufferInfo.bytesPerPixel
    var destinationImageBuffer = vImage_Buffer(
      data: destinationDataPointer,
      height: vImagePixelCount(size.height),
      width: vImagePixelCount(size.width),
      rowBytes: destBytesPerRow
    )
    
    // scale

    if isGrayscale {
      let resizeFlags = vImage_Flags(kvImageNoAllocate)
      let error = vImageScale_Planar8(&sourceBuffer, &destinationImageBuffer, nil, resizeFlags)
      if error != kvImageNoError {
        return nil
      }
    } else {
      let resizeFlags = vImage_Flags(kvImageNoAllocate | kvImageHighQualityResampling)
      
      // create a temporary buffer
      if temporaryBufferDataPointer == nil {
        let tmpBufferFlags = vImage_Flags(kvImageGetTempBufferSize)
        let tmpBufferSize = Int(vImageScale_ARGB8888(&sourceBuffer, &destinationImageBuffer, nil, tmpBufferFlags))
        if tmpBufferSize > 0 {
          guard let tmpBuffer = malloc(tmpBufferSize) else {
            return nil
          }
          temporaryBufferDataPointer = tmpBuffer
        }
      }
      
      let error = vImageScale_ARGB8888(
        &sourceBuffer,
        &destinationImageBuffer,
        temporaryBufferDataPointer,
        resizeFlags
      )
      if error != kvImageNoError {
        return nil
      }
    }
    
    guard
      let pool = pixelBufferPool,
      let destinationPixelBuffer = createPixelBuffer(with: pool)
    else {
      return nil
    }
    
    // save vImageBuffer to CVPixelBuffer
    
    var cgImageFormat = vImage_CGImageFormat(
      bitsPerComponent: UInt32(bufferInfo.bitsPerComponent),
      bitsPerPixel: UInt32(bufferInfo.bitsPerPixel),
      colorSpace: Unmanaged.passRetained(bufferInfo.colorSpace),
      bitmapInfo: bufferInfo.bitmapInfo,
      version: 0,
      decode: nil,
      renderingIntent: .defaultIntent
    )
    
    guard let cvImageFormat = vImageCVImageFormat_CreateWithCVPixelBuffer(
        destinationPixelBuffer
      )?.takeRetainedValue()
    else {
      return nil
    }
    vImageCVImageFormat_SetColorSpace(cvImageFormat, bufferInfo.colorSpace)
    
    let copyError = vImageBuffer_CopyToCVPixelBuffer(
      &destinationImageBuffer,
      &cgImageFormat,
      destinationPixelBuffer,
      cvImageFormat,
      nil,
      vImage_Flags(kvImageNoFlags)
    )
    
    if copyError != kvImageNoError {
      return nil
    }
    return HSImageBuffer(cvPixelBuffer: destinationPixelBuffer)
  }
}
