import UserProfileService from '../services/UserProfileService';
import { 
  UserProfile, 
  ProfileSimpleFieldKey, 
  ProfileArrayFieldKey,
  FieldMetadata 
} from '../types/UserProfile';

const profileService = UserProfileService.getInstance();

export const ProfileTools = {
  // Simple field operations
  async setFirstName(firstName: string, confirm: boolean = false): Promise<void> {
    await profileService.updateSimpleField('firstName', firstName, confirm);
  },

  async setLastName(lastName: string, confirm: boolean = false): Promise<void> {
    await profileService.updateSimpleField('lastName', lastName, confirm);
  },

  async setSex(sex: 'male' | 'female' | 'intersex', confirm: boolean = false): Promise<void> {
    await profileService.updateSimpleField('sex', sex, confirm);
  },

  async setGender(gender: string, confirm: boolean = false): Promise<void> {
    await profileService.updateSimpleField('gender', gender, confirm);
  },

  async setDateOfBirth(dateOfBirth: string, confirm: boolean = false): Promise<void> {
    await profileService.updateSimpleField('dateOfBirth', dateOfBirth, confirm);
  },

  async setSexualOrientation(orientation: string, confirm: boolean = false): Promise<void> {
    await profileService.updateSimpleField('sexualOrientation', orientation, confirm);
  },

  // Array field operations
  async addHealthGoal(goal: string, confirm: boolean = false): Promise<string> {
    const currentGoals = await profileService.getArrayField('currentHealthGoals') || [];
    const goalExists = currentGoals.some(item => item.value === goal);
    
    if (!goalExists) {
      return await profileService.addArrayItem('currentHealthGoals', goal, confirm);
    } else {
      throw new Error('Health goal already exists');
    }
  },

  async removeHealthGoal(goalId: string): Promise<void> {
    await profileService.removeArrayItem('currentHealthGoals', goalId);
  },

  async removeHealthGoalByValue(goal: string): Promise<void> {
    const currentGoals = await profileService.getArrayField('currentHealthGoals') || [];
    const goalItem = currentGoals.find(item => item.value === goal);
    if (goalItem) {
      await profileService.removeArrayItem('currentHealthGoals', goalItem.id);
    }
  },

  async updateHealthGoal(goalId: string, newGoal: string, confirm: boolean = false): Promise<void> {
    await profileService.updateArrayItem('currentHealthGoals', goalId, newGoal, confirm);
  },

  async addBehavioralSymptom(symptom: string, confirm: boolean = false): Promise<string> {
    const currentSymptoms = await profileService.getArrayField('currentBehavioralHealthSymptoms') || [];
    const symptomExists = currentSymptoms.some(item => item.value === symptom);
    
    if (!symptomExists) {
      return await profileService.addArrayItem('currentBehavioralHealthSymptoms', symptom, confirm);
    } else {
      throw new Error('Behavioral symptom already exists');
    }
  },

  async removeBehavioralSymptom(symptomId: string): Promise<void> {
    await profileService.removeArrayItem('currentBehavioralHealthSymptoms', symptomId);
  },

  async removeBehavioralSymptomByValue(symptom: string): Promise<void> {
    const currentSymptoms = await profileService.getArrayField('currentBehavioralHealthSymptoms') || [];
    const symptomItem = currentSymptoms.find(item => item.value === symptom);
    if (symptomItem) {
      await profileService.removeArrayItem('currentBehavioralHealthSymptoms', symptomItem.id);
    }
  },

  async updateBehavioralSymptom(symptomId: string, newSymptom: string, confirm: boolean = false): Promise<void> {
    await profileService.updateArrayItem('currentBehavioralHealthSymptoms', symptomId, newSymptom, confirm);
  },

  async addIntervention(intervention: string, confirm: boolean = false): Promise<string> {
    const currentInterventions = await profileService.getArrayField('currentInterventions') || [];
    const interventionExists = currentInterventions.some(item => item.value === intervention);
    
    if (!interventionExists) {
      return await profileService.addArrayItem('currentInterventions', intervention, confirm);
    } else {
      throw new Error('Intervention already exists');
    }
  },

  async removeIntervention(interventionId: string): Promise<void> {
    await profileService.removeArrayItem('currentInterventions', interventionId);
  },

  async removeInterventionByValue(intervention: string): Promise<void> {
    const currentInterventions = await profileService.getArrayField('currentInterventions') || [];
    const interventionItem = currentInterventions.find(item => item.value === intervention);
    if (interventionItem) {
      await profileService.removeArrayItem('currentInterventions', interventionItem.id);
    }
  },

  async updateIntervention(interventionId: string, newIntervention: string, confirm: boolean = false): Promise<void> {
    await profileService.updateArrayItem('currentInterventions', interventionId, newIntervention, confirm);
  },

  // Get operations
  async getProfile(): Promise<UserProfile> {
    return await profileService.getAllFields();
  },

  async getSimpleField<K extends ProfileSimpleFieldKey>(field: K): Promise<UserProfile[K]> {
    return await profileService.getSimpleField(field);
  },

  async getArrayField<K extends ProfileArrayFieldKey>(field: K): Promise<UserProfile[K]> {
    return await profileService.getArrayField(field);
  },

  // Confirmation operations
  async confirmSimpleField<K extends ProfileSimpleFieldKey>(field: K): Promise<void> {
    await profileService.confirmSimpleField(field);
  },

  async confirmArrayItem<K extends ProfileArrayFieldKey>(field: K, itemId: string): Promise<void> {
    await profileService.confirmArrayItem(field, itemId);
  },

  // Metadata operations
  async getSimpleFieldMetadata<K extends ProfileSimpleFieldKey>(field: K): Promise<FieldMetadata | undefined> {
    return await profileService.getSimpleFieldMetadata(field);
  },

  async getArrayItemMetadata<K extends ProfileArrayFieldKey>(field: K, itemId: string): Promise<FieldMetadata | undefined> {
    return await profileService.getArrayItemMetadata(field, itemId);
  },

  // Utility operations
  async hasSimpleField<K extends ProfileSimpleFieldKey>(field: K): Promise<boolean> {
    const fieldData = await profileService.getSimpleField(field);
    return fieldData !== undefined && fieldData.value !== null && fieldData.value !== '';
  },

  async hasArrayItems<K extends ProfileArrayFieldKey>(field: K): Promise<boolean> {
    const arrayData = await profileService.getArrayField(field);
    return arrayData !== undefined && arrayData.length > 0;
  },

  async getProfileSummary(): Promise<string> {
    const profile = await profileService.getAllFields();
    const parts: string[] = [];

    if (profile.firstName?.value || profile.lastName?.value) {
      parts.push(`Name: ${profile.firstName?.value || ''} ${profile.lastName?.value || ''}`.trim());
    }
    
    if (profile.sex?.value) parts.push(`Sex: ${profile.sex.value}`);
    if (profile.gender?.value) parts.push(`Gender: ${profile.gender.value}`);
    if (profile.dateOfBirth?.value) parts.push(`Date of Birth: ${profile.dateOfBirth.value}`);
    if (profile.sexualOrientation?.value) parts.push(`Sexual Orientation: ${profile.sexualOrientation.value}`);
    
    if (profile.currentHealthGoals?.length) {
      const goals = profile.currentHealthGoals.map(item => item.value).join(', ');
      parts.push(`Health Goals: ${goals}`);
    }
    
    if (profile.currentBehavioralHealthSymptoms?.length) {
      const symptoms = profile.currentBehavioralHealthSymptoms.map(item => item.value).join(', ');
      parts.push(`Current Symptoms: ${symptoms}`);
    }
    
    if (profile.currentInterventions?.length) {
      const interventions = profile.currentInterventions.map(item => item.value).join(', ');
      parts.push(`Current Interventions: ${interventions}`);
    }

    return parts.length > 0 ? parts.join('\n') : 'No profile information available';
  },

  async getDetailedProfileSummary(): Promise<string> {
    const profile = await profileService.getAllFields();
    const parts: string[] = [];

    // Helper function to format dates
    const formatDate = (date: Date) => date.toLocaleDateString();

    if (profile.firstName?.value || profile.lastName?.value) {
      const name = `${profile.firstName?.value || ''} ${profile.lastName?.value || ''}`.trim();
      let nameInfo = `Name: ${name}`;
      if (profile.firstName?.metadata.lastChanged) {
        nameInfo += ` (updated: ${formatDate(profile.firstName.metadata.lastChanged)})`;
      }
      parts.push(nameInfo);
    }
    
    if (profile.sex?.value) {
      let sexInfo = `Sex: ${profile.sex.value}`;
      if (profile.sex.metadata.lastChanged) {
        sexInfo += ` (updated: ${formatDate(profile.sex.metadata.lastChanged)})`;
      }
      parts.push(sexInfo);
    }

    if (profile.currentHealthGoals?.length) {
      parts.push('Health Goals:');
      profile.currentHealthGoals.forEach(goal => {
        let goalInfo = `  - ${goal.value}`;
        if (goal.metadata.lastChanged) {
          goalInfo += ` (added: ${formatDate(goal.metadata.lastChanged)})`;
        }
        if (goal.metadata.lastConfirmed) {
          goalInfo += ` (confirmed: ${formatDate(goal.metadata.lastConfirmed)})`;
        }
        parts.push(goalInfo);
      });
    }

    // Similar detailed formatting for other fields...

    return parts.length > 0 ? parts.join('\n') : 'No profile information available';
  },

  async clearAllData(): Promise<void> {
    await profileService.clearProfile();
  }
};

