# Feature Specification: 添加跑步任务种类

**Created**: 2026-07-10  
**Status**: Draft  
**Input**: 用户描述: "添加一个任务种类，名叫跑步。任务编辑页面形式与其他任务相似，且可以选择1-5公里，每次打卡代表完成1公里。"

**确认决策**: ①用户会提供跑步图标素材（ic_task_run.png 任务列表图标 + ic_dialog_run.png 打卡弹窗背景图）；②跑步为次数型任务（step=1），每次打卡完成1公里，目标可选1-5公里；③taskId=6，追加到现有0-5之后。

## Overview

在 HealthyLife 应用中新增第7种健康任务——跑步。跑步为次数型任务，每次打卡代表完成1公里，用户可在编辑页面选择1-5公里的目标。任务编辑、打卡、进度展示、成就等全部流程与其他次数型任务（吃苹果、刷牙等）一致，复用现有 TaskBaseInfo / TaskInfo / DayTaskInfo 数据模型与 UI 组件。

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 在任务列表中看到并开启跑步任务 (Priority: P1)

用户打开首页任务列表，能看到"跑步"任务条目（图标+名称）；点击可打开打卡弹窗；在任务编辑页面可设置1-5公里目标并开启任务。

**Why this priority**: 任务的基本可见性与可操作性是 MVP——看不到/开不了就无法使用。

**Independent Test**: 打开首页确认跑步任务出现；进入编辑页面设置目标并开启；回到首页确认跑步变为开启状态。

**Acceptance Scenarios**:

1. **Given** 应用首次安装或已有数据，**When** 用户查看首页任务列表，**Then** 可看到"跑步"任务条目，显示跑步图标和"跑步"名称。
2. **Given** 跑步任务处于关闭状态，**When** 用户点击跑步任务进入编辑页面，**Then** 编辑页面显示跑步图标、名称、目标选择器（1-5公里）、重复开关等，形式与吃苹果/刷牙等任务一致。
3. **Given** 用户在编辑页面选择了目标（如3公里）并开启任务，**When** 保存并返回首页，**Then** 跑步任务变为开启状态，显示"0/3公里"或默认进度。
4. **Given** 用户翻页到今天日历并点击，**When** 进度对话框打开，**Then** 跑步条目出现并正确显示进度。

---

### User Story 2 - 打卡跑步并正确累加进度 (Priority: P2)

用户对跑步任务打卡，每次打卡完成1公里；进度条与数值文字正确累加；达到目标后标记完成。

**Why this priority**: 打卡是核心行为，进度累加正确性依赖 step=1 与 clockTask 逻辑。

**Independent Test**: 开启跑步目标3公里，打卡1次→进度33%/1/3公里；再打卡→67%/2/3公里；第3次打卡→100%/已完成。

**Acceptance Scenarios**:

1. **Given** 跑步任务已开启且目标3公里、当前未打卡，**When** 用户打卡1次，**Then** 进度变为约33%，数值显示"1/3公里"。
2. **Given** 跑步进度1/3公里，**When** 再次打卡，**Then** 进度变为约67%，数值显示"2/3公里"。
3. **Given** 跑步进度2/3公里，**When** 第3次打卡，**Then** 进度100%，显示"已完成"。
4. **Given** 跑步已完成，**When** 再次点击，**Then** 提示已完成，不重复打卡（与现有逻辑一致）。

---

### User Story 3 - 跑步任务在各页面一致展示 (Priority: P3)

跑步任务在任务列表、编辑页面、打卡弹窗、进度对话框、成就卡片等所有已有页面均正确展示图标、名称、单位、进度。

**Why this priority**: 跨页面一致性确保用户体验完整无死角，依赖 taskBaseInfoList 通用渲染。

**Independent Test**: 逐页面核对跑步任务的图标、名称、单位是否一致。

**Acceptance Scenarios**:

1. **Given** 跑步任务已开启，**When** 查看首页任务列表，**Then** 跑步条目显示跑步图标、"跑步"名称、进度数值"X/Y公里"。
2. **Given** 跑步任务未完成，**When** 点击打开打卡弹窗，**Then** 弹窗标题显示"跑步"，背景图使用 ic_dialog_run.png。
3. **Given** 跑步任务已有打卡记录，**When** 查看成就卡片（AgencyCard），**Then** 跑步条目正确显示图标、名称与进度。

---

### Edge Cases

