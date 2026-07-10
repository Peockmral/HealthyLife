# Feature Specification: 月度打卡视图弹窗

**Created**: 2026-07-10  
**Status**: Draft  
**Input**: User description: "日历组件的时间轴右侧增加一个图标，点击图标调出按月视图呈现的打卡状态的弹窗。点击取消或者弹窗外可以关闭弹窗。"

## Overview

在首页周历组件的日期导航栏右侧（右箭头 chevron_right 之后）新增一个图标按钮，点击后弹出按月视图呈现的打卡状态弹窗。月视图中每天格子显示打卡完成率百分比数字和进度状态图标（复用现有 ic_home_undone/half_done/all_done），未来日期显示为灰色不可交互。支持左右切换查看不同月份。点击弹窗外或取消按钮可关闭弹窗。

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 打开月度打卡视图 (Priority: P1)

用户在首页看到周历组件日期导航栏右侧有一个图标，点击该图标后弹出一个居中对话框，显示当前月份的日历网格，每天格子显示打卡完成率百分比和状态图标。

**Why this priority**: 这是核心交互入口，没有它后续功能无从触发，是 MVP 最小可用切片。

**Independent Test**: 点击导航栏右侧图标→弹窗出现→显示当月日历→每天有完成率数字+状态图标→点击弹窗外关闭。

**Acceptance Scenarios**:

1. **Given** 首页已加载且周历组件可见, **When** 用户点击日期导航栏右侧的图标, **Then** 弹出一个居中的月视图对话框，显示当前月份日历网格
2. **Given** 月视图弹窗已打开, **When** 用户查看某天的格子, **Then** 格子显示该天的打卡完成率百分比整数（如"67%"）和对应的进度状态图标（未打卡→ic_home_undone，部分完成→ic_home_half_done，全部完成→ic_home_all_done）
3. **Given** 月视图弹窗已打开, **When** 用户点击弹窗外部区域或点击取消按钮, **Then** 弹窗关闭，回到首页

---

### User Story 2 - 切换月份查看历史打卡 (Priority: P2)

用户在月视图弹窗中可以切换到上个月或下个月，查看对应月份每天的打卡状态。

**Why this priority**: 扩展了时间维度，让用户能回顾历史打卡记录，是核心功能的重要增强。

**Independent Test**: 打开月视图→点击左箭头→显示上个月日历→点击右箭头→回到当前月。

**Acceptance Scenarios**:

1. **Given** 月视图弹窗已打开显示某月, **When** 用户点击月份导航左箭头, **Then** 日历切换到上个月，显示上个月每天的打卡状态
2. **Given** 月视图弹窗已打开显示某月, **When** 用户点击月份导航右箭头, **Then** 日历切换到下个月，显示下个月每天的打卡状态
3. **Given** 月视图弹窗已打开显示当前月, **When** 用户点击右箭头切换到下个月, **Then** 由于下个月还未发生，所有日期格子显示为灰色不可交互状态

---

### User Story 3 - 未来日期和空数据的显示 (Priority: P3)

月视图中未来日期（尚未到达的天）显示为灰色不可交互状态；历史日期中无打卡记录的显示为未完成状态。

**Why this priority**: 边界条件处理，确保视觉一致性和信息完整性。

**Independent Test**: 切换到下个月→所有格子灰色；查看历史无记录的某天→显示ic_home_undone+0%。

**Acceptance Scenarios**:

1. **Given** 月视图弹窗显示某月, **When** 某天日期在今天之后（未来）, **Then** 该格子显示灰色背景，无进度图标和百分比数字，不可交互
2. **Given** 月视图弹窗显示某月, **When** 某天日期在今天或之前且数据库中无DayInfo记录, **Then** 该格子显示ic_home_undone图标和"0%"文字
3. **Given** 月视图弹窗显示某月, **When** 某天日期在今天或之前且数据库有DayInfo记录但targetTaskNum=0, **Then** 该格子显示ic_home_undone图标和"0%"文字

---

### Edge Cases

- 当月只有28/29/30/31天时，日历网格是否正确渲染？
- 跨年切换月份（如12月→1月）是否正确？
- 数据库中某天有多条DayInfo记录如何处理？（应只有一条，以date为主键）
- 弹窗打开时数据是否为打开瞬间的快照？（不实时刷新）
- 月份切换时是否需要加载动画？

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 系统必须在WeekCalendarComponent日期导航栏（Row）右侧，右箭头之后，新增一个可点击的图标按钮
- **FR-002**: 点击图标按钮必须弹出一个居中对话框，展示当前月份的日历网格视图
- **FR-003**: 月视图每天格子必须显示打卡完成率百分比整数和进度状态图标
- **FR-004**: 进度状态图标必须复用现有三种：ic_home_undone（未打卡/完成率0%）、ic_home_half_done（部分完成/0%<完成率<100%）、ic_home_all_done（全部完成/完成率100%）
- **FR-005**: 完成率百分比必须取整数（Math.ceil(finTaskNum/targetTaskNum*100)），与DayInfo.calculatePercentage()一致
- **FR-006**: 月视图必须支持左右切换月份，有月份导航（左箭头+月份文字+右箭头）
- **FR-007**: 未来日期（日期在今天之后）必须显示灰色不可交互状态，不显示进度图标和百分比
- **FR-008**: 点击弹窗外部区域或取消按钮必须关闭弹窗
- **FR-009**: 弹窗必须为打开瞬间的数据快照，不实时刷新
- **FR-010**: 月视图日历网格必须正确适配28/29/30/31天及不同月份起始星期

### Key Entities

- **MonthDayInfo**: 月视图中单天的展示数据，包含日期字符串(date)、完成率百分比(percentage)、进度状态图标Resource(progressImg)、是否为未来日期(isFuture)。数据来源于DayInfoApi.queryByKey()查询结果

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 用户能在2秒内找到并点击月视图入口图标，弹窗在1秒内完成渲染
- **SC-002**: 月视图每天格子正确显示完成率百分比和对应状态图标，与该天实际打卡数据一致
- **SC-003**: 用户能在3次点击内切换到任意历史月份查看打卡记录
- **SC-004**: 未来日期全部显示灰色，无交互响应
- **SC-005**: 点击弹窗外或取消按钮，弹窗立即关闭

## Assumptions

- 弹窗复用现有 PromptActionClass + ComponentContent + wrapBuilder 全局对话框模式（与 DayTaskProgressDialog 和 TaskClockCustomDialog 一致）
- 月视图数据从 DayInfoApi 逐天查询（每月至多31次查询），不新建批量查询API
- 弹窗为数据快照模式，打开瞬间读取数据，不实时监听变化
- 月份切换时重新查询对应月份的DayInfo数据
- 日历网格固定7列（周一至周日），行数根据月份天数和起始星期动态计算（4-6行）
- 每周起始日为周一（与现有周历组件一致，getDay() === 0 视为周日，selectedDay = 6）
- 月份导航使用 SymbolGlyph（chevron_left/chevron_right），与现有周历导航风格一致

## Open Questions

- [无——所有关键点已通过用户确认明确]
