/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants as Const } from '../constants/CommonConstants';

// hilog tag
const TAG: string = 'PreferencesUtils';
// achievement store options
const achievementStoreOptions: preferences.Options = { name: Const.ACHIEVEMENT_STORE };

export class PreferencesUtils {
  // user preferences connect instances of achievement store.
  static storePreferences?: preferences.Preferences | null;

  /*
   * create a user preference instance of achievement store and initialize the relevant information.
   * @param { Context } context context.
   * @returns { Promise<void> } A promise object.
   */
  static async getPreferencesFromStorage(context: Context): Promise<void> {
    try {
      PreferencesUtils.storePreferences = await preferences.getPreferences(context, achievementStoreOptions)
      hilog.info(0x0000, TAG, `Succeeded to load the preferences, options is ${Const.ACHIEVEMENT_STORE}`);

      if (PreferencesUtils.storePreferences) {
        // initialize the relevant information
        if (!PreferencesUtils.storePreferences.hasSync(Const.MAX_CONSECUTIVE_DAYS)) {
          await PreferencesUtils.putPreference(Const.MAX_CONSECUTIVE_DAYS, '0');
        }
        if (!PreferencesUtils.storePreferences.hasSync(Const.CURRENT_CONSECUTIVE_DAYS)) {
          await PreferencesUtils.putPreference(Const.CURRENT_CONSECUTIVE_DAYS, '0');
        }
        if (!PreferencesUtils.storePreferences.hasSync(Const.CURRENT_DAY_STATUS)) {
          await PreferencesUtils.putPreference(Const.CURRENT_DAY_STATUS, String(false));
        }
        hilog.info(0x0000, TAG, `Succeeded to init the preferences info, options is ${Const.ACHIEVEMENT_STORE}`);
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `Failed to load the preferences, code is ${err.code}, message is ${err.message}`);
    }
  }

  /*
   * Sets an value for the key in the Preferences object and save the Preferences object to the file.
   * @param { string } key Indicates the key of the preferences to modify.
   * @param { string } value Indicates the value of the preferences.
   * @returns { Promise<void> } A promise object.
   */
  static async putPreference(key: string, value: string): Promise<void> {
    if (!PreferencesUtils.storePreferences) {
      return;
    }
    try {
      await PreferencesUtils.storePreferences.put(key, value)
      await PreferencesUtils.storePreferences.flush()
      hilog.info(0x0000, TAG, `Succeeded to put the preferences, key is ${key}, value is ${value}`);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG,
        `Failed to put the preferences, key is ${key}, value is ${value}, code is ${err.code}, message is ${err.message}`);
    }
  }

  /*
   * Obtains the value of a preferences in the ValueType format.
   * @param { string } key Indicates the key of the preferences.
   * @returns { Promise<string> } The value matching the specified key if it is found;
   */
  static async getPreference(key: string): Promise<string> {
    let value: string = ''
    if (!PreferencesUtils.storePreferences) {
      return value;
    }
    try {
      value = await PreferencesUtils.storePreferences.get(key, 'default') as string;
      hilog.info(0x0000, TAG, `Succeeded to get the preferences, key is ${key}, value is ${value}`);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG,
        `Failed to get the preferences, key is ${key}, code is ${err.code}, message is ${err.message}`);
      return value;
    }
    return value;
  }
}
