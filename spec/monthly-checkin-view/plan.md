# Implementation Plan: 月度打卡视图弹窗

**Input**: Feature specification from `spec/monthly-checkin-view/spec.md`

## Summary

在 WeekCalendarComponent 日期导航栏右侧新增图标按钮，点击弹出居中月视图弹窗。弹窗使用 PromptActionClass + ComponentContent + wrapBuilder 全局对话框模式，显示当月日历网格（Grid 7列），每天格子含进度状态图标+完成率百分比，支持左右切换月份，未来日期灰色不可交互，点外部/取消关闭。

## Technical Context

**Language/Version**: ArkTS (HarmonyOS SDK)
**Primary Dependencies**: @kit.ArkUI (ComponentContent, promptAction), existing PromptActionClass
**Storage**: 关系型数据库 (DayInfoApi.queryByKey 逐天查询)
**Testing**: 无自动化测试;模拟器 UI 验证
**Target Platform**: HarmonyOS 模拟器
**Project Type**: 移动应用功能增量
**Performance Goals**: 月份切换 <1s 渲染(31次 queryByKey 查询)
**Constraints**: PromptActionClass 全局单例；弹窗快照模式；@Builder 全局函数+wrapBuilder
**Scale/Scope**: 1个弹窗组件+1个参数类+1个入口改造+3个资源串

## Project Structure

### Documentation (this feature)

```text
spec/monthly-checkin-view/
├── spec.md              # Feature specification
├── plan.md              # This file
└── tasks.md             # Task breakdown (Phase 3)
```

### Source Code (repository root)

```text
features/healthylife/src/main/ets/
├── viewmodel/dialog/
│   └── MonthlyCheckinDialogParams.ets    # NEW: 弹窗参数类
├── views/dialog/
│   └── MonthlyCheckinDialog.ets          # NEW: 月视图弹窗(open+@Builder+Grid)
└── views/home/
    └── WeekCalendarComponent.ets         # MODIFIED: 导航栏右侧加图标按钮

commons/common/src/main/resources/
├── base/element/string.json              # MODIFIED: 新增3个资源串
├── en_US/element/string.json             # MODIFIED: 英文版
└── zh_CN/element/string.json             # MODIFIED: 中文版
```

**Structure Decision**: 遵循现有对话框模式(MonthlyCheckinDialog + MonthlyCheckinDialogParams),与 DayTaskProgressDialog 保持一致。

## Complexity Tracking

无 Constitution Check 违规。

## Research & Decisions

### D1: 弹窗技术方案
**Decision**: 复用 PromptActionClass + ComponentContent + wrapBuilder 全局对话框模式
**Rationale**: 与 DayTaskProgressDialog/TaskClockCustomDialog/AchievementDialog 完全一致,项目已建立模式,零学习成本;BaseDialogOptions 无 autoCancel,用 sibling layer(背景层+卡片层)实现点外部关闭
**Alternatives considered**: CustomDialog 装饰器(需挂载到组件树,不灵活) / 原生 AlertDialog(不支持自定义内容)

### D2: 日历网格布局方案
**Decision**: 使用 Grid 组件 + columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr') 7列布局
**Rationale**: Grid 是 ArkUI 官方推荐的日历布局组件,columnsTemplate 固定7列,行数随月份动态计算(4-6行),GridItem 内放进度图标+百分比文字;官方日历示例也用此方案
**Alternatives considered**: Flex+Wrap(行列控制不够精确) / 7个 Row 嵌套 Column(冗余)

### D3: 数据查询方案
**Decision**: 月份切换时对每天调用 DayInfoApi.queryByKey(dateStr) 逐天查询(至多31次)
**Rationale**: 现有 API 只有 queryByKey 单天查询;新增批量查询 API 属过度设计;31次轻量主键查询在 RDB 层面毫秒级完成,用户体验无感
**Alternatives considered**: 新增 queryByMonthRange 批量 API(额外代码,收益低) / 一次性查全表内存过滤(数据量增大后不可控)

### D4: 月份导航与数据刷新方案
**Decision**: 弹窗内维护 @State currentYear/currentMonth,左右箭头切换时重新查询整月数据,更新 @State monthData 数组触发 Grid 刷新
**Rationale**: @State 变化自动触发 UI 重新渲染;月份切换不频繁,每次重查询可保证数据一致性
**Alternatives considered**: 预加载前后月数据(增加复杂度,无实际性能需求)

### D5: 未来日期判定方案
**Decision**: 格子渲染时比较 dateStr 与 convertDate2Str(new Date()),大于则为未来日期
**Rationale**: 直接使用现有 convertDate2Str 工具函数;YYYYMMDD 字符串可直接字典序比较大小
**Alternatives considered**: Date 对象比较(需额外转换)

