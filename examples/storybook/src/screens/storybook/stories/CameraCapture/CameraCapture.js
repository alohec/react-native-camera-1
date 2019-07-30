// @flow
import React from 'react';
import { storiesOf } from '@storybook/react-native';
import { SafeAreaView, Modal, View } from 'react-native';
import { Provider } from 'react-redux';

import {
  CameraSettingIdentifiers,
  createCameraStateHOC,
  CameraCapture,
  requestCameraPermissions,
  startCameraPreview,
  CameraFormatList,
  CameraFormatListItem,
  filterBestAvailableFormats,
  uniqueKeyForFormat,
  setFormat
} from '@jonbrennecke/react-native-camera';

import { createReduxStore } from './cameraStore';
import { StorybookStateWrapper } from '../../utils';

const store = createReduxStore();

const styles = {
  flex: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
    backgroundColor: '#000',
  },
  camera: {
    flex: 1,
  },
  modal: {
    position: 'absolute',
    height: 300,
    width: '100%',
    backgroundColor: '#000',
    bottom: 0,
  }
};

const CameraStateContainer = createCameraStateHOC();

const Component = CameraStateContainer(
  ({
    startCapture,
    stopCapture,
    iso,
    exposure,
    supportedISORange,
    supportedExposureRange,
    supportedFormats,
    loadSupportedFeatures,
    updateISO,
    updateExposure,
  }) => {
    const setup = async (): Promise<void> => {
      try {
        await requestCameraPermissions();
        startCameraPreview();
        await loadSupportedFeatures();
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
      }
    };

    const bestAvailableFormats = filterBestAvailableFormats(supportedFormats);
    
    return (
      <StorybookStateWrapper
        initialState={{
          showFormatModal: false,
          cameraRef: React.createRef(),
          activeCameraSetting: CameraSettingIdentifiers.Exposure,
        }}
        onMount={setup}
        render={(getState, setState) => {
          return (
            <>
              <Modal
                transparent
                visible={getState().showFormatModal}
              >
                <View style={styles.modal}>
                  <CameraFormatList
                    style={styles.flex}
                    items={bestAvailableFormats}
                    keyForItem={({ format, depthFormat }) => uniqueKeyForFormat(format, depthFormat)}
                    renderItem={({ format, depthFormat }) => (
                      <CameraFormatListItem
                        format={format}
                        depthFormat={depthFormat}
                        onPress={() => setFormat(format)}
                      />
                    )}
                  />
                </View>
              </Modal>
              <CameraCapture
                style={styles.camera}
                cameraRef={getState().cameraRef}
                cameraSettings={{
                  [CameraSettingIdentifiers.ISO]: {
                    currentValue: iso,
                    supportedRange: supportedISORange,
                  },
                  [CameraSettingIdentifiers.Exposure]: {
                    currentValue: exposure,
                    supportedRange: supportedExposureRange,
                  },
                  [CameraSettingIdentifiers.ShutterSpeed]: {
                    currentValue: exposure,
                    supportedRange: supportedExposureRange,
                  }, // TODO
                  [CameraSettingIdentifiers.Focus]: {
                    currentValue: exposure,
                    supportedRange: supportedExposureRange,
                  }, // TODO
                  [CameraSettingIdentifiers.WhiteBalance]: {
                    currentValue: exposure,
                    supportedRange: supportedExposureRange,
                  }, // TODO
                }}
                supportedISORange={supportedISORange}
                activeCameraSetting={getState().activeCameraSetting}
                onRequestBeginCapture={startCapture}
                onRequestEndCapture={() =>
                  stopCapture({
                    saveToCameraRoll: true,
                  })
                }
                onRequestFocus={point => {
                  const { cameraRef } = getState();
                  if (cameraRef.current) {
                    cameraRef.current.focusOnPoint(point);
                  }
                }}
                onRequestChangeISO={iso => updateISO(iso)}
                onRequestChangeExposure={exposure => updateExposure(exposure)}
                onRequestSelectActiveCameraSetting={cameraSetting => {
                  setState({ activeCameraSetting: cameraSetting });
                }}
                onRequestShowFormatDialog={() => setState({ showFormatModal: true })}
              />
            </>
          );
        }}
      />
    );
  }
);

storiesOf('Camera', module).add('Camera Capture', () => (
  <Provider store={store}>
    <SafeAreaView style={styles.safeArea}>
      <Component />
    </SafeAreaView>
  </Provider>
));
