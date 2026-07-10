/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CommonConstants as Const } from 'common';
import { AuthUtils } from 'common/src/main/ets/utils/AuthUtils';

@Builder
export function registerBuilder() {
  RegisterComponent();
}

@Component
export struct RegisterComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.ach_back'))
            .height($r('app.float.default_40'))
            .width($r('app.float.default_40'))
            .margin({
              right: $r('app.float.default_8')
            })
            .onClick(() => {
              this.pageStack.pop();
            })
          Text($r('app.string.register_title'))
            .fontFamily($r(Const.HARMONY_HEI_TI_MEDIUM))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('app.float.default_20'))
            .width(Const.THOUSANDTH_1000)
            .height($r('app.float.default_56'))
        }
        .margin({
          left: $r('app.float.default_12'),
          right: $r('app.float.default_12')
        })

        Text($r('app.string.register_title'))
          .fontFamily($r(Const.HARMONY_HEI_TI_BOLD))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('app.float.default_28'))
          .margin({ top: 60, bottom: 40 })
          .width(Const.THOUSANDTH_1000)
          .textAlign(TextAlign.Center)

        TextInput({ placeholder: $r('app.string.username_label'), text: this.username })
          .width(Const.THOUSANDTH_880)
          .height(50)
          .fontSize($r('app.float.default_16'))
          .margin({ bottom: 16 })
          .onChange((value: string) => {
            this.username = value;
          })

        TextInput({ placeholder: $r('app.string.password_label'), text: this.password })
          .type(InputType.Password)
          .width(Const.THOUSANDTH_880)
          .height(50)
          .fontSize($r('app.float.default_16'))
          .margin({ bottom: 16 })
          .onChange((value: string) => {
            this.password = value;
          })

        TextInput({ placeholder: $r('app.string.confirm_password_label'), text: this.confirmPassword })
          .type(InputType.Password)
          .width(Const.THOUSANDTH_880)
          .height(50)
          .fontSize($r('app.float.default_16'))
          .margin({ bottom: 32 })
          .onChange((value: string) => {
            this.confirmPassword = value;
          })

        Button($r('app.string.register_button'))
          .width(Const.THOUSANDTH_880)
          .height(48)
          .fontSize($r('app.float.default_18'))
          .type(ButtonType.Capsule)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('app.color.task_clock_bg_color'))
          .margin({ bottom: 20 })
          .onClick(() => {
            this.handleRegister();
          })

        Text($r('app.string.login_button'))
          .fontFamily($r(Const.HARMONY_HEI_TI))
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('app.float.default_16'))
          .onClick(() => {
            this.pageStack.pop();
          })
      }
      .width(Const.THOUSANDTH_1000)
      .height(Const.THOUSANDTH_1000)
      .backgroundColor($r('sys.color.background_secondary'))
      .alignItems(HorizontalAlign.Center)
    }
    .size({
      width: Const.THOUSANDTH_1000,
      height: Const.THOUSANDTH_1000
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .padding({
      top: $r('app.float.default_40')
    })
  }

  private async handleRegister(): Promise<void> {
    if (this.username.trim() === '') {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.username_empty') });
      return;
    }
    if (this.password.trim() === '') {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.password_empty') });
      return;
    }
    if (this.password !== this.confirmPassword) {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.password_mismatch') });
      return;
    }
    const success: boolean = await AuthUtils.registerUser(this.username.trim(), this.password.trim());
    if (success) {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.register_success') });
      this.pageStack.pop();
    } else {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.user_exists') });
    }
  }
}
