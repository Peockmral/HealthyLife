import { CommonConstants as Const } from 'common';
import { ProfileStore, updateProfileField } from '../../viewmodel/ProfileStore';

@Builder
export function birthdayEditBuilder() {
  BirthdayEditComponent();
}

@Component
export struct BirthdayEditComponent {
  @Consume profileStore: ProfileStore;
  @Consume('pathStack') pageStack: NavPathStack;
  @State selectedDate: Date = new Date();
  @State dateSelected: boolean = false;

  aboutToAppear(): void {
    if (this.profileStore.userProfile.birthday !== '') {
      const parts: string[] = this.profileStore.userProfile.birthday.split('-');
      if (parts.length === 3) {
        this.selectedDate = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
        this.dateSelected = true;
      }
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
          Text($r('app.string.edit_birthday'))
            .fontFamily($r(Const.HARMONY_HEI_TI_MEDIUM))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize($r('app.float.default_20'))
            .width(Const.THOUSANDTH_1000)
            .height($r('app.float.default_56'))
        }
        .margin({
          left: $r('app.float.default_12'),
          right: $r('app.float.default_12')
        })

        // Current birthday display
        Column() {
          if (this.dateSelected) {
            Text(this.formatDate(this.selectedDate))
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('app.float.default_18'))
              .fontWeight(FontWeight.Medium)
          } else if (this.profileStore.userProfile.birthday !== '') {
            Text(this.profileStore.userProfile.birthday)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('app.float.default_18'))
              .fontWeight(FontWeight.Medium)
          } else {
            Text($r('app.string.not_set'))
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('app.float.default_18'))
          }
        }
        .margin({ top: 30 })

        // Select date button
        Button($r('app.string.select_date'))
          .width(200)
          .height(44)
          .fontSize($r('app.float.default_16'))
          .margin({ top: 24 })
          .onClick(() => {
            this.showDatePicker();
          })

        // Save button
        Button($r('app.string.save'))
          .width(Const.THOUSANDTH_940)
          .height(44)
          .fontSize($r('app.float.default_16'))
          .margin({ top: 24, left: $r('app.float.default_12'), right: $r('app.float.default_12') })
          .onClick(() => {
            this.saveBirthday();
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

  private showDatePicker(): void {
    const startDate: Date = new Date('1900-01-01');
    const endDate: Date = new Date();
    const defaultDate: Date = this.dateSelected ? this.selectedDate : new Date();
    this.getUIContext().showDatePickerDialog({
      start: startDate,
      end: endDate,
      selected: defaultDate,
      onDateAccept: (value: Date) => {
        this.selectedDate = value;
        this.dateSelected = true;
      }
    });
  }

  private formatDate(date: Date): string {
    const year: number = date.getFullYear();
    const month: number = date.getMonth() + 1;
    const day: number = date.getDate();
    const monthStr: string = month < 10 ? '0' + month : String(month);
    const dayStr: string = day < 10 ? '0' + day : String(day);
    return `${year}-${monthStr}-${dayStr}`;
  }

  private async saveBirthday(): Promise<void> {
    if (!this.dateSelected && this.profileStore.userProfile.birthday === '') {
      this.getUIContext().getPromptAction().showToast({ message: '请先选择日期' });
      return;
    }
    const dateStr: string = this.formatDate(this.selectedDate);
    const newStore: ProfileStore = await updateProfileField(Const.USER_BIRTHDAY, dateStr);
    this.profileStore = newStore;
    this.pageStack.pop();
  }
}
