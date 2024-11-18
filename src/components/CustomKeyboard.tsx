import React, {useState} from 'react';
import {
  View,
  StyleSheet,
  Text,
  Pressable,
  Dimensions,
  NativeModules,
} from 'react-native';

const {BLEHIDManager} = NativeModules;
const {width} = Dimensions.get('window'); // Get the screen width

const CustomKeyboard = () => {
  const [isUppercase, setIsUppercase] = useState(false);
  const [isNumberPad, setIsNumberPad] = useState(false);
  const [isSpecialChar, setSpecialChar] = useState(false);
  const [isActive, setIsActive] = useState(true);

  const keyboardLayout = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', '.'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', 'DELETE'],
    ['ESC', 'SPACE', 'ENTER'],
  ];

  const specialCharsLayout = [
    ['!', '@', '#', '$', '%', '^'],
    ['&', '*', '(', ')', ';', ':'],
    ['/', '?', '<', '>', '_', '-'],
    ['+', '=', '[', ']', '{', '}'],
  ];

  const numberPadLayout = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['0', 'ENTER'],
  ];

  const arrowPadLayout = [['UP'], ['LEFT', 'DOWN', 'RIGHT']];

  const handleKeyPress = (key: string) => {
    console.log(`Key pressed and sent: ${key}`);
    if (
      key === 'space' ||
      key === 'enter' ||
      key === 'esc' ||
      key === 'delete'
    ) {
      BLEHIDManager.sendKeys(key.toUpperCase());
    }
    BLEHIDManager.sendKeys(key);
  };

  const handleUppercaseToggle = () => {
    setIsUppercase(!isUppercase);
    BLEHIDManager.sendKeys('CAPSLOCK'); // Simulate CAPSLOCK press
  };

  const handleSpecialCharToggle = () => {
    setSpecialChar(!isSpecialChar);
    setIsNumberPad(false);
  };

  const handleNumberPadToggle = () => {
    setIsNumberPad(!isNumberPad);
    setSpecialChar(false);
  };

  const handleKeyboardToggle = () => {
    setIsActive(!isActive); // Toggles the keyboard visibility
  };

  return (
    <View style={styles.rootContainer}>
      {/* Toggle to activate/deactivate the keyboard */}
      <Pressable onPress={handleKeyboardToggle} style={styles.toggle}>
        <Text style={styles.toggleText}>
          {isActive ? 'Hide Keyboard' : 'Show Keyboard'}
        </Text>
      </Pressable>

      {isActive && (
        <View style={styles.keyboardContainer}>
          {isNumberPad && !isSpecialChar && (
            <View style={styles.numberPadContainer}>
              {/* Number Pad */}
              <View style={styles.padSection}>
                {numberPadLayout.map((row, rowIndex) => (
                  <View key={rowIndex} style={styles.row}>
                    {row.map((key, keyIndex) => (
                      <Pressable
                        key={keyIndex}
                        style={[
                          styles.key,
                          styles.numKey,
                          key === 'ENTER' ? styles.numEnterKey : null,
                        ]}
                        onPress={() => handleKeyPress(key)}>
                        <Text style={styles.keyText}>{key}</Text>
                      </Pressable>
                    ))}
                  </View>
                ))}
              </View>
              {/* Arrow Pad */}
              <View style={styles.padSection}>
                {arrowPadLayout.map((row, rowIndex) => (
                  <View key={rowIndex} style={styles.row}>
                    {row.map((key, keyIndex) => (
                      <Pressable
                        key={keyIndex}
                        style={[styles.key, styles.arrowKey]}
                        onPress={() => handleKeyPress(key)}>
                        <Text style={styles.keyText}>{key}</Text>
                      </Pressable>
                    ))}
                  </View>
                ))}
              </View>
            </View>
          )}
          {isSpecialChar &&
            !isNumberPad &&
            specialCharsLayout.map((row, rowIndex) => (
              <View key={rowIndex} style={styles.row}>
                {row.map((key, keyIndex) => (
                  <Pressable
                    key={keyIndex}
                    style={[styles.key, styles.specKey]}
                    onPress={() => handleKeyPress(key)}>
                    <Text style={styles.keyText}>{key}</Text>
                  </Pressable>
                ))}
              </View>
            ))}
          {!isNumberPad &&
            !isSpecialChar &&
            keyboardLayout.map((row, rowIndex) => (
              <View key={rowIndex} style={styles.row}>
                {row.map((key, keyIndex) => (
                  <Pressable
                    key={keyIndex}
                    style={[
                      styles.key,
                      key === 'SPACE' ? styles.spaceKey : null,
                      key === 'ENTER' ? styles.enterKey : null,
                      key === 'ESC' ? styles.escKey : null,
                      key === 'DELETE' ? styles.deleteKey : null,
                    ]}
                    onPress={() =>
                      handleKeyPress(
                        isUppercase ? key.toUpperCase() : key.toLowerCase(),
                      )
                    }>
                    <Text style={styles.keyText}>
                      {isUppercase ? key.toUpperCase() : key.toLowerCase()}
                    </Text>
                  </Pressable>
                ))}
              </View>
            ))}

          <View style={styles.toggleContainer}>
            <Pressable
              style={styles.toggleButton}
              onPress={handleUppercaseToggle}>
              <Text style={styles.keyText}>{isUppercase ? 'Aa' : 'aA'}</Text>
            </Pressable>
            <Pressable
              style={styles.toggleButton}
              onPress={handleSpecialCharToggle}>
              <Text style={styles.keyText}>
                {isSpecialChar ? 'ABC' : '!@/_{)'}
              </Text>
            </Pressable>
            <Pressable
              style={styles.toggleButton}
              onPress={handleNumberPadToggle}>
              <Text style={styles.keyText}>{isNumberPad ? 'ABC' : '123'}</Text>
            </Pressable>
          </View>
        </View>
      )}
    </View>
  );
};

