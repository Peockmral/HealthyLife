import { CommonConstants as Const } from 'common';
import { ProfileStore, updateProfileField } from '../../viewmodel/ProfileStore';

@Builder
export function genderSelectBuilder() {
  GenderSelectComponent();
}

@Component
export struct GenderSelectComponent {
  @Consume profileStore: ProfileStore;
  @Consume('pathStack') pageStack: NavPathStack;

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
          Text($r('app.string.select_gender'))
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

        // Options
        Column() {
          // Male row
          Row() {
            Text($r('app.string.gender_male'))
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('app.float.default_16'))
              .fontWeight(FontWeight.Medium)
            Blank()
            if (this.profileStore.userProfile.gender === 1) {
              SymbolGlyph($r('sys.symbol.checkmark'))
                .fontColor([$r('sys.color.icon_emphasize')])
                .fontWeight(FontWeight.Bold)
                .fontSize($r('app.float.default_20'))
            }
          }
          .width(Const.THOUSANDTH_1000)
          .height(56)
          .padding({ left: $r('app.float.default_12'), right: $r('app.float.default_12') })
          .onClick(() => {
            this.selectGender(1);
          })

          Divider().color($r('sys.color.comp_divider')).width(Const.THOUSANDTH_1000)

          // Female row
          Row() {
            Text($r('app.string.gender_female'))
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('app.float.default_16'))
              .fontWeight(FontWeight.Medium)
            Blank()
            if (this.profileStore.userProfile.gender === 2) {
              SymbolGlyph($r('sys.symbol.checkmark'))
                .fontColor([$r('sys.color.icon_emphasize')])
                .fontWeight(FontWeight.Bold)
                .fontSize($r('app.float.default_20'))
            }
          }
          .width(Const.THOUSANDTH_1000)
          .height(56)
          .padding({ left: $r('app.float.default_12'), right: $r('app.float.default_12') })
          .onClick(() => {
            this.selectGender(2);
          })
        }
        .width(Const.THOUSANDTH_940)
        .borderRadius($r('app.float.default_16'))
        .backgroundColor($r('sys.color.background_primary'))
        .margin({
          top: $r('app.float.default_12'),
          left: $r('app.float.default_12'),
          right: $r('app.float.default_12')
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

  private async selectGender(gender: number): Promise<void> {
    const newStore: ProfileStore = await updateProfileField(Const.USER_GENDER, String(gender));
    this.profileStore = newStore;
    this.pageStack.pop();
  }
}
