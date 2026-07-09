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
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { TaskInfo } from '../../model/database/TaskInfo';
import { TaskBaseInfo } from '../../model/TaskBaseModel';
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

  static agentConfigSet(taskInfo: TaskInfo, taskBaseInfo: TaskBaseInfo, uIContext: UIContext) {
    // Adjust the time format
    let GeneratedDestructArray_1 = taskInfo.targetValue.split(':');
    let hourStr = GeneratedDestructArray_1[0];
    let minuteStr = GeneratedDestructArray_1[1];
    try {
      let displayText = uIContext.getHostContext()?.resourceManager.getStringSync(taskBaseInfo.name.id);
      let targetReminderAgent: reminderAgentManager.ReminderRequestAlarm = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
        hour: parseInt(hourStr),
        minute: parseInt(minuteStr),
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        actionButton: [
          {
            title: 'close',
            type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
          },
          {
            title: 'snooze',
            type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_SNOOZE
          },
        ],
        wantAgent: {
          pkgName: 'com.huawei.healthylife',
          abilityName: 'EntryAbility'
        },
        ringDuration: 10,
        snoozeTimes: 2,
        timeInterval: 5 * 60,
        title: displayText,
        content: displayText,
        expiredContent: 'this reminder has expired',
        snoozeContent: 'remind later',
        slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION
      }
      return targetReminderAgent;
    } catch (error) {
      hilog.error(0x0000, TAG, `an error occurred: ${error}`);
      return undefined
    }
  }
}