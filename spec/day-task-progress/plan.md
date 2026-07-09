# Implementation Plan: 当天任务进度对话框

**Input**: Feature specification from `spec/day-task-progress/spec.md`

## Summary

为首页周历"今天且当前已选中"的图标点击新增居中进度对话框，以横向进度条展示当天每个已开启任务的完成进度：布尔型任务（早起 taskId=0 / 早睡 taskId=5，`step===0`）显示 0% 或 100% 两态；次数型任务（喝水/吃苹果/微笑/刷牙，`step>0`）按 `finValue/targetValue` 比例显示进度并复用现有 `targetValueBuilder` 的数值文字约定。复用现有 `PromptActionClass` 全局对话框模式 + `HomeStore.taskList` 快照数据 + `taskBaseInfoList.step` 区分任务类型，仅新增对话框组件与参数类，改造 `WeekCalendarComponent` 的点击分支。

## Technical Context

**Language/Version**: ArkTS (HarmonyOS ETS)  
**Primary Dependencies**: @kit.ArkUI（`ComponentContent`、`promptAction`、`Progress` 组件、`UIContext`）；@kit.ArkData（relationalStore，复用）  
**Storage**: relationalStore（复用 DayTaskInfo 表，无新增表）  
**Testing**: HarmonyOS 模拟器运行验证（项目无自动化测试框架）  
**Target Platform**: HarmonyOS（模拟器 127.0.0.1:5555）  
**Project Type**: mobile-app  
**Performance Goals**: 点击后 1 秒内弹框；进度条 60fps 流畅渲染  
**Constraints**: 复用已加载的 `HomeStore.taskList` 快照，对话框内不额外查询 DB；快照模式不阻塞后台打卡  
**Scale/Scope**: 3 个文件（2 新增 1 改造），单一功能切片

## Project Structure

### Documentation (this feature)

```text
spec/day-task-progress/
├── spec.md
├── plan.md              # 本文件
└── tasks.md             # Phase 3 产出
```

### Source Code (repository root)

```text
features/healthylife/src/main/ets/
├── views/dialog/
│   └── DayTaskProgressDialog.ets        # 新增：进度对话框 open 函数 + @Builder
├── viewmodel/dialog/
│   └── DayTaskProgressDialogParams.ets  # 新增：参数类 { date, taskList }
└── views/home/
    └── WeekCalendarComponent.ets        # 改造：dayOfWeekBuilder.onClick 点击今天已选中分支弹框
```

复用（不改）：

```text
commons/common/src/main/ets/
├── utils/PromptActionClass.ets          # 全局对话框控制器
├── model/TaskBaseModel.ets             # taskBaseInfoList（name/icon/unit/step）
└── model/database/DayTaskInfo.ets      # DayTaskInfo 实体
features/healthylife/src/main/ets/viewmodel/HomeStore.ets  # checkCurrentDay()、taskList 快照
```

**Structure Decision**: 对话框组件放 `features/healthylife/views/dialog`（与 `TaskClockCustomDialog` 同目录），参数类放 `viewmodel/dialog`（与 `TaskInfoDialogParams` 同目录），保持现有分层与命名一致。

## Complexity Tracking

无 Constitution Check 违规；本功能为现有模块内增量，不引入新模块、新依赖、新持久化表。

## Research & Decisions

### D1: 弹窗实现采用 PromptActionClass + ComponentContent + wrapBuilder 全局模式
- **Decision**: 复用现有 `PromptActionClass` 全局单例 + `ComponentContent` + `wrapBuilder` @Builder 构建对话框，提供 `openDayTaskProgressDialog(uIContext, params)` 函数。
- **Rationale**: 与现有 `TaskClockCustomDialog` / `AchievementDialog` / `TargetSettingDialog` 三个对话框完全一致；对话框在组件树外渲染，`WeekCalendarComponent` 无需声明 `@CustomDialog` / `CustomDialogController`；同一时刻仅一个对话框，与打卡/成就/目标设置对话框互斥，不冲突。
- **Alternatives considered**: `CustomDialogController`（需在 `@Component` 内声明 controller，与现有全局模式不一致，增加维护成本）。

