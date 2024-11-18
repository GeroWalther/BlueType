import React from 'react';
import {NativeModules, Button, ScrollView, View} from 'react-native';

const {BLEHIDManager} = NativeModules;
console.log('BLEHIDManager', BLEHIDManager);

export default function BaseTest({navigation}: any) {
  const onPress = (key: String) => {
    BLEHIDManager.sendKeys(key);
  };

  const moveMouse = (direction: String) => {
    BLEHIDManager.moveMouse(direction);
  };

  const mouseClick = (button: String) => {
    BLEHIDManager.mouseClick(button);
  };
  return (
    <ScrollView>
      <View
        style={{
          backgroundColor: '#07172f',
        }}>
        <Button title="A" color="#841584" onPress={() => onPress('A')} />

        <Button title="B" color="#841584" onPress={() => onPress('B')} />

        <Button
          title="Move Mouse right"
          color="#841584"
          onPress={() => moveMouse('right')}
        />

        <Button
          title="Move Mouse left"
          color="#841584"
          onPress={() => moveMouse('left')}
        />

        <Button
          title="Move Mouse Up"
          color="#841584"
          onPress={() => moveMouse('up')}
        />

        <Button
          title="Move Mouse down"
          color="#841584"
          onPress={() => moveMouse('down')}
        />

        <Button
          title="RightClick"
          color="#841584"
          onPress={() => mouseClick('right')}
        />

        <Button
          title="LeftClick"
          color="#841584"
          onPress={() => mouseClick('left')}
        />
      </View>
      <View>
        <Button
          title="To ControlScreen"
          color="#158484"
          onPress={() => {
            navigation.navigate('ControlScreen');
          }}
        />
      </View>
    </ScrollView>
  );
}
