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

import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { convertDate2Str, RdbConstants } from 'common';
import { RdbUtils } from 'common/src/main/ets/database/RdbUtils';
import DayInfoApi from 'common/src/main/ets/database/tables/DayInfoApi';
import TaskInfoApi from 'common/src/main/ets/database/tables/TaskInfoApi';
import { PreferencesUtils } from 'common/src/main/ets/utils/PreferencesUtils';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    RdbUtils.closeRdb();
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    // The UIAbility framework does NOT await an async onCreate, so loading the
    // page here used to race the RDB init: HomeComponent.aboutToAppear ran
    // initDayInfo (which inserts the today dayInfo row) BEFORE createRdb had
    // finished, so rdbStore was still undefined and the insert silently no-op'd
    // (rdbStore?.). That left today's dayInfo row missing forever, so the daily
    // progress was stuck at 0% no matter how many tasks were clocked. Await ALL
    // DB/preferences init here and ONLY THEN loadContent, so the store is ready
    // and the today row exists before the home page renders.
    await RdbUtils.createRdb(this.context);
    for (let tableName of RdbConstants.TABLE_NAME_LIST) {
      await RdbUtils.createTable(tableName);
    }
    // Add the isRepeat column for legacy databases (no-op on fresh installs where create-table already includes it).
    await TaskInfoApi.migrateIsRepeat();
    await TaskInfoApi.checkDefaultTask();
    // Init preferences and get store
    await PreferencesUtils.getPreferencesFromStorage(this.context);
    await DayInfoApi.initAchievementStoreByDayInfo(convertDate2Str(new Date()));

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}