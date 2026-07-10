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

import { JSON } from '@kit.ArkTS';
import { CommonConstants as Const } from 'common';
import { getNewlyUnlockedAchievementIndices } from '../model/AchievementModel';
import { TaskInfoDialogParams } from './dialog/TaskInfoDialogParams';
import { PreferencesUtils } from 'common/src/main/ets/utils/PreferencesUtils';
import { openAchievementCustomDialog } from '../views/dialog/AchievementDialog';

/*
 * Global achievement information storage.
 */
@Observed
export class AchievementStore {
  public maxConsecutiveDays: number;
  public currentConsecutiveDays: number;
  public currentDayStatus: boolean;

  constructor(maxConsecutiveDays: number, currentConsecutiveDays: number, currentDayStatus: boolean) {
    this.maxConsecutiveDays = maxConsecutiveDays;
    this.currentConsecutiveDays = currentConsecutiveDays;
    this.currentDayStatus = currentDayStatus;
  }
}

/*
 * Initialize global achievement information.
 */
export async function initAchievementStore() {
  const maxConsecutiveDays = Number(await PreferencesUtils.getPreference(Const.MAX_CONSECUTIVE_DAYS));
  const currentConsecutiveDays = Number(await PreferencesUtils.getPreference(Const.CURRENT_CONSECUTIVE_DAYS));
  const currentDayStatusStr: string = await PreferencesUtils.getPreference(Const.CURRENT_DAY_STATUS);
  const currentDayStatus = JSON.parse(currentDayStatusStr) as boolean;
  return new AchievementStore(maxConsecutiveDays, currentConsecutiveDays, currentDayStatus)
}

/*
 * Update the information when the achievement information changes.
 * @param { TaskInfoDialogParams } params Task info for clock custom dialog parameters.
 * @returns { Promise<AchievementStore> } A new AchievementStore instance with updated values.
 */
export async function updateAchievementStore(params: TaskInfoDialogParams): Promise<AchievementStore> {
  //Judge whether all tasks are completed that day, and return if not.
  const dayInfo = params.homeStore.weekList[params.homeStore.selectedDay];
  if (dayInfo.finTaskNum < dayInfo.targetTaskNum || params.achievementStore.currentDayStatus) {
    return new AchievementStore(params.achievementStore.maxConsecutiveDays,
      params.achievementStore.currentConsecutiveDays, params.achievementStore.currentDayStatus);
  }

  // Record the old max before any updates.
  const oldMax = params.achievementStore.maxConsecutiveDays;

  // Calculate the new values locally — do NOT mutate params.achievementStore in place.
  let newCurrentConsecutiveDays = params.achievementStore.currentConsecutiveDays + 1;
  await PreferencesUtils.putPreference(Const.CURRENT_CONSECUTIVE_DAYS, String(newCurrentConsecutiveDays));

  let newCurrentDayStatus = true;
  await PreferencesUtils.putPreference(Const.CURRENT_DAY_STATUS, String(newCurrentDayStatus));

  let newMaxConsecutiveDays = params.achievementStore.maxConsecutiveDays;
  if (newCurrentConsecutiveDays > newMaxConsecutiveDays) {
    newMaxConsecutiveDays = newCurrentConsecutiveDays;
    await PreferencesUtils.putPreference(Const.MAX_CONSECUTIVE_DAYS, String(newMaxConsecutiveDays));

    // Get all newly unlocked achievement indices and open dialogs with staggered timing.
    const newlyUnlockedIndices = getNewlyUnlockedAchievementIndices(oldMax, newMaxConsecutiveDays);
    for (let i = 0; i < newlyUnlockedIndices.length; i++) {
      const idx = newlyUnlockedIndices[i];
      const delay = i * 1500;
      if (delay === 0) {
        openAchievementCustomDialog(params.uIContext, idx);
      } else {
        setTimeout(() => {
          openAchievementCustomDialog(params.uIContext, idx);
        }, delay);
      }
    }
  }

  return new AchievementStore(newMaxConsecutiveDays, newCurrentConsecutiveDays, newCurrentDayStatus);
}