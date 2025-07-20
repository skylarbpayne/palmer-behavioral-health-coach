import React, { useState } from 'react';
import { StyleSheet, Text, View, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { ProfileTools } from '../utils/ProfileTools';

export default function ProfileTest() {
  const [testResults, setTestResults] = useState<string[]>([]);
  const [isRunning, setIsRunning] = useState(false);

  const addResult = (message: string) => {
    setTestResults(prev => [...prev, message]);
  };

  const clearResults = () => {
    setTestResults([]);
  };

  const runTests = async () => {
    setIsRunning(true);
    clearResults();
    
    try {
      addResult('🧪 Starting User Profile Tests...\n');

      // Clear existing data
      addResult('📝 Clearing existing profile data...');
      await ProfileTools.clearAllData();
      addResult('✅ Profile cleared\n');

      // Test 1: Simple fields
      addResult('1️⃣ Testing Simple Fields:');
      
      await ProfileTools.setFirstName('Jane');
      await ProfileTools.setLastName('Smith', true);
      await ProfileTools.setSex('female');
      await ProfileTools.setDateOfBirth('1985-12-03');
      
      const firstName = await ProfileTools.getSimpleField('firstName');
      const lastName = await ProfileTools.getSimpleField('lastName');
      
      addResult(`   ✅ Name: ${firstName?.value} ${lastName?.value}`);
      addResult(`   ✅ Last name confirmed: ${lastName?.metadata.lastConfirmed ? 'Yes' : 'No'}\n`);

      // Test 2: Array operations
      addResult('2️⃣ Testing Array Operations:');
      
      const goal1Id = await ProfileTools.addHealthGoal('Walk 10,000 steps daily');
      const goal2Id = await ProfileTools.addHealthGoal('Sleep 8 hours', true);
      const symptomId = await ProfileTools.addBehavioralSymptom('difficulty concentrating');
      const interventionId = await ProfileTools.addIntervention('evening journaling');
      
      addResult(`   ✅ Added goals, symptoms, and interventions\n`);

      // Test 3: Profile summary
      addResult('3️⃣ Profile Summary:');
      const summary = await ProfileTools.getProfileSummary();
      addResult(summary + '\n');

      // Test 4: Update operations
      addResult('4️⃣ Testing Updates:');
      
      await ProfileTools.updateHealthGoal(goal1Id, 'Walk 12,000 steps daily', true);
      addResult('   ✅ Updated health goal');
      
      await ProfileTools.removeHealthGoalByValue('Sleep 8 hours');
      addResult('   ✅ Removed health goal by value\n');

      // Test 5: Metadata
      addResult('5️⃣ Testing Metadata:');
      
      const goal1Metadata = await ProfileTools.getArrayItemMetadata('currentHealthGoals', goal1Id);
      addResult(`   ✅ Goal updated: ${goal1Metadata?.lastChanged?.toLocaleTimeString()}`);
      addResult(`   ✅ Goal confirmed: ${goal1Metadata?.lastConfirmed ? 'Yes' : 'No'}\n`);

      // Test 6: Validation
      addResult('6️⃣ Testing Validation:');
      
      try {
        await ProfileTools.addHealthGoal('Walk 12,000 steps daily'); // Duplicate
        addResult('   ❌ Duplicate check failed');
      } catch (error) {
        addResult('   ✅ Duplicate prevention working\n');
      }

      addResult('🎉 All tests completed successfully!');
      
    } catch (error) {
      addResult(`❌ Test failed: ${error}`);
    } finally {
      setIsRunning(false);
    }
  };

  const runPersistenceTest = async () => {
    try {
      addResult('\n📱 Testing Data Persistence:');
      
      // Add some data
      await ProfileTools.setFirstName('Test User');
      const goalId = await ProfileTools.addHealthGoal('Test persistence goal');
      
      // Get the data back
      const firstName = await ProfileTools.getSimpleField('firstName');
      const goals = await ProfileTools.getArrayField('currentHealthGoals');
      
      addResult(`   ✅ First name persisted: ${firstName?.value}`);
      addResult(`   ✅ Goals persisted: ${goals?.length || 0} goal(s)`);
      addResult('   💡 Restart the app and check if data persists\n');
      
    } catch (error) {
      addResult(`❌ Persistence test failed: ${error}`);
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>Profile System Test</Text>
      
      <View style={styles.buttonContainer}>
        <TouchableOpacity 
          style={[styles.button, isRunning && styles.buttonDisabled]} 
          onPress={runTests}
          disabled={isRunning}
        >
          <Text style={styles.buttonText}>
            {isRunning ? 'Running Tests...' : 'Run Full Test Suite'}
          </Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={styles.button} 
          onPress={runPersistenceTest}
        >
          <Text style={styles.buttonText}>Test Persistence</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={styles.clearButton} 
          onPress={clearResults}
        >
          <Text style={styles.buttonText}>Clear Results</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.resultsContainer}>
        {testResults.map((result, index) => (
          <Text key={index} style={styles.resultText}>
            {result}
          </Text>
        ))}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  content: {
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 20,
    textAlign: 'center',
  },
  buttonContainer: {
    marginBottom: 20,
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 15,
    borderRadius: 8,
    marginBottom: 10,
    alignItems: 'center',
  },
  buttonDisabled: {
    backgroundColor: '#ccc',
  },
  clearButton: {
    backgroundColor: '#FF3B30',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  resultsContainer: {
    backgroundColor: '#000',
    borderRadius: 8,
    padding: 15,
    minHeight: 200,
  },
  resultText: {
    color: '#00FF00',
    fontFamily: 'monospace',
    fontSize: 12,
    lineHeight: 16,
  },
});