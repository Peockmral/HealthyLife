# Implementation Plan: 成就奖章亮起功能

**Input**: Feature specification from `spec/achievement-badge-activate/spec.md`

## Summary

修复成就奖章在达成条件后不亮起的 bug。核心问题：① `@Consume` 不响应 `@Observed` 属性变化，导致 `updateAchievementStore()` 修改 `maxConsecutiveDays` 后 UI 不刷新；② `getAchievementDoneIndex()` 使用精确匹配，跨越多个成就级别时只触发最高级别的弹窗。修复方案参照 HomeStore 的已有模式：`updateAchievementStore()` 返回新 `AchievementStore` 实例，调用方赋值触发 `@Consume` 引用变化；新增 `getNewlyUnlockedAchievementIndices()` 替代 `getAchievementDoneIndex()`，返回所有新跨越的成就索引数组。

## Technical Context

**Language/Version**: ArkTS (HarmonyOS SDK)  
**Primary Dependencies**: ArkUI 框架, @kit.ArkData (Preferences)  
**Storage**: HarmonyOS Preferences (键值对持久化成就数据)  
**Testing**: DevEco Studio 模拟器手动验证  
**Target Platform**: HarmonyOS (API 12+)  
**Project Type**: 移动应用 (HealthyLife 健康打卡)  
**Performance Goals**: 成就判定实时响应，无延迟  
**Constraints**: `@Consume` 只观测引用变化，不观测 `@Observed` 属性变化  
**Scale/Scope**: 6 个预定义成就级别(3/7/30/50/73/99天)

## Project Structure

### Documentation (this feature)

```text
spec/achievement-badge-activate/
├── spec.md              # Feature specification
├── plan.md              # This file
└── tasks.md             # Task breakdown (Phase 3)
```

### Source Code (repository root)

```text
features/healthylife/src/main/ets/
├── model/
│   └── AchievementModel.ets           # [MODIFY] 新增 getNewlyUnlockedAchievementIndices()
├── viewmodel/
│   ├── AchievementStore.ets           # [MODIFY] updateAchievementStore 返回新实例 + 依次弹窗
│   └── dialog/
│       └── TaskInfoDialogParams.ets   # [MODIFY] 新增 refreshAchievementStore 回调
├── views/
│   ├── AchievementComponent.ets       # [REVIEW] 无需修改（@Consume 引用变化自动刷新）
│   ├── home/
│   │   └── TaskListComponent.ets      # [MODIFY] refreshAchievementStore 回调实现
│   └── dialog/
│       └── TaskClockCustomDialog.ets  # [MODIFY] 调用 refreshAchievementStore
└── pages/
    └── HealthyLifePage.ets            # [REVIEW] @Provide achievementStore（无需修改）

commons/common/src/main/ets/
├── constants/CommonConstants.ets      # [REVIEW] 无需修改
└── utils/PreferencesUtils.ets        # [REVIEW] 无需修改
```

**Structure Decision**: 完全遵循现有项目结构，仅修改必要的文件。

## Complexity Tracking

无 Constitution Check 违规需要说明。

## Research & Decisions

### D1: @Consume 刷新机制

**Decision**: `updateAchievementStore()` 返回新的 `AchievementStore` 实例，调用方赋值 `this.achievementStore = newStore` 触发 `@Consume` 引用变化。

**Rationale**: `@Consume` 用严格相等 `===` 判断变化，只观测引用变化，不观测 `@Observed` 属性变化。这与之前修复 HomeStore 的模式完全一致——`updateTaskList()` 返回新 `HomeStore` 实例。

**Alternatives considered**:
- 使用 `@ObjectLink` 在子组件中观测：需要大幅重构 `AchievementComponent` 为子组件模式，改动过大。
- 直接在 `@Consume` 组件中手动调用 `this.achievementStore = this.achievementStore`（自赋值触发刷新）：不规范，框架可能优化掉自赋值。

### D2: 跨越成就时的弹窗触发逻辑

**Decision**: 新增 `getNewlyUnlockedAchievementIndices(oldMax, newMax)` 函数，返回所有 `level > oldMax && level <= newMax` 的成就索引数组。`updateAchievementStore()` 依次对每个索引调用 `openAchievementCustomDialog()`。

**Rationale**: 现有 `getAchievementDoneIndex()` 使用精确匹配 `level === maxConsecutiveDays`，跨越级别时只能触发一个弹窗。改为返回区间内所有新跨越的索引，满足用户"所有被跨越的成就都应解锁"的需求。

**Alternatives considered**:
- 保持 `getAchievementDoneIndex` 不变，只修复 UI 刷新：不满足用户"跨越成就时所有被跨越的奖章同时解锁"的需求。
- 同时弹出所有弹窗：多个弹窗叠加用户体验差，改为依次弹出（关闭一个后弹下一个）。

### D3: 依次弹出多个成就弹窗的实现方式

