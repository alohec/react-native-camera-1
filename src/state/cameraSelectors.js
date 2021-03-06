// @flow
import type { ICameraState } from './cameraState';

export const selectCaptureStatus = (state: ICameraState) =>
  state.getCaptureStatus();

export const selectIsCameraStarted = (state: ICameraState) =>
  selectCaptureStatus(state) === 'started';

export const selectSupportedISORange = (state: ICameraState) =>
  state.getSupportedISORange();

export const selectSupportedExposureRange = (state: ICameraState) =>
  state.getSupportedExposureRange();

export const selectISO = (state: ICameraState) => state.getISO();

export const selectExposure = (state: ICameraState) => state.getExposure();

export const selectSupportedFormats = (state: ICameraState) =>
  state.getSupportedFormats();

export const selectHasCameraPermissions = (state: ICameraState) =>
  state.hasCameraPermissions();

export const selectFormat = (state: ICameraState) => state.getFormat();

export const selectDepthFormat = (state: ICameraState) =>
  state.getDepthFormat();

export const selectBlurAperture = (state: ICameraState) =>
  state.getBlurAperture();

export const selectPlaybackStateMap = (state: ICameraState) =>
  state.getPlaybackStateMap();

export const selectPlaybackState = (state: ICameraState, assetID: string) =>
  state.getPlaybackState(assetID);

export const selectPlaybackProgress = (state: ICameraState) =>
  state.getPlaybackProgress();

export const selectLastCapturedVideoURL = (state: ICameraState) =>
  state.getLastCapturedVideoURL();

export const selectCameraDeviceSupport = (state: ICameraState) =>
  state.getCameraDeviceSupport();
