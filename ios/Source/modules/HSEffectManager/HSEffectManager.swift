import AVFoundation
import CoreGraphics
import UIKit
import HSCameraUtils

@available(iOS 11.0, *)
@objc
class HSEffectManager: NSObject {
  internal lazy var effectLayer: CALayer = {
    let layer = CALayer()
    layer.contentsGravity = .resizeAspectFill
    return layer
  }()

  @objc(sharedInstance)
  public static let shared = HSEffectManager()
  
  private lazy var model: SegmentationModel = {
    return SegmentationModel()
//    SegmentationModel(contentsOf: <#T##URL#>)
  }()

  @objc(applyEffectWithDepthData:videoData:error:)
  public func applyEffect(with depthData: AVDepthData, videoSampleBuffer: CMSampleBuffer) throws {
    let depthPixelBuffer = HSPixelBuffer<Float32>(depthData: depthData)
    guard let videoPixelBuffer = HSPixelBuffer<Float32>(sampleBuffer: videoSampleBuffer) else {
      return
    }
    
    let input = SegmentationModelInput(
      color_image_input: videoPixelBuffer.buffer,
      depth_image_input: depthPixelBuffer.buffer
    )
    let output = try model.prediction(input: input)
    print(output.segmentation_image_output)
  }

  func createMask(depthImage: CIImage, scale: Float) -> CIImage {
    let blurRadius = 3
    return depthImage
      .clampedToExtent()
      .applyingFilter("CINoiseReduction", parameters: ["inputNoiseLevel": 1, "inputSharpness": 0.4])
      .applyingFilter("CIGaussianBlur", parameters: ["inputRadius": blurRadius])
      .cropped(to: depthImage.extent)
      .applyingFilter("CILanczosScaleTransform", parameters: ["inputScale": scale])
  }

//  func applyMask(foreground foregroundImage: CIImage, background backgroundImage: CIImage, mask maskImage: CIImage) {
//    let flipTransform = CGAffineTransform(scaleX: -1, y: 1)
////    let parameters = ["inputMaskImage": maskImage, "inputBackgroundImage": backgroundImage]
//    let displayImage = maskImage
////      .applyingFilter("CIBlendWithMask", parameters: parameters)
//      .applyingFilter("CIAffineTransform", parameters: ["inputTransform": flipTransform])
//
//    guard let cgImage = context.createCGImage(displayImage, from: displayImage.extent) else {
//      return
//    }
//
//    DispatchQueue.main.async {
//      self.effectLayer.contents = cgImage
//    }
//  }
}