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

import { HomeComponent } from '../views/HomeComponent';
import { MineComponent } from '../views/MineComponent';
import { NavList, TabId } from '../model/NavItemModel';
import { CommonConstants as Const } from 'common';
import { AchievementStore, initAchievementStore } from '../viewmodel/AchievementStore';
import { HomeStore } from '../viewmodel/HomeStore';
import { ProfileStore, initProfileStore } from '../viewmodel/ProfileStore';
import { UserProfile } from '../model/UserProfile';
import { AuthUtils } from 'common/src/main/ets/utils/AuthUtils';
import { LoginComponent } from '../views/auth/LoginComponent';
import { common } from '@kit.AbilityKit';

@Component
export struct HealthyLifePage {
  @State currentIndex: number = 0;
  @Provide achievementStore: AchievementStore = new AchievementStore(0, 0, false);
  @Provide('pathStack') pageStack: NavPathStack = new NavPathStack();
  @Provide homeStore: HomeStore = new HomeStore([], -1, '', []);
  @Provide profileStore: ProfileStore = new ProfileStore(new UserProfile('', '', 0, '', 0, 0));
  @Provide isLoggedIn: boolean = false;
  private context = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
  private windowClass = this.context.windowStage.getMainWindowSync();

  async aboutToAppear(): Promise<void> {
    try {
      await this.windowClass.setWindowLayoutFullScreen(true);
      await this.windowClass.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        statusBarContentColor: '#FF000000'
      })
    } catch (error) {
      console.error(`an error occurred: ${error}`);
    }
    this.achievementStore = await initAchievementStore();
    this.profileStore = await initProfileStore();
    this.isLoggedIn = await AuthUtils.isLoggedIn();
  }

  build() {
    Navigation(this.pageStack) {
      if (this.isLoggedIn) {
        Tabs({ barPosition: BarPosition.End }) {
          TabContent() {
            HomeComponent()
          }
          .tabBar(this.tabBuilder(TabId.HOME))

          TabContent() {
            MineComponent()
          }
          .tabBar(this.tabBuilder(TabId.MINE))
        }
        .backgroundColor($r('sys.color.background_secondary'))
        .scrollable(false)
        .width(Const.THOUSANDTH_1000)
        .height(Const.THOUSANDTH_1000)
        .barWidth(Const.THOUSANDTH_940)
        .vertical(false)
        .divider({
          strokeWidth: 1,
          color: $r('sys.color.background_tertiary')
        })
        .onChange((index) => {
          this.currentIndex = index;
        })
      } else {
        LoginComponent()
      }
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  tabBuilder(index: number) {
    Column() {
      Image(index === this.currentIndex ? NavList[index].icon_selected : NavList[index].icon)
        .width($r('app.float.default_24'))
        .height($r('app.float.default_24'))
        .objectFit(ImageFit.Contain);

      Text(NavList[index].text)
        .fontSize($r('app.float.default_10'))
        .fontWeight(FontWeight.Regular)
        .fontColor(this.currentIndex === index ? $r('app.color.text_font_color') : $r('sys.color.font_tertiary'))
        .margin({
          top: $r('app.float.default_4')
        })
    }
    .justifyContent(FlexAlign.Center)
    .width(Const.THOUSANDTH_1000)
    .height(Const.THOUSANDTH_1000)
  }
}