**Decision**: 在 `updateAchievementStore()` 中收集所有新解锁的成就索引，然后使用 `setTimeout` 间隔弹出或通过用户手动关闭当前弹窗后检查下一个。

**Rationale**: `PromptActionClass` 是全局单例，同时只能显示一个弹窗。需要串行处理：当前弹窗关闭后再弹下一个。考虑到实现简洁性，直接循环调用 `openAchievementCustomDialog()`，后一个会替换前一个（因为 `PromptActionClass.setContentNode` + `openDialog` 会替换当前弹窗内容）。改为在弹窗关闭后自动弹出下一个更合理。

**Alternatives considered**:
- 使用 Promise 链串行弹窗：弹窗关闭时机不易捕获。
- 只弹最高级别的弹窗：不满足用户需求。

### D4: refreshAchievementStore 回调设计

**Decision**: 在 `TaskInfoDialogParams` 中新增 `refreshAchievementStore: () => Promise<void>` 回调，由 `TaskListComponent` 实现赋值 `this.achievementStore = newStore`。

**Rationale**: 与现有的 `refreshHomeStore` 模式完全一致。`TaskClockCustomDialog.taskClock()` 在打卡后先调用 `refreshHomeStore`，再调用 `updateAchievementStore`（其中会返回新实例），然后调用 `refreshAchievementStore` 赋值。

**Alternatives considered**:
- 在 `TaskClockCustomDialog` 中直接获取 `@Consume achievementStore`：dialog 是全局 @Builder 函数，无法使用 `@Consume`。
- 在 `HealthyLifePage` 层面监听变化：过于复杂。

## Data Model

### AchievementStore (修改)

```
AchievementStore (@Observed)
├── maxConsecutiveDays: number      # 历史最高连续天数（不变）
├── currentConsecutiveDays: number  # 当前连续天数（不变）
└── currentDayStatus: boolean       # 当天是否已计入（不变）
```

无新增字段。修改点：`updateAchievementStore()` 改为返回新的 `AchievementStore` 实例。

### AchievementModel (修改)

新增函数 `getNewlyUnlockedAchievementIndices(oldMax: number, newMax: number): number[]`
- 返回所有 `AchievementList[i].level > oldMax && AchievementList[i].level <= newMax` 的索引
- 按级别从低到高排序

### TaskInfoDialogParams (修改)

新增字段：`refreshAchievementStore: () => Promise<void>`

## Contracts & Interfaces

### updateAchievementStore 修改后签名

```
函数: updateAchievementStore(params: TaskInfoDialogParams) => Promise<AchievementStore>
```

- 返回新的 `AchievementStore` 实例（属性从 Preferences 重新读取或基于当前值构造）
- 依次为每个新跨越的成就弹出动画弹窗
- 调用方需赋值: `this.achievementStore = await updateAchievementStore(params)`

### getNewlyUnlockedAchievementIndices 新增函数

```
函数: getNewlyUnlockedAchievementIndices(oldMax: number, newMax: number): number[]
```

- 输入: 旧的 maxConsecutiveDays 和新的 maxConsecutiveDays
- 输出: 所有新跨越的成就索引数组（从低到高排序）
- 示例: `getNewlyUnlockedAchievementIndices(2, 7)` → `[0, 1]` (3天和7天两个成就)

### TaskInfoDialogParams 修改后

```
TaskInfoDialogParams
├── dayTaskInfo: DayTaskInfo
├── homeStore: HomeStore
├── achievementStore: AchievementStore
├── uIContext: UIContext
├── refreshHomeStore: () => Promise<void>
└── refreshAchievementStore: () => Promise<void>   # 新增
```

### TaskListComponent 调用点修改

打卡回调构造 `TaskInfoDialogParams` 时新增 `refreshAchievementStore`:
```
new TaskInfoDialogParams(item, this.homeStore, this.achievementStore, this.getUIContext(),
  async () => { this.homeStore = await updateTaskList(this.homeStore); },
  async () => { this.achievementStore = await updateAchievementStore(params); }  // 新增
)
```

注意: `refreshAchievementStore` 需要引用 `params` 自身，存在循环引用问题。解决方案：先构造 params 再赋值回调，或在回调中使用外部闭包捕获 `achievementStore` 和 `uIContext`。实际实现时在 `TaskClockCustomDialog.taskClock()` 中直接处理，无需通过回调——因为 `taskClock` 已有 `params.achievementStore` 引用，可直接修改后返回新实例。

### 替代回调方案（更简洁）

不使用 `refreshAchievementStore` 回调，而是让 `updateAchievementStore` 返回新实例后，在 `taskClock()` 中直接调用 `params` 的方法。但 `taskClock` 是全局函数，无法访问 `@Consume`。

最终方案：在 `TaskClockCustomDialog.taskClock()` 中，`updateAchievementStore` 返回新 `AchievementStore` 实例后，通过 `TaskInfoDialogParams` 上的回调赋值。回调在 `TaskListComponent` 中实现，与 `refreshHomeStore` 模式一致。
