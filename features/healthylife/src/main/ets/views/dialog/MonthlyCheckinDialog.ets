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

import { ComponentContent } from '@kit.ArkUI';
import { i18n } from '@kit.LocalizationKit';
import { CommonConstants as Const, PromptActionClass } from 'common';
import { MonthlyCheckinDialogParams, MonthDayCellData } from '../../viewmodel/dialog/MonthlyCheckinDialogParams';

/*
 * Open the centered monthly check-in dialog. Reuses the global PromptActionClass +
 * ComponentContent + wrapBuilder pattern (same as DayTaskProgressDialog).
 * The dialog pre-computes month data before showing.
 */
export async function openMonthlyCheckinDialog(uIContext: UIContext,
  params: MonthlyCheckinDialogParams): Promise<void> {
  // Pre-compute the initial month data before creating the dialog content.
  await params.recomputeMonthData();

  PromptActionClass.setContext(uIContext);
  let monthlyCheckinDialogNode = new ComponentContent(uIContext,
    wrapBuilder(monthlyCheckinDialogBuilder), params);
  PromptActionClass.setContentNode(monthlyCheckinDialogNode);
  // Reset alignment explicitly: force center.
  PromptActionClass.setOptions({
    alignment: DialogAlignment.Center
  });
  PromptActionClass.openDialog();
}

/*
 * Month navigation: decrement the month, wrapping from Jan to Dec of the
 * previous year, then recompute the grid data.
 */
function prevMonth(params: MonthlyCheckinDialogParams): void {
  params.currentMonth--;
  if (params.currentMonth < 1) {
    params.currentMonth = 12;
    params.currentYear--;
  }
  params.recomputeMonthData();
}

/*
 * Month navigation: increment the month, wrapping from Dec to Jan of the
 * next year, then recompute the grid data.
 */
function nextMonth(params: MonthlyCheckinDialogParams): void {
  params.currentMonth++;
  if (params.currentMonth > 12) {
    params.currentMonth = 1;
    params.currentYear++;
  }
  params.recomputeMonthData();
}

/*
 * Format the current year/month as a locale-aware string (e.g. "2026年7月" / "July 2026").
 */
function formatYearMonth(year: number, month: number): string {
  const locale: string = i18n.System.getSystemLanguage();
  const formatter: Intl.DateTimeFormat = new Intl.DateTimeFormat(locale, {
    year: 'numeric',
    month: 'long'
  });
  return formatter.format(new Date(year, month - 1, 1));
}

/*
 * The main dialog content component. Uses @ObjectLink to observe @Observed
 * MonthlyCheckinDialogParams, so property changes (currentYear, currentMonth,
 * monthData) trigger automatic re-render.
 */
@Component
struct MonthlyCheckinDialogContent {
  @ObjectLink params: MonthlyCheckinDialogParams;

