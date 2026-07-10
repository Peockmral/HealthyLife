import { CommonConstants as Const } from 'common';
import { ProfileStore, updateProfileField } from '../../viewmodel/ProfileStore';

@Builder
export function weightEditBuilder() {
  WeightEditComponent();
}

@Component
export struct WeightEditComponent {
  @Consume profileStore: ProfileStore;
  @Consume('pathStack') pageStack: NavPathStack;
  @State selectedIndex: number = 450;
  private weightRange: string[] = [];

  aboutToAppear(): void {
    this.weightRange = this.generateRange();
    if (this.profileStore.userProfile.weight > 0) {
      this.selectedIndex = Math.round((this.profileStore.userProfile.weight - 20) * 10);
    } else {
      this.selectedIndex = 450; // default 65.0kg (index 450 = 20.0 + 450*0.1 = 65.0)
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
          Text($r('app.string.edit_weight'))
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
          TextPicker({ range: this.weightRange, selected: this.selectedIndex })
            .onChange((value: string | string[], index: number | number[]) => {
              if (typeof index === 'number') {
                this.selectedIndex = index;
              }
            })
            .width(200)

          Text($r('app.string.unit_kg'))
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
            this.saveWeight();
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
    for (let i = 0; i <= 2800; i++) {
      const value: number = 20 + i * 0.1;
      range.push(value.toFixed(1));
    }
    return range;
  }

  private async saveWeight(): Promise<void> {
    const value: string = this.weightRange[this.selectedIndex];
    const newStore: ProfileStore = await updateProfileField(Const.USER_WEIGHT, value);
    this.profileStore = newStore;
    this.pageStack.pop();
  }
}
