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

import { ComponentContent } from '@kit.ArkUI';
import { CommonConstants as Const, DayTaskInfo, PromptActionClass, taskBaseInfoList } from 'common';
import { DayTaskProgressDialogParams } from '../../viewmodel/dialog/DayTaskProgressDialogParams';

/*
 * Open the centered day-task-progress dialog. Reuses the global PromptActionClass +
 * ComponentContent + wrapBuilder pattern (same as TaskClockCustomDialog /
 * AchievementDialog / TargetSettingDialog). The dialog renders a snapshot of the
 * passed-in taskList and does NOT re-query the DB.
 */
export function openDayTaskProgressDialog(uIContext: UIContext, params: DayTaskProgressDialogParams): void {
  PromptActionClass.setContext(uIContext);
  let dayTaskProgressDialogNode = new ComponentContent(uIContext, wrapBuilder(dayTaskProgressDialogBuilder), params);
  PromptActionClass.setContentNode(dayTaskProgressDialogNode);
  // Reset alignment explicitly: PromptActionClass.options is a static field that may
  // retain a previous dialog's options (e.g. TargetSettingDialog sets Bottom). Force
  // center to satisfy US1 "居中对话框".
  PromptActionClass.setOptions({
    alignment: DialogAlignment.Center
  });
  PromptActionClass.openDialog();
}

/*
 * Compute the linear progress (0-100) for a single day task.
 * - Boolean tasks (taskBaseInfoList[taskId].step === 0, e.g. early-riser/sleep): 0% or 100%
 *   depending on isDone.
 * - Count tasks (step > 0, e.g. drink/apple/smile/brush): round(finValue / targetValue * 100),
 *   capped at 100. Empty/non-positive target falls back to the isDone state to avoid NaN.
 */
function getDayTaskProgress(item: DayTaskInfo): number {
  if (taskBaseInfoList[item.taskId].step === 0) {
    return item.isDone ? 100 : 0;
  }
  const target = Number(item.targetValue);
  if (!(target > 0)) {
    return item.isDone ? 100 : 0;
  }
  const fin = Number(item.finValue || '0');
  return Math.min(100, Math.round(fin / target * 100));
}

@Builder
export function dayTaskProgressDialogBuilder(params: DayTaskProgressDialogParams) {
  Stack({ alignContent: Alignment.Center }) {
    // Backdrop: full-screen transparent layer. Clicking it closes the dialog (US3).
    // The card below is a sibling (not a child), so clicks on the card do NOT bubble to
    // this backdrop — ClickEvent has no stopPropagation, so sibling layering avoids the
    // issue entirely.
    Column()
      .width(Const.THOUSANDTH_1000)
      .height(Const.THOUSANDTH_1000)
      .onClick(() => {
        PromptActionClass.closeDialog();
      })

    // Card: centered dialog content.
    Column() {
      Text($r('app.string.day_task_progress'))
        .fontFamily(Const.HARMONY_HEI_TI_BOLD)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('app.float.default_22'))

      Text(params.date)
        .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('app.float.default_14'))
        .margin({
          top: $r('app.float.default_4')
        })

      if (params.taskList.length === 0) {
        // Empty state: no enabled tasks for the day.
        Text($r('app.string.no_day_task'))
          .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('app.float.default_14'))
          .margin({
            top: $r('app.float.default_24')
          })
      } else {
        // Per-task progress list. The item layout is inlined here (instead of a nested
        // global @Builder) to stay consistent with TaskClockCustomDialog's single-builder
        // pattern and avoid the ComponentContent nestingBuilderSupported requirement.
        Column() {
          ForEach(params.taskList, (item: DayTaskInfo) => {
            Row() {
              Image(taskBaseInfoList[item.taskId].icon)
                .width($r('app.float.default_36'))
                .height($r('app.float.default_36'))
                .objectFit(ImageFit.Contain)
                .margin({
                  right: $r('app.float.default_8')
                })

              Column() {
                Text(taskBaseInfoList[item.taskId].name)
                  .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('app.float.default_16'))

                Progress({ value: getDayTaskProgress(item), total: 100, type: ProgressType.Linear })
                  .width(Const.THOUSANDTH_1000)
                  .color($r('sys.color.brand'))
                  .margin({
                    top: $r('app.float.default_6')
                  })

                // Value text row, reusing the targetValueBuilder convention:
                // isDone -> "已完成"; otherwise finValue||'--' / targetValue / unit.
                if (item.isDone) {
                  Text($r('app.string.was_done'))
                    .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_primary'))
                    .fontSize($r('app.float.default_14'))
                    .margin({
                      top: $r('app.float.default_4')
                    })
                } else {
                  Row() {
                    Text(item.finValue || '--')
                      .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_primary'))
                      .fontSize($r('app.float.default_14'))

                    Text(' / ' + item.targetValue + ' ')
                      .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_primary'))
                      .fontSize($r('app.float.default_14'))

                    Text(taskBaseInfoList[item.taskId].unit)
                      .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_primary'))
                      .fontSize($r('app.float.default_14'))
                  }
                  .margin({
                    top: $r('app.float.default_4')
                  })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width(Const.THOUSANDTH_1000)
            .margin({
              top: $r('app.float.default_12')
            })
          }, (item: DayTaskInfo) => item.taskId.toString() + item.id.toString())
        }
        .width(Const.THOUSANDTH_1000)
        .margin({
          top: $r('app.float.default_8')
        })
      }

      Button($r('app.string.close'))
        .type(ButtonType.Capsule)
        .width(Const.THOUSANDTH_1000)
        .height($r('app.float.default_42'))
        .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
        .fontWeight(FontWeight.Regular)
        .fontSize($r('app.float.default_18'))
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.brand'))
        .margin({
          top: $r('app.float.default_24')
        })
        .onClick(() => {
          PromptActionClass.closeDialog();
        })
    }
    .width($r('app.float.default_316'))
    .padding($r('app.float.default_16'))
    .borderRadius($r('app.float.default_24'))
    .backgroundColor($r('sys.color.background_primary'))
  }
  .width(Const.THOUSANDTH_1000)
  .height(Const.THOUSANDTH_1000)
}
