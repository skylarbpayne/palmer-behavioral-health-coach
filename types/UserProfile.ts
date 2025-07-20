import { z } from 'zod';

export interface FieldMetadata {
  lastChanged: Date;
  lastConfirmed?: Date;
}

export interface ProfileField<T> {
  value: T;
  metadata: FieldMetadata;
}

export interface ProfileArrayItem<T> {
  value: T;
  id: string;
  metadata: FieldMetadata;
}

export interface UserProfile {
  firstName?: ProfileField<string>;
  lastName?: ProfileField<string>;
  sex?: ProfileField<'male' | 'female' | 'intersex'>;
  gender?: ProfileField<string>;
  dateOfBirth?: ProfileField<string>;
  sexualOrientation?: ProfileField<string>;
  currentHealthGoals?: ProfileArrayItem<string>[];
  currentBehavioralHealthSymptoms?: ProfileArrayItem<string>[];
  currentInterventions?: ProfileArrayItem<string>[];
}

export type ProfileFieldKey = keyof UserProfile;
export type ProfileSimpleFieldKey = Extract<ProfileFieldKey, 'firstName' | 'lastName' | 'sex' | 'gender' | 'dateOfBirth' | 'sexualOrientation'>;
export type ProfileArrayFieldKey = Extract<ProfileFieldKey, 'currentHealthGoals' | 'currentBehavioralHealthSymptoms' | 'currentInterventions'>;

// Zod schemas for validation
export const FieldMetadataSchema = z.object({
  lastChanged: z.date(),
  lastConfirmed: z.date().optional(),
});

export const ProfileFieldSchema = <T>(valueSchema: z.ZodType<T>) => z.object({
  value: valueSchema,
  metadata: FieldMetadataSchema,
});

export const ProfileArrayItemSchema = <T>(valueSchema: z.ZodType<T>) => z.object({
  value: valueSchema,
  id: z.string(),
  metadata: FieldMetadataSchema,
});

export const UserProfileSchema = z.object({
  firstName: ProfileFieldSchema(z.string()).optional(),
  lastName: ProfileFieldSchema(z.string()).optional(),
  sex: ProfileFieldSchema(z.enum(['male', 'female', 'intersex'])).optional(),
  gender: ProfileFieldSchema(z.string()).optional(),
  dateOfBirth: ProfileFieldSchema(z.string()).optional(),
  sexualOrientation: ProfileFieldSchema(z.string()).optional(),
  currentHealthGoals: z.array(ProfileArrayItemSchema(z.string())).optional(),
  currentBehavioralHealthSymptoms: z.array(ProfileArrayItemSchema(z.string())).optional(),
  currentInterventions: z.array(ProfileArrayItemSchema(z.string())).optional(),
});

// Type helpers for safe access
export type UserProfileInput = z.input<typeof UserProfileSchema>;
export type UserProfileOutput = z.output<typeof UserProfileSchema>;