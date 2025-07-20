import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaView, StyleSheet } from 'react-native';
import HealthSummary from './components/HealthSummary';
import ChatScreen from './components/ChatScreen';
import ChatDebug from './components/ChatDebug';

const Tab = createBottomTabNavigator();

export default function App() {
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar style="auto" />
      <NavigationContainer>
        <Tab.Navigator
          screenOptions={{
            tabBarActiveTintColor: '#4CAF50',
            tabBarInactiveTintColor: '#666',
            headerStyle: {
              backgroundColor: '#4CAF50',
            },
            headerTintColor: '#fff',
            headerTitleStyle: {
              fontWeight: 'bold',
            },
          }}
        >
          <Tab.Screen 
            name="Summary" 
            component={HealthSummary}
            options={{
              title: 'Health Summary',
              tabBarLabel: 'Summary',
            }}
          />
          <Tab.Screen 
            name="Chat" 
            component={ChatScreen}
            options={{
              title: 'Health Coach',
              tabBarLabel: 'Chat',
            }}
          />
          <Tab.Screen 
            name="Debug" 
            component={ChatDebug}
            options={{
              title: 'Chat Debug',
              tabBarLabel: 'Debug',
            }}
          />
        </Tab.Navigator>
      </NavigationContainer>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
});
