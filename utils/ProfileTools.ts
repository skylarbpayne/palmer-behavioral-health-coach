import UserProfileService from '../services/UserProfileService';
import { ProfileFieldKey, UserProfile } from '../types/UserProfile';

const profileService = UserProfileService.getInstance();

export const ProfileTools = {
  async setFirstName(firstName: string, confirm: boolean = false): Promise<void> {
    await profileService.updateField('firstName', firstName, confirm);
  },

  async setLastName(lastName: string, confirm: boolean = false): Promise<void> {
    await profileService.updateField('lastName', lastName, confirm);
  },

  async setSex(sex: 'male' | 'female' | 'intersex', confirm: boolean = false): Promise<void> {
    await profileService.updateField('sex', sex, confirm);
  },

  async setGender(gender: string, confirm: boolean = false): Promise<void> {
    await profileService.updateField('gender', gender, confirm);
  },

  async setDateOfBirth(dateOfBirth: string, confirm: boolean = false): Promise<void> {
    await profileService.updateField('dateOfBirth', dateOfBirth, confirm);
  },

  async setSexualOrientation(orientation: string, confirm: boolean = false): Promise<void> {
    await profileService.updateField('sexualOrientation', orientation, confirm);
  },

  async addHealthGoal(goal: string, confirm: boolean = false): Promise<void> {
    const currentGoals = await profileService.getField('currentHealthGoals') || [];
    if (!currentGoals.includes(goal)) {
      await profileService.updateField('currentHealthGoals', [...currentGoals, goal], confirm);
    }
  },

  async removeHealthGoal(goal: string, confirm: boolean = false): Promise<void> {
    const currentGoals = await profileService.getField('currentHealthGoals') || [];
    const updatedGoals = currentGoals.filter(g => g !== goal);
    await profileService.updateField('currentHealthGoals', updatedGoals, confirm);
  },

  async setHealthGoals(goals: string[], confirm: boolean = false): Promise<void> {
    await profileService.updateField('currentHealthGoals', goals, confirm);
  },

  async addBehavioralSymptom(symptom: string, confirm: boolean = false): Promise<void> {
    const currentSymptoms = await profileService.getField('currentBehavioralHealthSymptoms') || [];
    if (!currentSymptoms.includes(symptom)) {
      await profileService.updateField('currentBehavioralHealthSymptoms', [...currentSymptoms, symptom], confirm);
    }
  },

  async removeBehavioralSymptom(symptom: string, confirm: boolean = false): Promise<void> {
    const currentSymptoms = await profileService.getField('currentBehavioralHealthSymptoms') || [];
    const updatedSymptoms = currentSymptoms.filter(s => s !== symptom);
    await profileService.updateField('currentBehavioralHealthSymptoms', updatedSymptoms, confirm);
  },

  async setBehavioralSymptoms(symptoms: string[], confirm: boolean = false): Promise<void> {
    await profileService.updateField('currentBehavioralHealthSymptoms', symptoms, confirm);
  },

  async addIntervention(intervention: string, confirm: boolean = false): Promise<void> {
    const currentInterventions = await profileService.getField('currentInterventions') || [];
    if (!currentInterventions.includes(intervention)) {
      await profileService.updateField('currentInterventions', [...currentInterventions, intervention], confirm);
    }
  },

  async removeIntervention(intervention: string, confirm: boolean = false): Promise<void> {
    const currentInterventions = await profileService.getField('currentInterventions') || [];
    const updatedInterventions = currentInterventions.filter(i => i !== intervention);
    await profileService.updateField('currentInterventions', updatedInterventions, confirm);
  },

  async setInterventions(interventions: string[], confirm: boolean = false): Promise<void> {
    await profileService.updateField('currentInterventions', interventions, confirm);
  },

  async getProfile(): Promise<UserProfile> {
    return await profileService.getAllFields();
  },

  async getField(field: ProfileFieldKey): Promise<any> {
    return await profileService.getField(field);
  },

  async confirmField(field: ProfileFieldKey): Promise<void> {
    await profileService.confirmField(field);
  },

  async getFieldLastChanged(field: ProfileFieldKey): Promise<Date | undefined> {
    const metadata = await profileService.getFieldMetadata(field);
    return metadata.lastChanged;
  },

  async getFieldLastConfirmed(field: ProfileFieldKey): Promise<Date | undefined> {
    const metadata = await profileService.getFieldMetadata(field);
    return metadata.lastConfirmed;
  },

  async hasField(field: ProfileFieldKey): Promise<boolean> {
    const value = await profileService.getField(field);
    return value !== undefined && value !== null && value !== '';
  },

  async getProfileSummary(): Promise<string> {
    const profile = await profileService.getAllFields();
    const parts: string[] = [];

    if (profile.firstName || profile.lastName) {
      parts.push(`Name: ${profile.firstName || ''} ${profile.lastName || ''}`.trim());
    }
    
    if (profile.sex) parts.push(`Sex: ${profile.sex}`);
    if (profile.gender) parts.push(`Gender: ${profile.gender}`);
    if (profile.dateOfBirth) parts.push(`Date of Birth: ${profile.dateOfBirth}`);
    if (profile.sexualOrientation) parts.push(`Sexual Orientation: ${profile.sexualOrientation}`);
    
    if (profile.currentHealthGoals?.length) {
      parts.push(`Health Goals: ${profile.currentHealthGoals.join(', ')}`);
    }
    
    if (profile.currentBehavioralHealthSymptoms?.length) {
      parts.push(`Current Symptoms: ${profile.currentBehavioralHealthSymptoms.join(', ')}`);
    }
    
    if (profile.currentInterventions?.length) {
      parts.push(`Current Interventions: ${profile.currentInterventions.join(', ')}`);
    }

    return parts.length > 0 ? parts.join('\n') : 'No profile information available';
  },

  async clearAllData(): Promise<void> {
    await profileService.clearProfile();
  }
};

export const LLMProfileTools = {
  description: "Tools for managing user profile information",
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
      description: "Add a health goal to the user's profile",
      parameters: { goal: "string", confirm: "boolean (optional)" }
    },
    {
      name: "removeHealthGoal",
      description: "Remove a health goal from the user's profile",
      parameters: { goal: "string", confirm: "boolean (optional)" }
    },
    {
      name: "addBehavioralSymptom",
      description: "Add a behavioral health symptom (avoid diagnostic labels)",
      parameters: { symptom: "string", confirm: "boolean (optional)" }
    },
    {
      name: "removeBehavioralSymptom",
      description: "Remove a behavioral health symptom",
      parameters: { symptom: "string", confirm: "boolean (optional)" }
    },
    {
      name: "addIntervention",
      description: "Add an intervention the user is currently attempting",
      parameters: { intervention: "string", confirm: "boolean (optional)" }
    },
    {
      name: "removeIntervention",
      description: "Remove an intervention",
      parameters: { intervention: "string", confirm: "boolean (optional)" }
    },
    {
      name: "getProfile",
      description: "Get the complete user profile",
      parameters: {}
    },
    {
      name: "getProfileSummary",
      description: "Get a readable summary of the user's profile",
      parameters: {}
    },
    {
      name: "confirmField",
      description: "Mark a field as confirmed by the user",
      parameters: { field: "ProfileFieldKey" }
    }
  ]
};

export default ProfileTools;