import { CommonConstants as Const } from 'common';
import { ProfileStore } from '../../viewmodel/ProfileStore';

@Builder
export function personalDataBuilder() {
  PersonalDataComponent();
}

@Component
export struct PersonalDataComponent {
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
          Text($r('app.string.profile_title'))
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

        // Field rows
        Column() {
          // Avatar row
          Row() {
            Text($r('app.string.label_avatar'))
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('app.float.default_16'))
              .fontWeight(FontWeight.Medium)
            Blank()
            if (this.profileStore.userProfile.avatarUri !== '') {
              Image(this.profileStore.userProfile.avatarUri)
                .width(30)
                .height(30)
                .borderRadius('50%')
                .clip(true)
                .objectFit(ImageFit.Cover)
            } else {
              Image($r('app.media.person_crop_circle'))
                .width(30)
                .height(30)
            }
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.icon_fourth')])
              .fontWeight(FontWeight.Normal)
              .fontSize($r('app.float.default_20'))
          }
          .width(Const.THOUSANDTH_1000)
          .height(56)
          .padding({ left: $r('app.float.default_12'), right: $r('app.float.default_12') })
          .onClick(() => {
            this.pageStack.pushPathByName('AvatarEditComponent', '');
          })

          Divider().color($r('sys.color.comp_divider')).width(Const.THOUSANDTH_1000)

          // Nickname row
          Row() {
            Text($r('app.string.label_nickname'))
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('app.float.default_16'))
              .fontWeight(FontWeight.Medium)
            Blank()
            if (this.profileStore.userProfile.nickname !== '') {
              Text(this.profileStore.userProfile.nickname)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('app.float.default_14'))
            } else {
              Text($r('app.string.not_set'))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('app.float.default_14'))
            }
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.icon_fourth')])
              .fontWeight(FontWeight.Normal)
              .fontSize($r('app.float.default_20'))
          }
          .width(Const.THOUSANDTH_1000)
          .height(56)
          .padding({ left: $r('app.float.default_12'), right: $r('app.float.default_12') })
          .onClick(() => {
            this.pageStack.pushPathByName('NicknameEditComponent', '');
          })

          Divider().color($r('sys.color.comp_divider')).width(Const.THOUSANDTH_1000)

          // Gender row
          Row() {
            Text($r('app.string.label_gender'))
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('app.float.default_16'))
              .fontWeight(FontWeight.Medium)
            Blank()
            if (this.profileStore.userProfile.gender === 1) {
              Text($r('app.string.gender_male'))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('app.float.default_14'))
            } else if (this.profileStore.userProfile.gender === 2) {
              Text($r('app.string.gender_female'))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('app.float.default_14'))
            } else {
              Text($r('app.string.not_set'))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('app.float.default_14'))
            }
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.icon_fourth')])
              .fontWeight(FontWeight.Normal)
              .fontSize($r('app.float.default_20'))
          }
          .width(Const.THOUSANDTH_1000)
          .height(56)
          .padding({ left: $r('app.float.default_12'), right: $r('app.float.default_12') })
          .onClick(() => {
            this.pageStack.pushPathByName('GenderSelectComponent', '');
          })

          Divider().color($r('sys.color.comp_divider')).width(Const.THOUSANDTH_1000)

          // Birthday row
          Row() {
            Text($r('app.string.label_birthday'))
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('app.float.default_16'))
              .fontWeight(FontWeight.Medium)
            Blank()
            if (this.profileStore.userProfile.birthday !== '') {
              Text(this.profileStore.userProfile.birthday)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('app.float.default_14'))
            } else {
              Text($r('app.string.not_set'))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('app.float.default_14'))
            }
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.icon_fourth')])
              .fontWeight(FontWeight.Normal)
              .fontSize($r('app.float.default_20'))
          }
          .width(Const.THOUSANDTH_1000)
          .height(56)
          .padding({ left: $r('app.float.default_12'), right: $r('app.float.default_12') })
          .onClick(() => {
            this.pageStack.pushPathByName('BirthdayEditComponent', '');
          })

          Divider().color($r('sys.color.comp_divider')).width(Const.THOUSANDTH_1000)

          // Height row
          Row() {
            Text($r('app.string.label_height'))
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('app.float.default_16'))
              .fontWeight(FontWeight.Medium)
            Blank()
            if (this.profileStore.userProfile.height > 0) {
              Text(this.profileStore.userProfile.height + 'cm')
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('app.float.default_14'))
            } else {
              Text($r('app.string.not_set'))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('app.float.default_14'))
            }
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.icon_fourth')])
              .fontWeight(FontWeight.Normal)
              .fontSize($r('app.float.default_20'))
          }
          .width(Const.THOUSANDTH_1000)
          .height(56)
          .padding({ left: $r('app.float.default_12'), right: $r('app.float.default_12') })
          .onClick(() => {
            this.pageStack.pushPathByName('HeightEditComponent', '');
          })

          Divider().color($r('sys.color.comp_divider')).width(Const.THOUSANDTH_1000)

          // Weight row
          Row() {
            Text($r('app.string.label_weight'))
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('app.float.default_16'))
              .fontWeight(FontWeight.Medium)
            Blank()
            if (this.profileStore.userProfile.weight > 0) {
              Text(this.profileStore.userProfile.weight + 'kg')
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('app.float.default_14'))
            } else {
              Text($r('app.string.not_set'))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('app.float.default_14'))
            }
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.icon_fourth')])
              .fontWeight(FontWeight.Normal)
              .fontSize($r('app.float.default_20'))
          }
          .width(Const.THOUSANDTH_1000)
          .height(56)
          .padding({ left: $r('app.float.default_12'), right: $r('app.float.default_12') })
          .onClick(() => {
            this.pageStack.pushPathByName('WeightEditComponent', '');
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
}
