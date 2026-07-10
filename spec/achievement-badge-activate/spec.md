# Feature Specification: 成就奖章亮起功能

**Created**: 2026-07-10  
**Status**: Draft  
**Input**: User description: "目前成就页面已经有6个成就类型，但是达成某个成就之后，目前奖章并不会亮起。请你实现达成奖章要求之后奖章亮起的功能。"

## Overview

成就页面展示6个连续打卡天数奖章(3/7/30/50/73/99天)，当前代码已有完整的成就判定和持久化逻辑，但存在两个关键问题导致奖章不会亮起：① `@Consume` 不响应 `@Observed` 属性变化，打卡后 UI 不刷新；② 成就弹窗触发使用精确匹配，跨越多个级别时只触发最高一个。本次修复需让奖章在达成条件后实时亮起，并确保跨越成就时所有被跨越的奖章同时解锁。

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 打卡完成后奖章实时亮起 (Priority: P1)

用户在首页打卡完成当天所有任务后，导航到成就页面，能看到对应天数的奖章已经从灰色变为彩色亮起状态。

**Why this priority**: 这是成就系统最核心的功能——达成后视觉反馈，没有它成就系统形同虚设。

**Independent Test**: 开启所有任务→全部打卡→进入成就页→3天奖章应显示为彩色亮起图标。

**Acceptance Scenarios**:

1. **Given** 用户已连续完成所有任务2天（maxConsecutiveDays=2, 所有奖章灰色），**When** 用户在第3天完成所有任务打卡，**Then** 3天奖章变为彩色亮起状态
2. **Given** 用户在成就页面停留时（从其他页面切换回来），**When** 此前已完成了当天所有任务，**Then** 成就页面应正确显示已解锁的奖章为亮起状态
3. **Given** 用户重启应用，**When** 进入成就页面，**Then** 所有已解锁的奖章仍应显示为亮起状态（持久化正确）

---

### User Story 2 - 跨越成就级别时所有被跨越的奖章同时解锁 (Priority: P2)

如果用户的连续打卡天数从较低值直接跳到较高值，跨越了中间的成就级别，则所有被跨越的奖章都应同时亮起。

**Why this priority**: 保证成就系统的完整性，不会因为跳级而遗漏中间成就。

**Independent Test**: 通过手动修改 Preferences 中的 maxConsecutiveDays 值为 7，进入成就页→3天和7天奖章都应亮起。

**Acceptance Scenarios**:

1. **Given** 用户 maxConsecutiveDays 从 2 直接变为 7，**When** 用户进入成就页面，**Then** 3天和7天奖章都应显示为亮起状态
2. **Given** 用户 maxConsecutiveDays 从 0 直接变为 30，**When** 用户进入成就页面，**Then** 3天、7天、30天三个奖章都应亮起

---

### User Story 3 - 成就解锁弹窗对每个新解锁的奖章分别展示 (Priority: P3)

当连续天数跨越多个成就级别时，应依次展示每个新解锁成就的动画弹窗（按级别从低到高），而不是只展示最高级别的弹窗或跳过中间级别。

**Why this priority**: 增强用户体验，让每个成就解锁都有仪式感。

**Independent Test**: 连续天数从 0 跳到 7 时，应先后弹出3天和7天两个成就动画弹窗。

**Acceptance Scenarios**:

1. **Given** 用户 maxConsecutiveDays 从 2 变为 7（跨越了3天和7天两个成就），**When** 打卡完成触发成就检查，**Then** 先弹出3天成就动画弹窗，关闭后再弹出7天成就动画弹窗
2. **Given** 用户 maxConsecutiveDays 从 5 变为 7（只跨越7天一个成就），**When** 打卡完成触发成就检查，**Then** 只弹出7天成就动画弹窗

---

### Edge Cases

- 用户从未完成过任何一天的打卡时，所有奖章保持灰色
- 连续天数断开后重新累计，之前已解锁的奖章仍保持亮起（maxConsecutiveDays 是历史最高值，不会减少）
- 同一天重复打卡不会重复触发成就弹窗（currentDayStatus 防护）
- 应用重启后成就数据从 Preferences 正确恢复

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 打卡完成当天所有任务后，AchievementStore 的 maxConsecutiveDays 更新必须实时反映到成就页面 UI，奖章立即亮起
- **FR-002**: AchievementStore 属性变化必须触发 `@Consume` 消费者的 UI 刷新（与 HomeStore 的修复模式一致：更新后返回新实例，调用方赋值触发引用变化）
- **FR-003**: 成就判定条件使用 `>=`（大于等于）而非精确匹配，确保 maxConsecutiveDays 超过某个成就级别时，该级别及以下所有成就的奖章都亮起
- **FR-004**: 当 maxConsecutiveDays 跨越多个成就级别时，依次为每个新跨越的成就弹出解锁动画弹窗（从低级别到高级别顺序展示）
- **FR-005**: 已解锁的奖章在成就页面点击后可查看成就详情弹窗（现有功能保持不变）
- **FR-006**: 成就数据持久化到 Preferences 的逻辑保持不变，重启应用后数据正确恢复
- **FR-007**: 同一天内重复打卡不重复增加连续天数（currentDayStatus 防护保持不变）

### Key Entities

- **AchievementStore**: 全局成就状态，包含 maxConsecutiveDays（历史最高连续天数）、currentConsecutiveDays（当前连续天数）、currentDayStatus（当天是否已计入连续天数）。标记为 @Observed，通过 @Provide/@Consume 在组件树中传递。
- **AchievementItem**: 成就定义，包含 level（解锁所需天数）、name（显示名）、iconOn（亮起图标）、iconOff（灰色图标）。6个预定义成就：3/7/30/50/73/99天。

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 用户完成当天所有任务打卡后，导航到成就页面，对应的奖章立即显示为亮起状态（100%可复现）
- **SC-002**: 用户在成就页面停留时完成打卡（通过其他交互场景），返回成就页面后奖章已更新
- **SC-003**: 连续天数跨越多个成就级别时，所有被跨越的奖章同时亮起，无遗漏
- **SC-004**: 应用重启后进入成就页，之前已解锁的奖章仍为亮起状态
- **SC-005**: 成就解锁弹窗按级别从低到高依次展示，每个弹窗均可正常关闭

## Assumptions

- 成就系统的6个奖章级别和判定逻辑（连续完成天数）不变
- 奖章的亮起/灰色判断逻辑（`level <= maxConsecutiveDays` 时亮起）已是正确的，只需修复 UI 刷新问题
- AchievementStore 的 @Observed + @Consume 刷新问题与之前修复的 HomeStore 属于同一模式，采用相同的解决方案（更新后返回新实例）
- 成就弹窗动画的现有实现保持不变
- 用户一天只能完成一次所有任务打卡（currentDayStatus 保证）

## Open Questions

- 无（需求已明确）
