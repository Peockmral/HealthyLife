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

@Component
export struct LoginComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @Consume isLoggedIn: boolean;
  @State username: string = '';
  @State password: string = '';

  build() {
    Column() {
      Text($r('app.string.login_title'))
        .fontFamily($r(Const.HARMONY_HEI_TI_BOLD))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('app.float.default_28'))
        .margin({ top: 100, bottom: 40 })
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
        .margin({ bottom: 32 })
        .onChange((value: string) => {
          this.password = value;
        })

      Button($r('app.string.login_button'))
        .width(Const.THOUSANDTH_880)
        .height(48)
        .fontSize($r('app.float.default_18'))
        .type(ButtonType.Capsule)
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('app.color.task_clock_bg_color'))
        .margin({ bottom: 20 })
        .onClick(() => {
          this.handleLogin();
        })

      Text($r('app.string.register_button'))
        .fontFamily($r(Const.HARMONY_HEI_TI))
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('app.float.default_16'))
        .margin({ bottom: 20 })
        .onClick(() => {
          this.pageStack.pushPathByName('RegisterComponent', '');
        })
    }
    .width(Const.THOUSANDTH_1000)
    .height(Const.THOUSANDTH_1000)
    .backgroundColor($r('sys.color.background_secondary'))
    .alignItems(HorizontalAlign.Center)
  }

  private async handleLogin(): Promise<void> {
    if (this.username.trim() === '') {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.username_empty') });
      return;
    }
    if (this.password.trim() === '') {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.password_empty') });
      return;
    }
    const valid: boolean = await AuthUtils.validateLogin(this.username.trim(), this.password.trim());
    if (valid) {
      await AuthUtils.setLoggedIn(true);
      this.isLoggedIn = true;
    } else {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.login_failed') });
    }
  }
}
