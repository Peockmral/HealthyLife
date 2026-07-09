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

/*
 * Parameters for the day task progress dialog.
 * - date: the current selected day string (used for the dialog subtitle); expected to be today
 *   when the dialog is opened from the week calendar click-today flow.
 * - taskList: a snapshot of DayTaskInfo[] for the day (HomeStore.taskList); the dialog renders a
 *   linear progress bar per task and does NOT re-query the DB (snapshot mode).
 */
export class DayTaskProgressDialogParams {
  date: string;
  taskList: DayTaskInfo[];

  constructor(date: string, taskList: DayTaskInfo[]) {
    this.date = date;
    this.taskList = taskList;
  }
}