### D2: 进度数据源用 HomeStore.taskList 快照，不额外查询
- **Decision**: 对话框直接使用传入的 `homeStore.taskList`（`DayTaskInfo[]`），不在对话框内再调 `DayTaskInfoApi.queryDayTaskInfo`。
- **Rationale**: `taskList` 是 `initCurrentDateInfo` 中 `queryDayTaskInfo(currentDate)` 的结果，已含当天所有 `isOpen` 任务的 `finValue`/`isDone`；对话框为快照模式（打开瞬间进度），无需实时；避免重复异步查询，保证 1 秒内弹框。
- **Alternatives considered**: 对话框打开时再 `queryDayTaskInfo`（多余异步查询，延迟弹框，且与已加载的 `taskList` 可能不一致）。

### D3: 任务类型判断用 taskBaseInfoList[taskId].step === 0
- **Decision**: `step===0` 为布尔型（进度 0%/100%），`step>0` 为次数型（按比例）。
- **Rationale**: `step` 语义明确（0=一次性打卡即完成，>0=累加步进），与 `clockTask` 打卡逻辑（line 557-565）完全一致；`step=0.5`（喝水）归次数型（`step>0`）正确。`pickerType===TIME` 等价，但 `step` 与进度算法语义更直接对应。
- **Alternatives considered**: 解析 `targetValue` 含 `':'` 判断（脆弱，依赖字符串格式）；用 `pickerType===PickerType.TIME`（等价但与进度算法语义不贴近）。

### D4: 点外部关闭通过根容器 onClick + 内卡片 stopPropagation 实现
- **Decision**: `ComponentContent` 根容器（width/height 100%，透明背景）`onClick` 调 `PromptActionClass.closeDialog()`；内层卡片容器 `onClick` 调 `event.stopPropagation()` 阻止冒泡，确保点卡片内容不误关。
- **Rationale**: `openCustomDialog` 的 `BaseDialogOptions` 无 `autoCancel`，遮罩点击不自动关闭，需手动处理；根容器占满屏 + `onClick` 关闭最直观满足 US3"点外部空白关闭"；`stopPropagation` 保证点进度条/关闭按钮等卡片内交互不被误关。
- **Alternatives considered**: 仅靠关闭按钮（不满足 US3 点外部要求）；`BaseDialogOptions.onAction`（无对应关闭回调）。

### D5: 次数型进度百分比取整数（Math.round）
- **Decision**: 次数型进度 = `Math.min(100, Math.round(Number(finValue||'0') / Number(targetValue) * 100))`；布尔型 = `isDone ? 100 : 0`。
- **Rationale**: 次数型比例多为 33%/67%/50% 等整数级，整数最简洁；布尔型本就 0/100；解决 spec Open Question。注：`Progress` 组件 `value` 会自动 clamp 到 `[0,total]`，故实际可省 `Math.min`，但保留以语义清晰。
- **Alternatives considered**: 保留一位小数（如 33.3%，过度精细，视觉冗余）。

### D6: 触发点复用现有"点击已选中天 selectedDay===index"空操作分支
- **Decision**: 改造 `WeekCalendarComponent.dayOfWeekBuilder` 的 `onClick`：在 `selectedDay === index` 分支内追加 `if (checkCurrentDay()) openDayTaskProgressDialog(...)`，否则保持 `return`；`selectedDay !== index` 分支保持 `refreshDateInfo` 切换。
- **Rationale**: 现有 `selectedDay===index` 分支为 `return` 空操作，正适合注入今天弹框逻辑；非今天点击走切换（保持），今天未选中点击也走切换（先选中），再次点今天（已选中）才弹框——完全符合确认的交互（仅今天弹框、今天未选中先切换）。
- **Alternatives considered**: 给日历图标加单独 `onClick` 只弹框（破坏现有切换逻辑，需重构翻页交互）。

## Data Model

复用现有实体，无新增持久化表：