  build() {
    Column() {
      // Title: "Monthly Check-in"
      Text($r('app.string.monthly_checkin'))
        .fontFamily(Const.HARMONY_HEI_TI_BOLD)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('app.float.default_22'))

      // Month navigation: left arrow + year/month text + right arrow
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontColor([$r('sys.color.icon_secondary')])
          .fontWeight(FontWeight.Normal)
          .fontSize($r('app.float.default_18'))
          .clickEffect({
            level: ClickEffectLevel.HEAVY,
            scale: Const.SYMBOL_GLYPH_CLICK_SCALE
          })
          .onClick(() => {
            prevMonth(this.params);
          })

        Text(formatYearMonth(this.params.currentYear, this.params.currentMonth))
          .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('app.float.default_16'))
          .margin({
            left: $r('app.float.default_12'),
            right: $r('app.float.default_12')
          })

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontColor([$r('sys.color.icon_secondary')])
          .fontWeight(FontWeight.Normal)
          .fontSize($r('app.float.default_18'))
          .clickEffect({
            level: ClickEffectLevel.HEAVY,
            scale: Const.SYMBOL_GLYPH_CLICK_SCALE
          })
          .onClick(() => {
            nextMonth(this.params);
          })
      }
      .justifyContent(FlexAlign.Center)
      .margin({
        top: $r('app.float.default_12')
      })

      // Weekday header: Mon~Sun (reusing WEEK_SHORTHAND_LIST)
      Row() {
        ForEach(Const.WEEK_SHORTHAND_LIST, (dayName: Resource, index: number) => {
          Text(dayName)
            .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('app.float.default_10'))
            .width(Const.PERCENTAGE_100_EXCEPT_7)
            .textAlign(TextAlign.Center)
        }, (dayName: Resource, index: number) => index.toString())
      }
      .width(Const.THOUSANDTH_1000)
      .margin({
        top: $r('app.float.default_12')
      })

      // Calendar grid: 7 columns
      Grid() {
        ForEach(this.params.monthData, (cell: MonthDayCellData) => {
          GridItem() {
            if (!cell.isCurrentMonth || cell.dateStr === '') {
              // Empty placeholder cell for offset
              Column()
                .width(Const.THOUSANDTH_1000)
                .height(Const.THOUSANDTH_1000)
            } else if (cell.isFuture) {
              // Future date: grey background, day number only, no icon/percentage
              Column() {
                Text(cell.dayOfMonth.toString())
                  .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_tertiary'))
                  .fontSize($r('app.float.default_12'))
              }
              .width(Const.THOUSANDTH_1000)
              .justifyContent(FlexAlign.Center)
              .backgroundColor($r('sys.color.background_tertiary'))
              .borderRadius($r('app.float.default_8'))
            } else {
              // Historical date: progress icon + percentage + day number
              Column() {
                Image(cell.progressImg)
                  .width($r('app.float.default_20'))
                  .height($r('app.float.default_20'))
                  .objectFit(ImageFit.Contain)

                Text(cell.percentage + Const.PERCENT)
                  .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('app.float.default_10'))
                  .margin({
                    top: $r('app.float.default_2')
                  })

                Text(cell.dayOfMonth.toString())
                  .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('app.float.default_10'))
              }
              .width(Const.THOUSANDTH_1000)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
          }
        }, (cell: MonthDayCellData) => cell.dateStr + (cell.isFuture ? 'f' : 'p') + cell.percentage)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
      .width(Const.THOUSANDTH_1000)
      .height(280)
      .margin({
        top: $r('app.float.default_8')
      })

      // Cancel button
      Button($r('app.string.cancel'))
        .type(ButtonType.Capsule)
        .width(Const.THOUSANDTH_1000)
        .height($r('app.float.default_42'))
        .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
        .fontWeight(FontWeight.Regular)
        .fontSize($r('app.float.default_18'))
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.brand'))
        .margin({
          top: $r('app.float.default_16')
        })
        .onClick(() => {
          PromptActionClass.closeDialog();
        })
    }
    .width($r('app.float.default_316'))
    .padding($r('app.float.default_16'))
    .borderRadius($r('app.float.default_24'))
    .backgroundColor($r('sys.color.background_primary'))
  }
}

@Builder
export function monthlyCheckinDialogBuilder(params: MonthlyCheckinDialogParams) {
  Stack({ alignContent: Alignment.Center }) {
    // Backdrop: full-screen transparent layer. Clicking it closes the dialog.
    // The card below is a sibling (not a child), so clicks on the card do NOT
    // bubble to this backdrop — sibling layering avoids the issue entirely.
    Column()
      .width(Const.THOUSANDTH_1000)
      .height(Const.THOUSANDTH_1000)
      .onClick(() => {
        PromptActionClass.closeDialog();
      })

    // Card: dialog content rendered via a @Component with @ObjectLink.
    // This enables reactive updates when params properties change (month switch).
    MonthlyCheckinDialogContent({ params: params })
  }
  .width(Const.THOUSANDTH_1000)
  .height(Const.THOUSANDTH_1000)
}
