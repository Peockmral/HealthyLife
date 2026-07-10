import { CommonConstants as Const } from 'common';
import { ProfileStore, updateProfileField } from '../../viewmodel/ProfileStore';

@Builder
export function nicknameEditBuilder() {
  NicknameEditComponent();
}

@Component
export struct NicknameEditComponent {
  @Consume profileStore: ProfileStore;
  @Consume('pathStack') pageStack: NavPathStack;
  @State nicknameText: string = '';

  aboutToAppear(): void {
    this.nicknameText = this.profileStore.userProfile.nickname;
  }

  build() {
    NavDestination() {
      Column() {
        // Title bar
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
          Text($r('app.string.edit_nickname'))
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

        // Input
        TextInput({ placeholder: '请输入昵称', text: this.nicknameText })
          .width(Const.THOUSANDTH_940)
          .height(56)
          .maxLength(20)
          .margin({ top: $r('app.float.default_20'), left: $r('app.float.default_12'), right: $r('app.float.default_12') })
          .onChange((value: string) => {
            this.nicknameText = value;
          })

        // Save button
        Button($r('app.string.save'))
          .width(Const.THOUSANDTH_940)
          .height(44)
          .fontSize($r('app.float.default_16'))
          .margin({ top: 24, left: $r('app.float.default_12'), right: $r('app.float.default_12') })
          .onClick(() => {
            this.saveNickname();
          })
      }
      .width(Const.THOUSANDTH_1000)
      .height(Const.THOUSANDTH_1000)
      .backgroundColor($r('sys.color.background_secondary'))
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

  private async saveNickname(): Promise<void> {
    if (this.nicknameText.trim() === '') {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.nickname_empty_error').toString() });
      return;
    }
    const newStore: ProfileStore = await updateProfileField(Const.USER_NICKNAME, this.nicknameText);
    this.profileStore = newStore;
    this.pageStack.pop();
  }
}
