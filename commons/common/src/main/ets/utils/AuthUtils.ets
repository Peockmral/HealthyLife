/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants as Const } from '../constants/CommonConstants';
import { PreferencesUtils } from './PreferencesUtils';

const TAG: string = 'AuthUtils';

export class AuthUtils {
  /*
   * Read all registered users from Preferences as a Record map.
   * @returns { Promise<Record<string, string>> } Map of username to password.
   */
  static async getRegisteredUsers(): Promise<Record<string, string>> {
    const jsonStr: string = await PreferencesUtils.getPreference(Const.REGISTERED_USERS);
    if (jsonStr === 'default' || jsonStr === '' || jsonStr === '{}') {
      return {} as Record<string, string>;
    }
    try {
      return JSON.parse(jsonStr) as Record<string, string>;
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to parse registered users: ${error}`);
      return {} as Record<string, string>;
    }
  }

  /*
   * Register a new user. Returns false if username already exists.
   * @param { string } username The username to register.
   * @param { string } password The password for the new user.
   * @returns { Promise<boolean> } true if registration succeeded, false if username taken.
   */
  static async registerUser(username: string, password: string): Promise<boolean> {
    const users: Record<string, string> = await AuthUtils.getRegisteredUsers();
    if (users[username] !== undefined) {
      hilog.info(0x0000, TAG, `Username already exists: ${username}`);
      return false;
    }
    users[username] = password;
    const jsonStr: string = JSON.stringify(users);
    await PreferencesUtils.putPreference(Const.REGISTERED_USERS, jsonStr);
    hilog.info(0x0000, TAG, `User registered successfully: ${username}`);
    return true;
  }

  /*
   * Validate login credentials against registered users.
   * @param { string } username The username to validate.
   * @param { string } password The password to validate.
   * @returns { Promise<boolean> } true if credentials match, false otherwise.
   */
  static async validateLogin(username: string, password: string): Promise<boolean> {
    const users: Record<string, string> = await AuthUtils.getRegisteredUsers();
    if (users[username] !== undefined && users[username] === password) {
      hilog.info(0x0000, TAG, `Login validated for user: ${username}`);
      return true;
    }
    hilog.info(0x0000, TAG, `Login validation failed for user: ${username}`);
    return false;
  }

  /*
   * Check if the user is currently logged in.
   * @returns { Promise<boolean> } true if logged in, false otherwise.
   */
  static async isLoggedIn(): Promise<boolean> {
    const value: string = await PreferencesUtils.getPreference(Const.IS_LOGGED_IN);
    return value === 'true';
  }

  /*
   * Set the login state.
   * @param { boolean } value The login state to persist.
   * @returns { Promise<void> }
   */
  static async setLoggedIn(value: boolean): Promise<void> {
    await PreferencesUtils.putPreference(Const.IS_LOGGED_IN, String(value));
  }
}