export const LLMProfileTools = {
  description: "Tools for managing user profile information with item-level metadata tracking",
  tools: [
    {
      name: "setFirstName",
      description: "Set the user's first name",
      parameters: { firstName: "string", confirm: "boolean (optional)" }
    },
    {
      name: "setLastName", 
      description: "Set the user's last name",
      parameters: { lastName: "string", confirm: "boolean (optional)" }
    },
    {
      name: "setSex",
      description: "Set the user's biological sex",
      parameters: { sex: "'male' | 'female' | 'intersex'", confirm: "boolean (optional)" }
    },
    {
      name: "setGender",
      description: "Set the user's gender identity",
      parameters: { gender: "string", confirm: "boolean (optional)" }
    },
    {
      name: "setDateOfBirth",
      description: "Set the user's date of birth (YYYY-MM-DD format)",
      parameters: { dateOfBirth: "string", confirm: "boolean (optional)" }
    },
    {
      name: "setSexualOrientation",
      description: "Set the user's sexual orientation",
      parameters: { orientation: "string", confirm: "boolean (optional)" }
    },
    {
      name: "addHealthGoal",
      description: "Add a health goal to the user's profile (returns item ID)",
      parameters: { goal: "string", confirm: "boolean (optional)" },
      returns: "string (item ID)"
    },
    {
      name: "removeHealthGoalByValue",
      description: "Remove a health goal by its value",
      parameters: { goal: "string" }
    },
    {
      name: "removeHealthGoal",
      description: "Remove a health goal by its ID",
      parameters: { goalId: "string" }
    },
    {
      name: "updateHealthGoal",
      description: "Update a health goal by ID",
      parameters: { goalId: "string", newGoal: "string", confirm: "boolean (optional)" }
    },
    {
      name: "addBehavioralSymptom",
      description: "Add a behavioral health symptom (avoid diagnostic labels)",
      parameters: { symptom: "string", confirm: "boolean (optional)" },
      returns: "string (item ID)"
    },
    {
      name: "removeBehavioralSymptomByValue",
      description: "Remove a behavioral health symptom by its value",
      parameters: { symptom: "string" }
    },
    {
      name: "removeBehavioralSymptom",
      description: "Remove a behavioral health symptom by its ID",
      parameters: { symptomId: "string" }
    },
    {
      name: "addIntervention",
      description: "Add an intervention the user is currently attempting",
      parameters: { intervention: "string", confirm: "boolean (optional)" },
      returns: "string (item ID)"
    },
    {
      name: "removeInterventionByValue",
      description: "Remove an intervention by its value",
      parameters: { intervention: "string" }
    },
    {
      name: "removeIntervention",
      description: "Remove an intervention by its ID", 
      parameters: { interventionId: "string" }
    },
    {
      name: "getProfile",
      description: "Get the complete user profile with all metadata",
      parameters: {}
    },
    {
      name: "getProfileSummary",
      description: "Get a readable summary of the user's profile",
      parameters: {}
    },
    {
      name: "getDetailedProfileSummary",
      description: "Get a detailed summary including timestamps",
      parameters: {}
    },
    {
      name: "confirmSimpleField",
      description: "Mark a simple field as confirmed by the user",
      parameters: { field: "ProfileSimpleFieldKey" }
    },
    {
      name: "confirmArrayItem",
      description: "Mark an array item as confirmed by the user",
      parameters: { field: "ProfileArrayFieldKey", itemId: "string" }
    }
  ]
};

export default ProfileTools;