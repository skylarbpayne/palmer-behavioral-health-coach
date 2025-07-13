import AsyncStorage from '@react-native-async-storage/async-storage';
import { UserProfile, ProfileFieldKey } from '../types/UserProfile';

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
    return {
      metadata: {
        lastChanged: {},
        lastConfirmed: {}
      }
    };
  }

  async loadProfile(): Promise<UserProfile> {
    try {
      if (this.profile) {
        return this.profile;
      }

      const profileData = await AsyncStorage.getItem(USER_PROFILE_KEY);
      
      if (profileData) {
        const parsed = JSON.parse(profileData);
        this.profile = {
          ...parsed,
          metadata: {
            lastChanged: this.parseDates(parsed.metadata?.lastChanged || {}),
            lastConfirmed: this.parseDates(parsed.metadata?.lastConfirmed || {})
          }
        };
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
      const profileToStore = {
        ...this.profile,
        metadata: {
          lastChanged: this.stringifyDates(this.profile.metadata.lastChanged),
          lastConfirmed: this.stringifyDates(this.profile.metadata.lastConfirmed)
        }
      };

      await AsyncStorage.setItem(USER_PROFILE_KEY, JSON.stringify(profileToStore));
    } catch (error) {
      console.error('Error saving user profile:', error);
      throw error;
    }
  }

  async getField<K extends ProfileFieldKey>(field: K): Promise<UserProfile[K] | undefined> {
    const profile = await this.loadProfile();
    return profile[field];
  }

  async updateField<K extends ProfileFieldKey>(
    field: K, 
    value: UserProfile[K], 
    confirm: boolean = false
  ): Promise<void> {
    const profile = await this.loadProfile();
    const now = new Date();

    profile[field] = value;
    profile.metadata.lastChanged[field] = now;
    
    if (confirm) {
      profile.metadata.lastConfirmed[field] = now;
    }

    this.profile = profile;
    await this.saveProfile();
  }

  async confirmField(field: ProfileFieldKey): Promise<void> {
    const profile = await this.loadProfile();
    profile.metadata.lastConfirmed[field] = new Date();
    this.profile = profile;
    await this.saveProfile();
  }

  async getFieldMetadata(field: ProfileFieldKey): Promise<{
    lastChanged?: Date;
    lastConfirmed?: Date;
  }> {
    const profile = await this.loadProfile();
    return {
      lastChanged: profile.metadata.lastChanged[field],
      lastConfirmed: profile.metadata.lastConfirmed[field]
    };
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

  private parseDates(dateObj: Record<string, any>): Record<string, Date> {
    const result: Record<string, Date> = {};
    for (const [key, value] of Object.entries(dateObj)) {
      if (value) {
        result[key] = new Date(value);
      }
    }
    return result;
  }

  private stringifyDates(dateObj: Record<string, Date>): Record<string, string> {
    const result: Record<string, string> = {};
    for (const [key, value] of Object.entries(dateObj)) {
      if (value instanceof Date) {
        result[key] = value.toISOString();
      }
    }
    return result;
  }
}

export default UserProfileService;