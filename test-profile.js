// Test script for user profile system
// Run with: node test-profile.js

const { ProfileTools } = require('./dist/utils/ProfileTools');

async function testUserProfile() {
  console.log('🧪 Testing User Profile System\n');

  try {
    // Clear any existing data
    console.log('📝 Clearing existing profile data...');
    await ProfileTools.clearAllData();
    
    // Test 1: Simple field operations
    console.log('\n1️⃣ Testing Simple Fields:');
    
    await ProfileTools.setFirstName('John');
    await ProfileTools.setLastName('Doe', true); // with confirmation
    await ProfileTools.setSex('male');
    await ProfileTools.setDateOfBirth('1990-05-15');
    
    const firstName = await ProfileTools.getSimpleField('firstName');
    const lastName = await ProfileTools.getSimpleField('lastName');
    
    console.log(`   ✅ Name: ${firstName?.value} ${lastName?.value}`);
    console.log(`   ✅ First name metadata:`, firstName?.metadata);
    console.log(`   ✅ Last name confirmed:`, lastName?.metadata.lastConfirmed ? 'Yes' : 'No');
    
    // Test 2: Array operations
    console.log('\n2️⃣ Testing Array Operations:');
    
    const goal1Id = await ProfileTools.addHealthGoal('Exercise 30 minutes daily');
    const goal2Id = await ProfileTools.addHealthGoal('Drink 8 glasses of water', true);
    const symptom1Id = await ProfileTools.addBehavioralSymptom('low energy');
    const intervention1Id = await ProfileTools.addIntervention('morning meditation');
    
    console.log(`   ✅ Added health goal 1 (ID: ${goal1Id})`);
    console.log(`   ✅ Added health goal 2 (ID: ${goal2Id}) - confirmed`);
    console.log(`   ✅ Added symptom (ID: ${symptom1Id})`);
    console.log(`   ✅ Added intervention (ID: ${intervention1Id})`);
    
    // Test 3: Get profile summary
    console.log('\n3️⃣ Profile Summary:');
    const summary = await ProfileTools.getProfileSummary();
    console.log(summary);
    
    // Test 4: Detailed summary with timestamps
    console.log('\n4️⃣ Detailed Summary:');
    const detailedSummary = await ProfileTools.getDetailedProfileSummary();
    console.log(detailedSummary);
    
    // Test 5: Item management
    console.log('\n5️⃣ Testing Item Management:');
    
    // Update a goal
    await ProfileTools.updateHealthGoal(goal1Id, 'Exercise 45 minutes daily', true);
    console.log('   ✅ Updated health goal 1');
    
    // Remove a goal by value
    await ProfileTools.removeHealthGoalByValue('Drink 8 glasses of water');
    console.log('   ✅ Removed health goal 2 by value');
    
    // Test 6: Metadata access
    console.log('\n6️⃣ Testing Metadata Access:');
    
    const goal1Metadata = await ProfileTools.getArrayItemMetadata('currentHealthGoals', goal1Id);
    console.log(`   ✅ Goal 1 last changed: ${goal1Metadata?.lastChanged}`);
    console.log(`   ✅ Goal 1 confirmed: ${goal1Metadata?.lastConfirmed ? 'Yes' : 'No'}`);
    
    const firstNameMetadata = await ProfileTools.getSimpleFieldMetadata('firstName');
    console.log(`   ✅ First name last changed: ${firstNameMetadata?.lastChanged}`);
    
    // Test 7: Final profile state
    console.log('\n7️⃣ Final Profile State:');
    const finalProfile = await ProfileTools.getProfile();
    console.log('   Full profile structure:');
    console.log(JSON.stringify(finalProfile, null, 2));
    
    // Test 8: Data validation
    console.log('\n8️⃣ Testing Data Validation:');
    
    try {
      await ProfileTools.setSex('invalid'); // Should fail validation
      console.log('   ❌ Validation failed - this should not appear');
    } catch (error) {
      console.log('   ✅ Sex validation working:', error.message);
    }
    
    try {
      await ProfileTools.addHealthGoal('Exercise 45 minutes daily'); // Duplicate
      console.log('   ❌ Duplicate check failed');
    } catch (error) {
      console.log('   ✅ Duplicate prevention working:', error.message);
    }
    
    console.log('\n🎉 All tests completed successfully!');
    
  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}

// Only run if this file is executed directly
if (require.main === module) {
  testUserProfile().catch(console.error);
}

module.exports = { testUserProfile };