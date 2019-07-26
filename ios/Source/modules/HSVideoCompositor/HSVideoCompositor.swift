import AVFoundation
import CoreImage
import HSCameraUtils

class HSVideoCompositor: NSObject, AVVideoCompositing {
  private enum VideoCompositionRequestError: Error {
    case failedToComposePixelBuffer
  }

  private var renderingQueue = DispatchQueue(label: "com.jonbrennecke.hsvideocompositor.renderingqueue")
  private var renderingContextQueue = DispatchQueue(label: "com.jonbrennecke.hsvideocompositor.rendercontextqueue")
  private var renderContext: AVVideoCompositionRenderContext?
  
  private lazy var mtlDevice: MTLDevice! = {
    guard let mtlDevice = MTLCreateSystemDefaultDevice() else {
      fatalError("Failed to create Metal device")
    }
    return mtlDevice
  }()
  
  private lazy var context = CIContext(mtlDevice: mtlDevice)
  private lazy var depthBlurEffect = HSDepthBlurEffect()

  public var depthTrackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid
  public var videoTrackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid
  public var isDepthPreviewEnabled: Bool = false
  public var isPortraitModeEnabled: Bool = false

  private func composePixelBuffer(with request: AVAsynchronousVideoCompositionRequest) -> CVPixelBuffer? {
    if isDepthPreviewEnabled {
      return request.sourceFrame(byTrackID: depthTrackID)
    }
    if !isPortraitModeEnabled {
      return request.sourceFrame(byTrackID: videoTrackID)
    }
    guard
      let videoPixelBuffer = request.sourceFrame(byTrackID: videoTrackID),
      let depthPixelBuffer = request.sourceFrame(byTrackID: depthTrackID)
    else {
      return nil
    }
    guard
      let depthBlurImage = depthBlurEffect.makeEffectImage(
        depthPixelBuffer: HSPixelBuffer(pixelBuffer: depthPixelBuffer),
        videoPixelBuffer: HSPixelBuffer(pixelBuffer: videoPixelBuffer)
      ),
      let outputPixelBuffer = renderContext?.newPixelBuffer()
    else {
      return nil
    }
    context.render(depthBlurImage, to: outputPixelBuffer)
    return outputPixelBuffer
  }

  // MARK: - AVVideoCompositing implementation

  var sourcePixelBufferAttributes = [
    kCVPixelBufferPixelFormatTypeKey: [kCVPixelFormatType_32BGRA],
  ] as [String: Any]?

  var requiredPixelBufferAttributesForRenderContext = [
    kCVPixelBufferPixelFormatTypeKey: [kCVPixelFormatType_32BGRA],
  ] as [String: Any]

  var shouldCancelAllRequests: Bool = false

  func renderContextChanged(_ newContext: AVVideoCompositionRenderContext) {
    renderingContextQueue.sync {
      renderContext = newContext
    }
  }

  func startRequest(_ request: AVAsynchronousVideoCompositionRequest) {
    autoreleasepool {
      renderingQueue.sync { // TODO: sync or async?
        if self.shouldCancelAllRequests {
          request.finishCancelledRequest()
          return
        }
        guard let pixelBuffer = self.composePixelBuffer(with: request) else {
          request.finish(with: VideoCompositionRequestError.failedToComposePixelBuffer)
          return
        }
        request.finish(withComposedVideoFrame: pixelBuffer)
      }
    }
  }

  func cancelAllPendingVideoCompositionRequests() {
    renderingQueue.sync {
      shouldCancelAllRequests = true
    }
    renderingQueue.async {
      self.shouldCancelAllRequests = false
    }
  }
}
