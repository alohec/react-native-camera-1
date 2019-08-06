import AVFoundation

@available(iOS 11.1, *)
internal func depthEnabledCaptureDevice(withPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
  let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [
    .builtInTrueDepthCamera, .builtInDualCamera,
  ], mediaType: .video, position: position)
  return discoverySession.devices.first
}

@available(iOS 10.0, *)
internal func getOppositeCamera(session: AVCaptureSession) -> AVCaptureDevice? {
  let position = getOppositeCameraPosition(session: session)
  return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
}

fileprivate func getOppositeCameraPosition(session: AVCaptureSession, defaultPosition: AVCaptureDevice.Position = .front) -> AVCaptureDevice.Position {
  let device = activeCaptureDevice(session: session)
  switch device?.position {
  case .some(.back):
    return .front
  case .some(.front):
    return .back
  default:
    return defaultPosition
  }
}

internal func activeCaptureDevicePosition(session: AVCaptureSession) -> AVCaptureDevice.Position? {
  let device = activeCaptureDevice(session: session)
  return device?.position
}

fileprivate func activeCaptureDevice(session: AVCaptureSession) -> AVCaptureDevice? {
  return session.inputs.reduce(nil) { (device, input) -> AVCaptureDevice? in
    if input.isKind(of: AVCaptureDeviceInput.classForCoder()) {
      let device = (input as! AVCaptureDeviceInput).device
      if device.position != .unspecified {
        return device
      }
    }
    return device
  }
}
