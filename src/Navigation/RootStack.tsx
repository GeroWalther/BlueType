import React from 'react';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import BaseTest from '../Screens/BaseTest';
import ControlScreen from '../Screens/ControlScreen';
import ConnectivityScreen from '../Screens/ConnectivityScreen';

const Stack = createNativeStackNavigator();

export default function RootStack() {
  return (
    <Stack.Navigator initialRouteName="ConnectivityScreen">
      <Stack.Screen name="BaseTest" component={BaseTest} />
      <Stack.Screen name="ConnectivityScreen" component={ConnectivityScreen} />
      {/* <Stack.Screen name="ScanScreen" component={BaseTest} /> */}
      <Stack.Screen
        name="ControlScreen"
        component={ControlScreen}
        options={{
          headerShown: false,
        }}
      />
    </Stack.Navigator>
  );
}