export default CustomKeyboard;

const styles = StyleSheet.create({
  rootContainer: {
    alignItems: 'center',
  },
  keyboardContainer: {
    backgroundColor: '#1F2937',
    borderRadius: 8,
    padding: 8,
    width: '100%',
    alignItems: 'center',
  },
  numberPadContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '100%',
  },
  padSection: {
    flex: 1,
    marginHorizontal: 5,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-evenly',
    marginBottom: '3%',
    width: '100%',
  },
  key: {
    width: width * 0.08,
    height: 60,
    backgroundColor: '#374151',
    marginHorizontal: 3,
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  specKey: {
    backgroundColor: '#093440',
    flex: 1,
  },
  numKey: {
    backgroundColor: '#20695a',
    flex: 1,
  },
  keyText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
  },
  spaceKey: {
    flex: 3,
    height: 60,
    backgroundColor: '#6B7280',
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  enterKey: {
    flex: 2,
    backgroundColor: '#10B981',
  },
  numEnterKey: {
    flex: 1,
    backgroundColor: '#10B981',
    marginHorizontal: 3,
  },
  escKey: {
    flex: 2,
    backgroundColor: '#3B82F6',
  },
  deleteKey: {
    flex: 2,
    backgroundColor: '#EF4444',
  },
  arrowKey: {
    backgroundColor: '#b042ec',
    borderRadius: 8,
    flex: 0.3,
    marginTop: 10,
  },
  toggleContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    // marginVertical: 5,
    width: '100%',
  },
  toggleButton: {
    flex: 0.3,
    height: 50,
    backgroundColor: '#374151',
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  toggleText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#10B981',
  },
  toggle: {
    padding: 5,
    borderRadius: 8,
    width: 180,
    backgroundColor: '#c1f0bf',
    justifyContent: 'center',
    alignItems: 'center',
  },
});
