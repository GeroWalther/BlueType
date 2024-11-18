import {Pressable, Text, StyleSheet} from 'react-native';
import React from 'react';

const Button = ({onPress, children, disconnect = false}: any) => {
  return (
    <Pressable
      style={[
        styles.baseButton,
        disconnect ? styles.disconnectButton : styles.connectButton,
      ]}
      onPress={onPress}>
      <Text style={styles.text}>{children}</Text>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  baseButton: {
    borderRadius: 12,
    paddingVertical: 6,
    paddingHorizontal: 16,
    marginHorizontal: 10,
    marginTop: 10,
  },
  connectButton: {
    backgroundColor: '#1E3A8A',
  },
  disconnectButton: {
    backgroundColor: '#EF4444',
    paddingVertical: 4,
    paddingHorizontal: 8,
    marginTop: 2,
  },
  text: {
    color: '#FFFFFF',
    fontSize: 20,
    fontWeight: '600',
  },
});

export default Button;
