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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants as Const } from 'common';

// hilog tag.
const TAG: string = 'SplashPage';

@Entry
@Component
struct SplashPage {

  jumpAdPage() {
    setTimeout(() => {
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/AdvertisingPage' }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `Jump to advertising page failed, code is ${err.code},message is ${err.message}`);
      });
    }, Const.LAUNCHER_DELAY_TIME);
  }

  aboutToAppear() {
    this.jumpAdPage();
  }

  aboutToDisappear() {
    clearTimeout();
  }

  build() {
    Column() {
      Image($r('app.media.logo'))
        .width($r('app.float.default_120'))
        .aspectRatio(Const.DEFAULT_ASPECT_RATIO)
        .margin({
          top: $r('app.float.default_120')
        });

      Text($r('app.string.EntryAbility_label'))
        .fontFamily(Const.HARMONY_HEI_TI_BOLD)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('app.float.default_24'))
        .letterSpacing($r('app.float.letter_space_1'))
        .margin({
          top: $r('app.float.default_20'),
          bottom: $r('app.float.default_8')
        })

      Text($r('app.string.EntryAbility_desc'))
        .fontFamily(Const.HARMONY_HEI_TI)
        .fontWeight(FontWeight.Normal)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('app.float.default_16'))
        .letterSpacing($r('app.float.letter_space_34'))
        .opacity($r('app.float.opacity_6'))
    }
    .width(Const.THOUSANDTH_1000)
    .height(Const.THOUSANDTH_1000)
    .backgroundImagePosition({
      x: $r('app.float.default_0'),
      y: $r('app.float.default_0')
    })
    .backgroundImage($r('app.media.ic_splash_bg'))
    .backgroundImageSize({
      width: Const.THOUSANDTH_1000,
      height: Const.THOUSANDTH_1000
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}