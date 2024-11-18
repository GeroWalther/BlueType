import React from 'react';
import {View, StyleSheet, Text} from 'react-native';
import Button from '../components/Button';
import TrackpadComponent from '../components/TrackPad';
import CustomKeyboard from '../components/CustomKeyboard';

const ControlScreen = ({navigation}: any) => {
  const [deviceName, _setDeviceName] = React.useState('Geros Mac');

  return (
    <View style={styles.screen}>
      <View style={styles.topSection}>
        <Button
          style={styles.btn}
          disconnect
          onPress={() => {
            // TODO: Disconnect the Bluetooth connection and navigate back to the main screen.
            navigation.navigate('BaseTest');
          }}>
          Disconnect
        </Button>
        <Text style={styles.textStyle}>Connected to: {deviceName}</Text>
      </View>

      <View style={styles.contentContainer}>
        <View style={styles.trackContainer}>
          <TrackpadComponent />
        </View>
        <CustomKeyboard />
      </View>
    </View>
  );
};

export default ControlScreen;

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: '#1b1f2b',
  },
  btn: {marginTop: 5},
  topSection: {
    alignItems: 'center',
    paddingHorizontal: 5,
  },
  textStyle: {
    fontSize: 18,
    fontWeight: '600',
    textAlign: 'center',
    marginTop: 10,
    color: '#ffffff',
  },
  contentContainer: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: '#1b1f2b',
  },
  trackContainer: {
    flex: 1,
  },
});
