import AsyncStorage from '@react-native-async-storage/async-storage';
import { 
  UserProfile, 
  ProfileFieldKey, 
  ProfileSimpleFieldKey, 
  ProfileArrayFieldKey,
  UserProfileSchema,
  ProfileField,
  ProfileArrayItem,
  FieldMetadata
} from '../types/UserProfile';
import { v4 as uuidv4 } from 'uuid';

const USER_PROFILE_KEY = '@user_profile';

class UserProfileService {
  private static instance: UserProfileService;
  private profile: UserProfile | null = null;

  private constructor() {}

  static getInstance(): UserProfileService {
    if (!UserProfileService.instance) {
      UserProfileService.instance = new UserProfileService();
    }
    return UserProfileService.instance;
  }

  private createEmptyProfile(): UserProfile {
    return {};
  }

  async loadProfile(): Promise<UserProfile> {
    try {
      if (this.profile) {
        return this.profile;
      }

      const profileData = await AsyncStorage.getItem(USER_PROFILE_KEY);
      
      if (profileData) {
        const parsed = JSON.parse(profileData);
        this.profile = this.deserializeProfile(parsed);
        
        // Validate with Zod schema
        const validation = UserProfileSchema.safeParse(this.profile);
        if (!validation.success) {
          console.warn('Profile validation failed, creating new profile:', validation.error);
          this.profile = this.createEmptyProfile();
        }
      } else {
        this.profile = this.createEmptyProfile();
      }

      return this.profile!;
    } catch (error) {
      console.error('Error loading user profile:', error);
      this.profile = this.createEmptyProfile();
      return this.profile;
    }
  }

  async saveProfile(): Promise<void> {
    if (!this.profile) {
      throw new Error('No profile to save');
    }

    try {
      const serializedProfile = this.serializeProfile(this.profile);
      await AsyncStorage.setItem(USER_PROFILE_KEY, JSON.stringify(serializedProfile));
    } catch (error) {
      console.error('Error saving user profile:', error);
      throw error;
    }
  }

  async getSimpleField<K extends ProfileSimpleFieldKey>(field: K): Promise<UserProfile[K] | undefined> {
    const profile = await this.loadProfile();
    return profile[field];
  }

  async getArrayField<K extends ProfileArrayFieldKey>(field: K): Promise<UserProfile[K] | undefined> {
    const profile = await this.loadProfile();
    return profile[field];
  }

  async updateSimpleField<K extends ProfileSimpleFieldKey>(
    field: K,
    value: K extends 'sex' ? 'male' | 'female' | 'intersex' : string,
    confirm: boolean = false
  ): Promise<void> {
    const profile = await this.loadProfile();
    const now = new Date();

    const fieldData: ProfileField<any> = {
      value,
      metadata: {
        lastChanged: now,
        lastConfirmed: confirm ? now : profile[field]?.metadata.lastConfirmed
      }
    };

    (profile as any)[field] = fieldData;
    this.profile = profile;
    await this.saveProfile();
  }

  async addArrayItem<K extends ProfileArrayFieldKey>(
    field: K,
    value: string,
    confirm: boolean = false
  ): Promise<string> {
    const profile = await this.loadProfile();
    const now = new Date();
    const id = uuidv4();

    const newItem: ProfileArrayItem<string> = {
      value,
      id,
      metadata: {
        lastChanged: now,
        lastConfirmed: confirm ? now : undefined
      }
    };

    if (!profile[field]) {
      (profile as any)[field] = [];
    }

    (profile[field] as ProfileArrayItem<string>[]).push(newItem);
    this.profile = profile;
    await this.saveProfile();
    
    return id;
  }

  async removeArrayItem<K extends ProfileArrayFieldKey>(
    field: K,
    id: string
  ): Promise<void> {
    const profile = await this.loadProfile();
    
    if (profile[field]) {
      (profile[field] as ProfileArrayItem<string>[]) = 
        (profile[field] as ProfileArrayItem<string>[]).filter(item => item.id !== id);
      
      this.profile = profile;
      await this.saveProfile();
    }
  }

