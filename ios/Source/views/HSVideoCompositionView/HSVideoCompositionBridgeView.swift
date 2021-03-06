import React
import UIKit

@objc
class HSVideoCompositionBridgeView: HSVideoCompositionView {
  @objc
  public var onPlaybackProgress: RCTDirectEventBlock?

  @objc
  public var onPlaybackStateChange: RCTDirectEventBlock?

  @objc
  public var onMetadataLoaded: RCTDirectEventBlock?

  @objc
  public var onDidPlayToEnd: RCTDirectEventBlock?
}
