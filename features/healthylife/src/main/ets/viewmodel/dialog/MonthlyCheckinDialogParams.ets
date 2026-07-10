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

import { CommonConstants as Const, convertDate2Str } from 'common';
import DayInfoApi from 'common/src/main/ets/database/tables/DayInfoApi';

/*
 * Cell data for a single day in the monthly check-in grid.
 */
export class MonthDayCellData {
  dateStr: string;
  percentage: number;
  progressImg: Resource;
  isFuture: boolean;
  isCurrentMonth: boolean;
  dayOfMonth: number;

  constructor(dateStr: string, percentage: number, progressImg: Resource,
    isFuture: boolean, isCurrentMonth: boolean, dayOfMonth: number) {
    this.dateStr = dateStr;
    this.percentage = percentage;
    this.progressImg = progressImg;
    this.isFuture = isFuture;
    this.isCurrentMonth = isCurrentMonth;
    this.dayOfMonth = dayOfMonth;
  }
}

/*
 * Parameters for the monthly check-in dialog.
 * - currentDate: the current selected day string (YYYYMMDD), used to locate the initial month.
 * - currentYear/currentMonth: the year and month currently displayed (1-12).
 * - monthData: the grid data for the displayed month, recomputed on month switch.
 *
 * Uses @Observed so that @ObjectLink in MonthlyCheckinDialogContent can observe
 * property changes and re-render automatically.
 */
@Observed
export class MonthlyCheckinDialogParams {
  currentDate: string;
  currentYear: number;
  currentMonth: number;
  monthData: MonthDayCellData[];

  constructor(currentDate: string) {
    this.currentDate = currentDate;
    this.currentYear = parseInt(currentDate.substring(0, 4));
    this.currentMonth = parseInt(currentDate.substring(4, 6));
    this.monthData = [];
  }

  /*
   * Recompute the month grid data for currentYear/currentMonth.
   * - Calculates the Monday-based offset for the first day of the month.
   * - Queries DayInfoApi.queryByKey for each day (up to 31 queries).
   * - Future dates (dateStr > today) are marked isFuture=true.
   * - Null/empty DayInfo records default to 0% + ic_home_undone.
   */
  async recomputeMonthData(): Promise<void> {
    const firstDay = new Date(this.currentYear, this.currentMonth - 1, 1);
    const dayOfWeek = firstDay.getDay();
    const offset = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
    const daysInMonth = new Date(this.currentYear, this.currentMonth, 0).getDate();

    const todayStr = convertDate2Str(new Date());
    const cells: MonthDayCellData[] = [];

    // Leading empty cells for offset
    for (let i = 0; i < offset; i++) {
      cells.push(new MonthDayCellData('', 0, $r('app.media.ic_home_undone'), false, false, 0));
    }

    // Actual day cells
    for (let d = 1; d <= daysInMonth; d++) {
      const monthStr = this.currentMonth < 10 ? '0' + this.currentMonth : '' + this.currentMonth;
      const dayStr = d < 10 ? '0' + d : '' + d;
      const dateStr = '' + this.currentYear + monthStr + dayStr;
      const isFuture = dateStr > todayStr;
      let percentage = 0;
      let progressImg: Resource = $r('app.media.ic_home_undone');

      if (!isFuture) {
        const dayInfo = await DayInfoApi.queryByKey(dateStr);
        if (dayInfo !== null && dayInfo.targetTaskNum > 0) {
          percentage = dayInfo.calculatePercentage();
          progressImg = dayInfo.getProgressImg();
        }
      }

      cells.push(new MonthDayCellData(dateStr, percentage, progressImg, isFuture, true, d));
    }

    this.monthData = cells;
  }
}
