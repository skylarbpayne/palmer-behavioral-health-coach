export interface UserProfile {
  firstName?: string;
  lastName?: string;
  sex?: 'male' | 'female' | 'intersex';
  gender?: string;
  dateOfBirth?: string;
  sexualOrientation?: string;
  currentHealthGoals?: string[];
  currentBehavioralHealthSymptoms?: string[];
  currentInterventions?: string[];
  
  metadata: {
    lastChanged: { [key in keyof Omit<UserProfile, 'metadata'>]?: Date };
    lastConfirmed: { [key in keyof Omit<UserProfile, 'metadata'>]?: Date };
  };
}

export interface UserProfileField {
  value: any;
  lastChanged: Date;
  lastConfirmed?: Date;
}

export type ProfileFieldKey = keyof Omit<UserProfile, 'metadata'>;