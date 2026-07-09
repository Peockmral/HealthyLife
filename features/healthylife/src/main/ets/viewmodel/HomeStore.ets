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

import {
  CommonConstants as Const, convertDate2Str, convertStr2Date, DayInfo, DayTaskInfo
} from 'common';
import DayInfoApi from 'common/src/main/ets/database/tables/DayInfoApi';
import TaskInfoApi from 'common/src/main/ets/database/tables/TaskInfoApi';
import DayTaskInfoApi from 'common/src/main/ets/database/tables/DayTaskInfoApi';

/*
 * Global day and tasks information storage.
 */
@Observed
export class HomeStore {
  // three consecutive weeks where the current date is located
  public weekList: DayInfo[];
  public selectedDay: number;
  public currentDate: string;
  public taskList: DayTaskInfo[];

  constructor(weekList: DayInfo[], selectedDay: number, currentDate: string, taskList: DayTaskInfo[]) {
    this.weekList = weekList;
    this.selectedDay = selectedDay;
    this.currentDate = currentDate;
    this.taskList = taskList;
  }

  public checkCurrentDay(): boolean {
    return convertDate2Str(new Date()) === this.currentDate;
  }
}

/*
 * Initialize the global storage information of the day.
 * @param { Date } date Date of the day.
 * @returns { Promise<HomeStore> } The global storage information.
 */
export async function initCurrentDateInfo(date: Date): Promise<HomeStore> {
  let dayOfWeek = date.getDay();
  let selectedDay = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
  let dateList: Date[] = getWeekDates(date, selectedDay);
  let weekList: DayInfo[] = [];
  for (let dateOfWeek of dateList) {
    let dateStr = convertDate2Str(dateOfWeek);
    let dayInfo = await DayInfoApi.queryByKey(dateStr);
    if (dayInfo === null) {
      // if this info is null, init to default value.
      dayInfo = new DayInfo(dateStr, 0, 0);
    }
    weekList.push(dayInfo);
  }

  let dateStr = convertDate2Str(date);
  let taskList: DayTaskInfo[] = await DayTaskInfoApi.queryDayTaskInfo(dateStr);
  if (taskList.length === 0 && date > new Date()) {
    // The day is in the future and has no persisted records yet: prefill it in-memory with the
    // repeating opened tasks only. Today-only tasks must not appear on future days.
    let repeatTaskList = await TaskInfoApi.queryRepeatTaskInfo();
    for (let repeatTask of repeatTaskList) {
      taskList.push(repeatTask.convert2DefaultDayTask(dateStr))
    }
  }
  return new HomeStore(weekList, selectedDay + Const.WEEK_DAY_NUM, dateStr, taskList);
}

/*
 * Re-query the home list / week list for the current date and return a NEW
 * HomeStore instance. Callers MUST assign the result back to the @Consume
 * homeStore (this.homeStore = await updateTaskList(this.homeStore)) so that the
 * homeStore reference changes — that is the only change @Consume consumers
 * (HomeTopComponent / TaskListComponent / WeekCalendarComponent) can observe.
 * @Observed property mutations are only delivered to @ObjectLink, which these
 * components do NOT use, so mutating weekList/taskList in place never refreshed
 * the UI after a clock-in / open / close / delete.
 * @param { HomeStore } homeStore The global storage information.
 * @returns { Promise<HomeStore> } A freshly-queried HomeStore instance.
 */
export async function updateTaskList(homeStore: HomeStore): Promise<HomeStore> {
  return await initCurrentDateInfo(convertStr2Date(homeStore.currentDate));
}

/*
 * Get a list of dates for three weeks before and after the day.
 * @param { Date } inputDate Date of the day.
 * @param { number } adjustDays The difference between the day and Monday.
 * @returns { Date[] } The array of three weeks.
 */
function getWeekDates(inputDate: Date, adjustDays: number): Date[] {
  const monday = new Date(inputDate);
  monday.setDate(inputDate.getDate() - adjustDays - Const.WEEK_DAY_NUM);

  const dates: Date[] = [];
  for (let i = 0; i < Const.WEEK_DAY_NUM * 3; i++) {
    // eslint-disable-next-line @performance/reuse-date-instances-check
    const currentDate = new Date(monday);
    currentDate.setDate(monday.getDate() + i);
    dates.push(currentDate);
  }
  return dates;
}