import React from 'react';
import {View, TouchableOpacity, Text, StyleSheet} from 'react-native';

const TrackpadComponent = () => {
  return (
    <View style={styles.container}>
      <TouchableOpacity
        style={styles.trackpad}
        onPress={() => console.log('Trackpad pressed')}>
        <Text style={styles.trackpadText}>Trackpad</Text>
      </TouchableOpacity>
      <View style={styles.buttonRow}>
        <TouchableOpacity
          style={styles.leftClick}
          onPress={() => console.log('Left Click')}>
          <Text style={styles.buttonText}>Left Click</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.rightClick}
          onPress={() => console.log('Right Click')}>
          <Text style={styles.buttonText}>Right Click</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    flex: 1,
    marginTop: 10,
    marginBottom: 5,
  },
  trackpad: {
    flex: 1,
    width: '95%',
    // height: '60%',
    backgroundColor: '#2c323b',
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 12,
  },
  trackpadText: {
    color: '#3d495a',
    fontSize: 18,
  },
  buttonRow: {
    width: '95%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 8,
  },
  leftClick: {
    flex: 2,
    height: 80,
    backgroundColor: '#372f8f',
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 12,
    marginRight: 8,
  },
  rightClick: {
    flex: 1,
    height: 80,
    backgroundColor: '#163053',
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 12,
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 18,
  },
});

export default TrackpadComponent;
