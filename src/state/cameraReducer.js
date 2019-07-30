// @flow
import { createReducer } from './createReducer';
import { createCameraState } from './cameraState';

import type { Action } from '../types';
import type {
  ICameraState,
  CameraCaptureStatus,
  CameraISORange,
  CameraExposureRange,
  CameraFormat,
} from './cameraState';

const CameraState = createCameraState({
  captureStatus: 'stopped',
  supportedISORange: { min: 0, max: 16000 },
  supportedExposureRange: { min: 0, max: 16000 },
  supportedFormats: [],
  iso: 0,
  exposure: 0,
  format: null,
  hasCameraPermissions: false,
});

export const initialState = new CameraState();

const reducers = {
  setCaptureStatus: (
    state,
    { payload }: Action<{ captureStatus: CameraCaptureStatus }>
  ): ICameraState => {
    if (!payload) {
      return state;
    }
    return state.setCaptureStatus(payload.captureStatus);
  },

  setSupportedISORange: (
    state,
    { payload }: Action<{ range: CameraISORange }>
  ): ICameraState => {
    if (!payload) {
      return state;
    }
    return state.setSupportedISORange(payload.range);
  },

  setSupportedExposureRange: (
    state,
    { payload }: Action<{ range: CameraExposureRange }>
  ): ICameraState => {
    if (!payload) {
      return state;
    }
    return state.setSupportedExposureRange(payload.range);
  },

  setSupportedFormats: (
    state,
    { payload }: Action<{ formats: CameraFormat[] }>
  ): ICameraState => {
    if (!payload) {
      return state;
    }
    return state.setSupportedFormats(payload.formats);
  },

  setISO: (state, { payload }: Action<{ iso: number }>): ICameraState => {
    if (!payload) {
      return state;
    }
    return state.setISO(payload.iso);
  },

  setExposure: (
    state,
    { payload }: Action<{ exposure: number }>
  ): ICameraState => {
    if (!payload) {
      return state;
    }
    return state.setExposure(payload.exposure);
  },

  setHasCameraPermissions: (
    state,
    { payload }: Action<{ hasCameraPermissions: boolean }>
  ): ICameraState => {
    if (!payload) {
      return state;
    }
    return state.setHasCameraPermissions(payload.hasCameraPermissions);
  },

  setFormat: (
    state,
    { payload }: Action<{ format: CameraFormat }>
  ): ICameraState => {
    if (!payload) {
      return state;
    }
    return state.setFormat(payload.format);
  },
};

export const {
  reducer,
  actionCreators: identityActionCreators,
} = createReducer(initialState, reducers);
