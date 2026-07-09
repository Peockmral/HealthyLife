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
import {
  CommonConstants as Const, convertTime2Date, PickerType, PromptActionClass
} from 'common';
import { TargetSettingDialogParams } from '../../viewmodel/dialog/TargetSettingDialogParams';

export function openTargetSettingCustomDialog(uIContext: UIContext, params: TargetSettingDialogParams): void {
  PromptActionClass.setContext(uIContext);
  params.selectedValue = params.taskInfo.targetValue;
  let targetSettingDialogNode = new ComponentContent(uIContext, wrapBuilder(targetSettingDialogBuilder), params);
  PromptActionClass.setContentNode(targetSettingDialogNode);
  PromptActionClass.setOptions({
    alignment: DialogAlignment.Bottom,
    offset: {
      dx: Const.DEFAULT_0,
      dy: Const.DEFAULT_NEGATIVE_20
    }
  })
  PromptActionClass.openDialog();
}

@Builder
export function targetSettingDialogBuilder(params: TargetSettingDialogParams) {
  Column() {
    Row() {
      Text($r('app.string.target_setting'))
        .fontSize($r('app.float.default_20'))
        .fontWeight(FontWeight.Bold)
        .margin({
          top: $r('app.float.default_12'),
          right: $r('app.float.default_12'),
          bottom: $r('app.float.default_16')
        })
    }
    .width(Const.THOUSANDTH_1000)
    .height($r('app.float.default_56'))
    .justifyContent(FlexAlign.Center)

    if (params.taskBaseInfo.pickerType === PickerType.TIME) {
      TimePicker({
        selected: convertTime2Date(params.selectedValue),
        format: TimePickerFormat.HOUR_MINUTE,
        start: params.startDate,
        end: params.endDate
      })
        .margin({
          left: $r('app.float.default_24'),
          right: $r('app.float.default_24')
        })
        .useMilitaryTime(true)
        .onChange((value: TimePickerResult) => {
          if (value.hour != undefined && value.minute != undefined) {
            params.selectedValue = `${("0" + value.hour).slice(-2)}:${("0" + value.minute).slice(-2)}`;
          }
        })
    } else if (params.taskBaseInfo.pickerType === PickerType.TEXT) {
      TextPicker({
        range: params.taskBaseInfo.pickerRange,
        value: params.selectedValue
      })
        .width(Const.THOUSANDTH_900)
        .margin({
          left: $r('app.float.default_24'),
          right: $r('app.float.default_24')
        })
        .onChange((value: string | string[]) => {
          params.selectedValue = value as string;
        })
    }

    Row() {
      Text($r('app.string.cancel'))
        .fontColor($r('app.color.text_font_color'))
        .fontSize($r('app.float.default_20'))
        .onClick(() => {
          PromptActionClass.closeDialog();
        })

      Text($r('app.string.confirm'))
        .fontColor($r('app.color.text_font_color'))
        .fontSize($r('app.float.default_20'))
        .onClick(() => {
          params.taskInfo.targetValue = params.selectedValue;
          PromptActionClass.closeDialog();
        })
    }
    .width(Const.THOUSANDTH_1000)
    .height($r('app.float.default_56'))
    .justifyContent(FlexAlign.SpaceAround)
    .margin({
      top: $r('app.float.default_8')
    })
  }
  .backgroundColor($r('sys.color.background_primary'))
  .height(Const.THOUSANDTH_420)
  .justifyContent(FlexAlign.SpaceAround)
  .borderRadius($r('app.float.default_32'))
  .margin({
    left: $r('app.float.default_18'),
    right: $r('app.float.default_18'),
    bottom: Const.THOUSANDTH_500
  })
  .padding($r('app.float.default_12'))
}