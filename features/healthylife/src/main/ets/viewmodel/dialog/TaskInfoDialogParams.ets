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

import { DayTaskInfo } from 'common';
import { HomeStore } from '../HomeStore';
import { AchievementStore } from '../AchievementStore';

/*
 * Task info for clock custom dialog parameters.
 */
export class TaskInfoDialogParams {
  dayTaskInfo: DayTaskInfo;
  homeStore: HomeStore;
  achievementStore: AchievementStore;
  uIContext: UIContext;
  // Invoked after a clock-in mutates the DB. It reassigns the @Consume homeStore
  // reference inside the owning component (TaskListComponent), because @Consume
  // re-renders ONLY on a reference change — it does NOT observe @Observed property
  // mutations (only @ObjectLink does), so mutating homeStore.weekList/taskList in
  // place would never refresh the UI.
  refreshHomeStore: () => Promise<void>;
  // Invoked after updateAchievementStore returns a new AchievementStore instance.
  // Reassigns the @Consume achievementStore reference in TaskListComponent so the
  // UI refreshes (same pattern as refreshHomeStore above).
  refreshAchievementStore: () => Promise<void>;

  constructor(dayTaskInfo: DayTaskInfo, homeStore: HomeStore, achievementStore: AchievementStore,
    uIContext: UIContext, refreshHomeStore: () => Promise<void>,
    refreshAchievementStore: () => Promise<void>) {
    this.dayTaskInfo = dayTaskInfo;
    this.homeStore = homeStore;
    this.achievementStore = achievementStore;
    this.uIContext = uIContext;
    this.refreshHomeStore = refreshHomeStore;
    this.refreshAchievementStore = refreshAchievementStore;
  }
}