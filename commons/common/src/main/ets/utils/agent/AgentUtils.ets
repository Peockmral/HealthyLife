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

import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { TaskInfo } from '../../model/database/TaskInfo';
import { TaskBaseInfo } from '../../model/TaskBaseModel';
import TaskInfoApi from '../../database/tables/TaskInfoApi';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = '[AgentUtils]';

export class AgentUtils {
  static async creatAgent(taskInfo: TaskInfo, taskBaseInfo: TaskBaseInfo, uIContext: UIContext): Promise<number> {
    let targetReminderAgent = AgentUtils.agentConfigSet(taskInfo, taskBaseInfo, uIContext);
    if (!targetReminderAgent) {
      return -1;
    }
    try {
      let reminderId: number = await reminderAgentManager.publishReminder(targetReminderAgent); // 发布的提醒ID
      hilog.info(0x0000, TAG, `Succeeded in publishing reminder. `);
      return reminderId;
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed to publish reminder. Code: ${err.code}, message: ${err.message}`);
      // 1700002 = number of reminders exceeds the limit. On the emulator the internal quota
      // counter can desync from getValidReminders (returns empty yet publish still fails), so
      // per-reminder cancel cannot reclaim it. Nuclear recovery: cancel ALL of this app's
      // reminders to reset the counter, clear stored ids so other open tasks self-heal on next
      // edit, then retry the publish once.
      if (err.code === 1700002) {
        hilog.info(0x0000, TAG, `1700002: invoking cancelAllReminders + resetAllReminderIds, then retrying`);
        try {
          await reminderAgentManager.cancelAllReminders();
        } catch (e) {
          hilog.error(0x0000, TAG, `cancelAllReminders failed: code=${e.code}, message=${e.message}`);
        }
        try {
          await TaskInfoApi.resetAllReminderIds();
        } catch (e) {
          hilog.error(0x0000, TAG, `resetAllReminderIds failed: ${e}`);
        }
        try {
          let reminderId: number = await reminderAgentManager.publishReminder(targetReminderAgent);
          hilog.info(0x0000, TAG, `Succeeded in publishing reminder after recovery. reminderId=${reminderId}`);
          return reminderId;
        } catch (err2) {
          hilog.error(0x0000, TAG,
            `Retry publish still failed. Code: ${err2.code}, message: ${err2.message}`);
        }
      }
    }
    return -1;
  }

  static async updateAgent(taskInfo: TaskInfo, taskBaseInfo: TaskBaseInfo, uIContext: UIContext): Promise<void> {
    let targetReminderAgent = AgentUtils.agentConfigSet(taskInfo, taskBaseInfo, uIContext);
    reminderAgentManager.updateReminder(taskInfo.reminderId, targetReminderAgent).then(() => {
      console.info("update reminder succeed");
    }).catch((err: BusinessError) => {
      console.error("promise err code:" + err.code + " message:" + err.message);
    });
  }

  static deleteAgent(reminderId: number): void {
    // The value of reminderId is obtained from the callback after the reminder agent is successfully published.
    reminderAgentManager.cancelReminder(reminderId).then(() => {
      hilog.info(0x0000, TAG, `Succeeded in canceling reminder. `);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Failed to cancel reminder. Code: ${err.code}, message: ${err.message}`);
    });
  }

  /*
   * Cancel every system reminder that is not in the tracked set.
   * reminderAgentManager reminders are system-level and per-app with a quota (~30).
   * Reinstalls / failed cancels leave ghost reminders whose ids are no longer in our DB,
   * so they can never be cancelled normally and eventually fill the quota, causing
   * publishReminder to fail with 1700002 "number of reminders exceeds the limit".
   * This reclaims that quota by cancelling only ghosts, preserving legitimately active
   * task reminders (早起 / 早睡).
   * @param { number[] } trackedIds reminderIds still tracked by opened tasks in the DB.
   * @returns { Promise<number> } how many ghost reminders were cancelled.
   */
  static async cleanupGhostReminders(trackedIds: number[]): Promise<number> {
    let cleaned = 0;
    try {
      let reminders = await reminderAgentManager.getAllValidReminders();
      hilog.info(0x0000, TAG,
        `getAllValidReminders: count=${reminders.length}, tracked=${trackedIds.length}`);
      for (let info of reminders) {
        let id = info.reminderId;
        if (trackedIds.indexOf(id) === -1) {
          try {
            await reminderAgentManager.cancelReminder(id);
            cleaned++;
            hilog.info(0x0000, TAG, `Cancelled ghost reminder id=${id}`);
          } catch (e) {
            hilog.error(0x0000, TAG, `Failed to cancel ghost reminder id=${id}: ${e}`);
          }
        }
      }
    } catch (err) {
      hilog.error(0x0000, TAG,
        `getAllValidReminders failed, cannot cleanup ghosts: code=${err.code}, message=${err.message}`);
    }
    if (cleaned > 0) {
      hilog.info(0x0000, TAG, `cleanupGhostReminders cancelled ${cleaned} ghost reminder(s)`);
    }
    return cleaned;
  }

  static agentConfigSet(taskInfo: TaskInfo, taskBaseInfo: TaskBaseInfo, uIContext: UIContext) {
    // Adjust the time format
    let GeneratedDestructArray_1 = taskInfo.targetValue.split(':');
    let hourStr = GeneratedDestructArray_1[0];
    let minuteStr = GeneratedDestructArray_1[1];
    let hour = parseInt(hourStr);
    let minute = parseInt(minuteStr);
    hilog.info(0x0000, TAG,
      `agentConfigSet: taskId=${taskInfo.taskId}, targetValue='${taskInfo.targetValue}', ` +
      `parsed hour=${hour}, minute=${minute}`);
    if (isNaN(hour) || isNaN(minute)) {
      hilog.error(0x0000, TAG,
        `agentConfigSet: invalid targetValue '${taskInfo.targetValue}', hour/minute is NaN, abort`);
      return undefined;
    }
    try {
      let displayText = uIContext.getHostContext()?.resourceManager.getStringSync(taskBaseInfo.name.id);
      // Minimal config: the emulator's ReminderAgentService logged
      // "Does not have argument type:tapDismissed/forceDistributed/notDistributed" + "Read result
      // failed, code is: 1" on the full config, so actionButton / snooze / ringDuration / slotType
      // are stripped to rule out an unsupported field triggering the publish failure.
      let targetReminderAgent: reminderAgentManager.ReminderRequestAlarm = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
        hour: hour,
        minute: minute,
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        title: displayText,
        content: displayText,
        wantAgent: {
          pkgName: 'com.huawei.healthylife',
          abilityName: 'EntryAbility'
        }
      }
      return targetReminderAgent;
    } catch (error) {
      hilog.error(0x0000, TAG, `an error occurred: ${error}`);
      return undefined
    }
  }
}