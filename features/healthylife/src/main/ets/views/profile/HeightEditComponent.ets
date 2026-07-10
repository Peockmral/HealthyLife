import { CommonConstants as Const } from 'common';
import { ProfileStore, updateProfileField } from '../../viewmodel/ProfileStore';

@Builder
export function heightEditBuilder() {
  HeightEditComponent();
}

@Component
export struct HeightEditComponent {
  @Consume profileStore: ProfileStore;
  @Consume('pathStack') pageStack: NavPathStack;
  @State selectedIndex: number = 70;
  private heightRange: string[] = [];

  aboutToAppear(): void {
    this.heightRange = this.generateRange();
    if (this.profileStore.userProfile.height > 0) {
      this.selectedIndex = this.profileStore.userProfile.height - 100;
    } else {
      this.selectedIndex = 70; // default 170cm
    }
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
          Text($r('app.string.edit_height'))
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

        // Picker with unit label
        Row() {
          TextPicker({ range: this.heightRange, selected: this.selectedIndex })
            .onChange((value: string | string[], index: number | number[]) => {
              if (typeof index === 'number') {
                this.selectedIndex = index;
              }
            })
            .width(200)

          Text($r('app.string.unit_cm'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('app.float.default_16'))
            .margin({ left: 8 })
        }
        .margin({ top: 40 })
        .justifyContent(FlexAlign.Center)

        // Save button
        Button($r('app.string.save'))
          .width(Const.THOUSANDTH_940)
          .height(44)
          .fontSize($r('app.float.default_16'))
          .margin({ top: 40, left: $r('app.float.default_12'), right: $r('app.float.default_12') })
          .onClick(() => {
            this.saveHeight();
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

  private generateRange(): string[] {
    const range: string[] = [];
    for (let i = 100; i <= 250; i++) {
      range.push(String(i));
    }
    return range;
  }

  private async saveHeight(): Promise<void> {
    const value: string = this.heightRange[this.selectedIndex];
    const newStore: ProfileStore = await updateProfileField(Const.USER_HEIGHT, value);
    this.profileStore = newStore;
    this.pageStack.pop();
  }
}
