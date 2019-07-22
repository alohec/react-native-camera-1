// @flow
import React, { Component } from 'react';
import {
  View,
  Animated,
  TouchableWithoutFeedback,
  MaskedViewIOS,
  Easing,
} from 'react-native';
import { autobind } from 'core-decorators';

import type { Style } from '../../types';

type Props = {
  style?: ?Style,
  onRequestBeginCapture: () => void,
  onRequestEndCapture: () => void,
};

const styles = {
  outerViewAnim: (anim: Animated.Value) => ({
    height: 75,
    width: 75,
    borderRadius: 37.5,
    transform: [{ scale: anim }],
    shadowColor: '#000',
    shadowOpacity: 0.25,
    shadowOffset: {
      width: 1,
      height: 4,
    },
    shadowRadius: 5,
    alignItems: 'center',
    justifyContent: 'center',
  }),
  centerAnim: (anim: Animated.Value) => ({
    transform: [{ scale: anim }],
    height: 65,
    width: 65,
    borderRadius: 32.5,
    overflow: 'hidden',
    backgroundColor: '#fff',
  }),
  border: {
    height: 75,
    width: 75,
    borderRadius: 37.5,
    borderWidth: 4,
    borderColor: '#fff',
    position: 'absolute',
  },
  borderMask: {
    height: 75,
    width: 75,
    borderRadius: 37.5,
    position: 'absolute',
  },
  inner: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#fff',
  },
  progress: {
    height: 75,
    width: 75,
    borderRadius: 37.5,
    position: 'absolute',
  },
};

// $FlowFixMe
@autobind
export class CaptureButton extends Component<Props> {
  outerViewAnim: Animated.Value = new Animated.Value(1);
  centerViewAnim: Animated.Value = new Animated.Value(1);

  touchableOnPressIn() {
    Animated.spring(this.outerViewAnim, {
      toValue: 0.95,
      duration: 250,
      useNativeDriver: true,
      easing: Easing.out(Easing.quad),
    }).start();
    Animated.spring(this.centerViewAnim, {
      toValue: 0.65,
      duration: 250,
      useNativeDriver: true,
      easing: Easing.out(Easing.quad),
    }).start();
    this.props.onRequestBeginCapture();
  }

  touchableOnPressOut() {
    Animated.spring(this.outerViewAnim, {
      toValue: 1.0,
      duration: 250,
      useNativeDriver: true,
      easing: Easing.out(Easing.quad),
    }).start();
    Animated.spring(this.centerViewAnim, {
      toValue: 1.0,
      duration: 250,
      useNativeDriver: true,
      easing: Easing.out(Easing.quad),
    }).start();
    this.props.onRequestEndCapture();
  }

  render() {
    return (
      <TouchableWithoutFeedback
        onPressIn={this.touchableOnPressIn}
        onPressOut={this.touchableOnPressOut}
      >
        <Animated.View style={styles.outerViewAnim(this.outerViewAnim)}>
          <Animated.View
            style={[styles.centerAnim(this.centerViewAnim), this.props.style]}
          />
          <MaskedViewIOS
            style={styles.borderMask}
            maskElement={<View style={styles.border} />}
          >
            <View style={styles.inner} />
          </MaskedViewIOS>
        </Animated.View>
      </TouchableWithoutFeedback>
    );
  }
}
