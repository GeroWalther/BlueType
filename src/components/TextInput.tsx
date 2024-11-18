import React, {useEffect, useState} from 'react';
import {
  TextInput,
  Pressable,
  Text,
  Keyboard,
  View,
  StyleSheet,
  TextInputProps,
} from 'react-native';

const Input = (
  props: React.JSX.IntrinsicAttributes &
    React.JSX.IntrinsicClassAttributes<TextInput> &
    Readonly<TextInputProps>,
) => {
  const dismissKeyboard = () => {
    Keyboard.dismiss();
  };
  const [isKeyboardVisible, setIsKeyboardVisible] = useState(false);

  useEffect(() => {
    const keyboardDidShowListener = Keyboard.addListener(
      'keyboardDidShow',
      () => {
        setIsKeyboardVisible(true);
      },
    );
    const keyboardDidHideListener = Keyboard.addListener(
      'keyboardDidHide',
      () => {
        setIsKeyboardVisible(false);
      },
    );
    return () => {
      keyboardDidShowListener.remove();
      keyboardDidHideListener.remove();
    };
  }, []);

  return (
    <View style={styles.container}>
      <TextInput
        style={styles.input}
        placeholder="Type here..."
        multiline
        autoCapitalize="none"
        {...props}
      />
      {isKeyboardVisible && (
        <Pressable onPress={dismissKeyboard} style={styles.dismissButton}>
          <Text style={styles.dismissButtonText}>Dismiss{'\n'}Keyboard</Text>
        </Pressable>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row', // flex-row
    marginVertical: 8, // my-2
  },
  input: {
    height: 56, // h-14
    borderWidth: 1, // border
    borderColor: '#D1D5DB', // border-gray-400
    paddingHorizontal: 12, // px-3
    backgroundColor: '#FFFFFF', // bg-white
    fontSize: 20, // text-xl
    paddingVertical: 8, // py-2
    flex: 1, // flex-1
  },
  dismissButton: {
    height: 56, // h-14
    padding: 8, // p-2
    borderRadius: 12, // rounded-lg
    backgroundColor: '#FB923C', // bg-orange-400
    justifyContent: 'center',
    alignItems: 'center',
  },
  dismissButtonText: {
    fontSize: 12, // text-sm
    textAlign: 'center', // text-center
  },
});

export default Input;