  async updateArrayItem<K extends ProfileArrayFieldKey>(
    field: K,
    id: string,
    value: string,
    confirm: boolean = false
  ): Promise<void> {
    const profile = await this.loadProfile();
    
    if (profile[field]) {
      const item = (profile[field] as ProfileArrayItem<string>[]).find(item => item.id === id);
      if (item) {
        const now = new Date();
        item.value = value;
        item.metadata.lastChanged = now;
        if (confirm) {
          item.metadata.lastConfirmed = now;
        }
        
        this.profile = profile;
        await this.saveProfile();
      }
    }
  }

  async confirmSimpleField<K extends ProfileSimpleFieldKey>(field: K): Promise<void> {
    const profile = await this.loadProfile();
    if (profile[field]) {
      profile[field]!.metadata.lastConfirmed = new Date();
      this.profile = profile;
      await this.saveProfile();
    }
  }

  async confirmArrayItem<K extends ProfileArrayFieldKey>(
    field: K,
    id: string
  ): Promise<void> {
    const profile = await this.loadProfile();
    
    if (profile[field]) {
      const item = (profile[field] as ProfileArrayItem<string>[]).find(item => item.id === id);
      if (item) {
        item.metadata.lastConfirmed = new Date();
        this.profile = profile;
        await this.saveProfile();
      }
    }
  }

  async getSimpleFieldMetadata<K extends ProfileSimpleFieldKey>(field: K): Promise<FieldMetadata | undefined> {
    const profile = await this.loadProfile();
    return profile[field]?.metadata;
  }

  async getArrayItemMetadata<K extends ProfileArrayFieldKey>(
    field: K,
    id: string
  ): Promise<FieldMetadata | undefined> {
    const profile = await this.loadProfile();
    
    if (profile[field]) {
      const item = (profile[field] as ProfileArrayItem<string>[]).find(item => item.id === id);
      return item?.metadata;
    }
    
    return undefined;
  }

  async getAllFields(): Promise<UserProfile> {
    return await this.loadProfile();
  }

  async clearProfile(): Promise<void> {
    try {
      await AsyncStorage.removeItem(USER_PROFILE_KEY);
      this.profile = this.createEmptyProfile();
    } catch (error) {
      console.error('Error clearing user profile:', error);
      throw error;
    }
  }

  private serializeProfile(profile: UserProfile): any {
    const serialized: any = {};
    
    for (const [key, value] of Object.entries(profile)) {
      if (value) {
        if (Array.isArray(value)) {
          // Handle array fields
          serialized[key] = value.map(item => ({
            ...item,
            metadata: {
              lastChanged: item.metadata.lastChanged.toISOString(),
              lastConfirmed: item.metadata.lastConfirmed?.toISOString()
            }
          }));
        } else {
          // Handle simple fields
          serialized[key] = {
            ...value,
            metadata: {
              lastChanged: value.metadata.lastChanged.toISOString(),
              lastConfirmed: value.metadata.lastConfirmed?.toISOString()
            }
          };
        }
      }
    }
    
    return serialized;
  }

  private deserializeProfile(serialized: any): UserProfile {
    const profile: UserProfile = {};
    
    for (const [key, value] of Object.entries(serialized)) {
      if (value) {
        if (Array.isArray(value)) {
          // Handle array fields
          (profile as any)[key] = value.map((item: any) => ({
            ...item,
            metadata: {
              lastChanged: new Date(item.metadata.lastChanged),
              lastConfirmed: item.metadata.lastConfirmed ? new Date(item.metadata.lastConfirmed) : undefined
            }
          }));
        } else if (value && typeof value === 'object' && 'metadata' in value) {
          // Handle simple fields
          (profile as any)[key] = {
            ...value,
            metadata: {
              lastChanged: new Date((value as any).metadata.lastChanged),
              lastConfirmed: (value as any).metadata.lastConfirmed ? new Date((value as any).metadata.lastConfirmed) : undefined
            }
          };
        }
      }
    }
    
    return profile;
  }
}

export default UserProfileService;