- **跑步目标设为1公里**:打卡1次即完成(100%),与刷牙等单次任务行为一致。
- **跑步目标设为5公里**:需打卡5次完成,进度依次20%/40%/60%/80%/100%。
- **旧数据库无taskId=6记录**:应用升级后,initDayInfo 的 seed 流程(对 isOpen 任务)会自动为当天创建 dayTaskInfo,无需迁移。
- **TASK_NUM 硬编码**:现有 `CommonConstants.TASK_NUM = 6` 需改为 7,否则 AddTaskComponent 等只显示6个任务。
- **图标素材缺失**:用户承诺提供;若实现期暂缺,应确保代码可编译但图标显示为空/占位。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 系统 MUST 新增 taskId=6 的跑步任务,step=1(每次打卡1公里),unit="公里",PickerType=TEXT,targetValue 可选'1'-'5'。
- **FR-002**: 系统 MUST 在 taskBaseInfoList 中新增 index=6 的 TaskBaseInfo 条目(name=跑步,icon=ic_task_run,dialog=ic_dialog_run,unit=公里,step=1,pickerType=TEXT,pickerRange=['1','2','3','4','5'])。
- **FR-003**: 系统 MUST 在 defaultTaskInfoList 中新增 taskId=6 的 TaskInfo 条目(isOpen=false,targetValue='1',其他默认值)。
- **FR-004**: 系统 MUST 更新 TASK_NUM 常量从6改为7。
- **FR-005**: 系统 MUST 新增 PICKER_RANGE_RUN=['1','2','3','4','5'] 常量供跑步任务目标选择。
- **FR-006**: 系统 MUST 提供跑步任务的图标素材 ic_task_run.png 和 ic_dialog_run.png(由用户提供,放入 commons/common/src/main/resources/base/media/)。
- **FR-007**: 系统 MUST 新增"公里"单位资源串(app.string.unit_km),供跑步任务及进度展示使用。
- **FR-008**: 跑步任务的打卡行为 MUST 与其他次数型任务一致:每次打卡 finValue += step(1),isDone = finValue >= targetValue。
- **FR-009**: 跑步任务在所有已有页面(任务列表/编辑/打卡弹窗/进度对话框/成就卡片)MUST 通过 taskBaseInfoList[taskId] 通用渲染,无需各页面单独适配。
- **FR-010**: 跑步任务的 isRepeat 开关 MUST 可用(与其他次数型任务一致)。

### Key Entities *(include if feature involves data)*

- **TaskBaseInfo(taskBaseInfoList[6])**: 新增条目——id=6, name='跑步', icon=ic_task_run, dialog=ic_dialog_run, unit='公里', step=1, pickerType=TEXT, pickerRange=PICKER_RANGE_RUN。
- **TaskInfo(defaultTaskInfoList)**: 新增默认条目——taskId=6, isOpen=false, targetValue='1', finValue='', isDone=false, isRepeat=false。
- **PICKER_RANGE_RUN**: 新增常量 ['1','2','3','4','5']。
- **TASK_NUM**: 从6更新为7。

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 用户在首页任务列表能看到"跑步"任务条目(图标+名称),可见率100%。
- **SC-002**: 用户可在编辑页面设置1-5公里目标并开启跑步,目标选择器显示1-5整数,默认1公里。
- **SC-003**: 打卡1次完成1公里,进度正确累加(1/3→33%,2/3→67%,3/3→100%),准确率100%。
- **SC-004**: 跑步任务在所有已有页面(列表/编辑/弹窗/进度框/成就卡)展示一致,图标/名称/单位匹配,无遗漏页面。
- **SC-005**: 现有6种任务的功能不受影响,回归0缺陷。

## Assumptions

- taskId=6 追加到现有0-5之后,不影响现有 taskId 逻辑(TaskInfoApi.clockTask 等用 taskId 查 taskBaseInfoList[taskId],数组长度需≥7)。
- 跑步为纯次数型任务(step=1),与吃苹果/刷牙行为完全一致,打卡弹窗使用 ic_dialog_run.png 背景图。
- 用户会提供 ic_task_run.png 和 ic_dialog_run.png 图标素材;实现期若暂缺,先复制现有图标占位(如 ic_task_apple.png),确保编译通过。
- "公里"单位资源串 key 为 unit_km,放入 commons/common resources。
- TASK_NUM=7 反映任务总数;AddTaskComponent 用此常量遍历显示所有任务。
- 跑步任务的提醒(alert/reminder)功能与现有次数型任务一致(isAlert 开关),不特殊处理。
- 现有 DayTaskProgressDialog(刚实现的进度对话框)通过 taskBaseInfoList[taskId] 通用渲染,无需为跑步单独适配。

## Open Questions

- (无关键未决项;图标资源用户确认提供;taskId/step/pickerRange 均有明确默认。)
