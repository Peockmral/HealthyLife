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
import { UserInfoComponent } from './mine/UserInfoComponent';

@Component
export struct MineComponent {
  @Provide uiContext: UIContext = this.getUIContext();
  @Consume('pathStack') pageStack: NavPathStack;

  build() {
    Navigation() {
      Column() {
        UserInfoComponent()
        Row({ space: $r('app.float.default_16') }) {
          Image($r('app.media.book_closed_per'))
            .width($r('app.float.default_24'))
            .height($r('app.float.default_24'))
          Text($r('app.string.mine_personal_data'))
            .fontColor($r('app.color.mine_font_color'))
            .fontSize($r('app.float.default_18'))
            .fontWeight(FontWeight.Medium)
          Blank();
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.icon_fourth')])
            .fontWeight(FontWeight.Normal)
            .fontSize($r('app.float.default_24'))
        }
        .width(Const.THOUSANDTH_940)
        .height(Const.THOUSANDTH_100)
        .borderRadius({
          topLeft: $r('app.float.default_16'),
          topRight: $r('app.float.default_16')
        })
        .padding({
          left: $r('app.float.default_12'),
          right: $r('app.float.default_12')
        })
        .backgroundColor($r('sys.color.background_primary'))
        .margin({
          top: $r('app.float.default_6')
        })

        Divider()
          .color($r('app.float.default_1'))
          .width(Const.THOUSANDTH_880)
        Row({ space: $r('app.float.default_16') }) {
          Image($r('app.media.arrow_up_circle'))
            .width($r('app.float.default_24'))
            .height($r('app.float.default_24'))
          Text($r('app.string.mine_check_updates'))
            .fontColor($r('app.color.mine_font_color'))
            .fontSize($r('app.float.default_18'))
            .fontWeight(FontWeight.Medium)
          Blank();
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.icon_fourth')])
            .fontWeight(FontWeight.Normal)
            .fontSize($r('app.float.default_24'))
        }
        .width(Const.THOUSANDTH_940)
        .height(Const.THOUSANDTH_100)
        .borderRadius({
          bottomLeft: $r('app.float.default_16'),
          bottomRight: $r('app.float.default_16')
        })
        .padding({
          left: $r('app.float.default_12'),
          right: $r('app.float.default_12')
        })
        .backgroundColor($r('sys.color.background_primary'))
        .margin({
          bottom: $r('app.float.default_6')
        })

        Row({ space: $r('app.float.default_16') }) {
          Image($r('app.media.star_trophy'))
            .width($r('app.float.default_24'))
            .height($r('app.float.default_24'))
          Text($r('app.string.mine_achievement'))
            .fontColor($r('app.color.mine_font_color'))
            .fontSize($r('app.float.default_18'))
            .fontWeight(FontWeight.Medium)
          Blank();
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.icon_fourth')])
            .fontWeight(FontWeight.Normal)
            .fontSize($r('app.float.default_24'))
        }
        .width(Const.THOUSANDTH_940)
        .height(Const.THOUSANDTH_100)
        .borderRadius($r('app.float.default_16'))
        .padding({
          left: $r('app.float.default_12'),
          right: $r('app.float.default_12')
        })
        .backgroundColor($r('sys.color.background_primary'))
        .margin({
          top: $r('app.float.default_6')
        })
        .onClick(() => {
          this.pageStack.pushPathByName('AchievementComponent', '');
        })
      }
      .width(Const.THOUSANDTH_1000)
      .height(Const.THOUSANDTH_1000)
    }
    .title($r('app.string.tab_mine'))
    .backgroundColor($r('sys.color.background_secondary'))
  }
}