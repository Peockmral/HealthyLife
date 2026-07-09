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

import { CommonConstants as Const } from 'common';

@Reusable
@Component
export struct UserInfoComponent {
  build() {
    Row({ space: $r('app.float.default_12') }) {
      Image($r('app.media.person_crop_circle'))
        .width($r('app.float.default_48'))
        .height($r('app.float.default_48'))

      Text($r('app.string.user_name'))
        .fontColor($r('app.color.mine_font_color'))
        .fontSize($r('app.float.default_18'))
        .fontWeight(FontWeight.Medium)
    }
    .width(Const.THOUSANDTH_940)
    .height(Const.THOUSANDTH_130)
    .borderRadius($r('app.float.default_16'))
    .padding({
      left: $r('app.float.default_12'),
      right: $r('app.float.default_12')
    })
    .backgroundColor($r('sys.color.background_primary'))
    .margin({
      bottom: $r('app.float.default_6')
    })
  }
}