- **DayTaskInfo**（进度数据源）：`{ id: number; date: string; taskId: number; targetValue: string; finValue: string; isDone: boolean }` — 当天任务实例，`finValue`/`isDone` 决定进度。
- **TaskBaseInfo**（`taskBaseInfoList`，任务元信息）：`{ id; name: Resource; icon: Resource; unit: ResourceStr; step: number; pickerType; ... }` — `name`/`icon`/`unit` 用于条目展示，`step` 用于区分两类进度算法。
- **DayInfo**（周历图标，复用不改）：`{ date; targetTaskNum; finTaskNum }` — `getProgressImg()` 已基于 `finTaskNum`/`targetTaskNum` 显示日历图标。

新增非持久化参数类：

- **DayTaskProgressDialogParams**：`{ date: string; taskList: DayTaskInfo[] }` — `date` 用于标题/空状态提示，`taskList` 为进度展示快照。

进度计算规则（纯逻辑，无副作用）：
- 布尔型（`step===0`）：进度 = `isDone ? 100 : 0`；文字 = `isDone` ? `app.string.was_done`（已完成） : `finValue || '--'`。
- 次数型（`step>0`）：进度 = `Math.min(100, Math.round(Number(finValue||'0') / Number(targetValue) * 100))`；文字 = `isDone` ? `app.string.was_done` : `${finValue||'--'} / ${targetValue} ${unit}`。
- 边界：`finValue` 空串作 0；`targetValue` 为数字字符串（`Number` 转换）；`finValue` 超 `targetValue` 由 `Progress` 自动 clamp 封顶 100%。

## Contracts & Interfaces

### 打开对话框（新增）
- `openDayTaskProgressDialog(uIContext: UIContext, params: DayTaskProgressDialogParams): void`
  - 内部流程：`PromptActionClass.setContext(uIContext)` → `setContentNode(new ComponentContent(uIContext, wrapBuilder(dayTaskProgressDialogBuilder), params))` → `openDialog()`。
  - 与现有 `openTaskClockCustomDialog` 同模式。

### 对话框内容 Builder（新增）
- `@Builder dayTaskProgressDialogBuilder(params: DayTaskProgressDialogParams)`
  - 根容器：`Column`（width/height 100%，透明背景）`.onClick(() => PromptActionClass.closeDialog())` — 点外部关闭。
  - 卡片容器：`Column`（居中，白底圆角，固定宽度，内边距）`.onClick((e) => e.stopPropagation())` — 阻止冒泡防误关。
  - 卡片内容：
    - 标题行：`Text`（"今日进度" 文案，可复用或新增资源串）+ 日期文案。
    - 列表区：`taskList.length === 0` → 显示空状态文字（"今天还没有开启的任务"）；否则 `ForEach(taskList)` 渲染任务进度条子 Builder。
    - 关闭按钮（辅助）：底部 `Button`（"关闭"）`.onClick(() => PromptActionClass.closeDialog())`。
  - 任务进度条子 Builder：`Row`{ `Image(taskBaseInfoList[taskId].icon)` + `Column`{ `Text(name)` + `Progress({value:进度值, total:100, type:Linear}).color(品牌色)` + 文字行 } }。
  - 文字行复用现有 `targetValueBuilder` 约定：`isDone` 显示 `app.string.was_done`（已完成），否则 `finValue||'--'` / `targetValue` / `unit`。

### WeekCalendarComponent 点击改造（改造契约）
- `dayOfWeekBuilder.onClick`：
  - `selectedDay === index`（点击已选中天）：
    - `this.homeStore.checkCurrentDay()` 为真（今天）→ `openDayTaskProgressDialog(this.getUIContext(), new DayTaskProgressDialogParams(this.homeStore.currentDate, this.homeStore.taskList))`。
    - 否则（非今天已选中）→ 保持 `return`（无操作）。
  - `selectedDay !== index`（点击未选中天）→ 保持 `refreshDateInfo(index - selectedDay)`（切换日期，不改）。

### 复用接口（不改）
- `HomeStore.checkCurrentDay(): boolean` — 判今天。
- `HomeStore.taskList: DayTaskInfo[]` — 当前选中天快照。
- `PromptActionClass.openDialog() / closeDialog()` — 全局对话框控制。
- `taskBaseInfoList[taskId]: { name; icon; unit; step }` — 任务元信息。
- `app.string.was_done` — "已完成"资源串；`Const` 常量（字体、尺寸）。