### D6: 月份首日偏移（空格子）处理
**Decision**: 月首日星期几决定前置空格子数量。周一为起始日(getDay()===0视为周日→偏移6, getDay()===1→偏移0,...,getDay()===6→偏移5),空格子渲染为空白不可交互项
**Rationale**: 与现有周历组件的周一起始约定一致(selectedDay = dayOfWeek===0?6:dayOfWeek-1)
**Alternatives considered**: 周日起始(与现有组件不一致)

### D7: 月份文字显示格式
**Decision**: 显示 "YYYY年MM月" 格式(中文) / "MMMM YYYY" 格式(英文),用 Intl.DateTimeFormat 国际化
**Rationale**: 使用系统 i18n 能力,自动适配语言;不新增月份名称资源串
**Alternatives considered**: 手动12个月份资源串(冗余,i18n 已内置)

## Data Model

### MonthlyCheckinDialogParams

弹窗参数,传递给 @Builder 函数:

| Field | Type | Description |
|-------|------|-------------|
| currentDate | string | 打开弹窗时的当前日期(YYYYMMDD),用于定位初始显示月份 |

### MonthDayCellData (弹窗内部使用,不单独建类)

月视图中单个格子的渲染数据(用 @State monthData: MonthDayCellData[] 数组存储):

| Field | Type | Description |
|-------|------|-------------|
| dateStr | string | 日期字符串(YYYYMMDD),空字符串表示占位空格子 |
| percentage | number | 完成率百分比(0-100) |
| progressImg | Resource | 进度状态图标(ic_home_undone/half_done/all_done) |
| isFuture | boolean | 是否为未来日期 |
| isCurrentMonth | boolean | 是否为当前月份(空格子为false) |
| dayOfMonth | number | 日序号(1-31) |

### 计算逻辑

- **percentage**: 复用 DayInfo.calculatePercentage() — Math.ceil(finTaskNum/targetTaskNum*100),targetTaskNum===0时为0
- **progressImg**: 复用 DayInfo.getProgressImg() — finTaskNum===0或targetTaskNum===0→ic_home_undone; finTaskNum<targetTaskNum→ic_home_half_done; finTaskNum>=targetTaskNum→ic_home_all_done
- **isFuture**: dateStr > convertDate2Str(new Date())

### 月份切换查询流程

1. 计算 targetMonth 的年份+月份
2. 计算该月1号的星期几→前置空格子数
3. 计算该月天数→总格子数=前置空格子数+天数
4. For i 1..天数: dateStr = YYYYMMDD(i), queryByKey(dateStr)
5. 有结果→用 DayInfo 的 percentage/getProgressImg; 无结果(isNull)→percentage=0, progressImg=ic_home_undone
6. 未来日期→isFuture=true, percentage/progressImg 不显示

## Contracts & Interfaces

### 新增函数: openMonthlyCheckinDialog

签名: `export function openMonthlyCheckinDialog(uIContext: UIContext, params: MonthlyCheckinDialogParams): void`

职责:
1. PromptActionClass.setContext(uIContext)
2. 创建 ComponentContent(wrapBuilder(monthlyCheckinDialogBuilder), params)
3. PromptActionClass.setContentNode(node)
4. PromptActionClass.setOptions({ alignment: DialogAlignment.Center })
5. PromptActionClass.openDialog()

### 新增 @Builder: monthlyCheckinDialogBuilder

签名: `@Builder function monthlyCheckinDialogBuilder(params: MonthlyCheckinDialogParams)`

职责:
- 渲染 Stack(背景层+卡片层)
- 卡片内:标题+月份导航Row+星期头Row+Grid(7列,ForEach格子)
- 格子内:进度图标+百分比文字,未来日期灰色
- 背景层 onClick → closeDialog
- 取消按钮 onClick → closeDialog

### 月份导航交互

- 左箭头 onClick → currentMonth-1(1月则currentYear-1,currentMonth=12) → recomputeMonthData
- 右箭头 onClick → currentMonth+1(12月则currentYear+1,currentMonth=1) → recomputeMonthData

### WeekCalendarComponent 改造

在日期导航 Row 的 chevron_right 之后,新增 SymbolGlyph($r('sys.symbol.calendar')) 图标按钮,onClick 调用 openMonthlyCheckinDialog。

### 新增资源串

| Name | base/en_US | zh_CN |
|------|-----------|-------|
| monthly_checkin | "Monthly Check-in" | "月度打卡" |
| monthly_checkin_cancel | "Cancel" | "取消"(可复用现有 cancel) |
| monthly_checkin_no_data | "No data" | "暂无数据" |

注:"取消"已有 `cancel` 资源串,可复用;实际仅需新增 `monthly_checkin` 标题串。
