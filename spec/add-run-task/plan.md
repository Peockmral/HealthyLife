# Implementation Plan: 添加跑步任务种类

**Input**: Feature specification from `spec/add-run-task/spec.md`

## Summary

在 HealthyLife 中新增第7种健康任务——跑步(taskId=6,step=1,每次打卡1公里,目标1-5公里可选)。改动集中在 `commons/common` 模块的配置数据(TaskBaseModel / TaskInfo / CommonConstants / string.json / 图标素材),所有已有 UI 组件(AddTaskComponent / EditTaskComponent / TaskClockCustomDialog / AgencyCard / DayTaskProgressDialog 等)通过 `taskBaseInfoList[taskId]` 通用渲染,无需代码改动。`checkDefaultTask()` 自动为新安装和升级场景补插 taskId=6 记录。

## Technical Context

**Language/Version**: ArkTS (HarmonyOS ETS)  
**Primary Dependencies**: @kit.ArkUI(复用); @kit.ArkData(relationalStore,复用)  
**Storage**: relationalStore(复用 TaskInfo / DayTaskInfo 表,无新表/新列)  
**Testing**: HarmonyOS 模拟器运行验证  
**Target Platform**: HarmonyOS(模拟器 127.0.0.1:5555)  
**Project Type**: mobile-app  
**Performance Goals**: 无性能变更(仅增1条配置)  
**Constraints**: 图标素材由用户提供;纯配置改动,不改业务逻辑代码  
**Scale/Scope**: 3 个 .ets 配置文件 + 3 个 string.json + 2 个图标文件

## Project Structure

### Documentation (this feature)

```text
spec/add-run-task/
├── spec.md
├── plan.md              # 本文件
└── tasks.md             # Phase 3 产出
```

### Source Code (repository root)

修改:

```text
commons/common/src/main/ets/
├── constants/CommonConstants.ets           # TASK_NUM 6→7 + 新增 PICKER_RANGE_RUN
├── model/TaskBaseModel.ets                # taskBaseInfoList 新增 index 6
└── model/database/TaskInfo.ets            # defaultTaskInfoList 新增 index 6

commons/common/src/main/resources/
├── base/element/string.json               # 新增 task_run + unit_km
├── base/media/                            # 新增 ic_task_run.png + ic_dialog_run.png(用户提供)
├── en_US/element/string.json              # 新增 task_run + unit_km
└── zh_CN/element/string.json              # 新增 task_run + unit_km
```

无需改动的 UI 组件(通用渲染,通过 taskBaseInfoList[taskId] 自动适配):

```text
features/healthylife/src/main/ets/views/task/AddTaskComponent.ets     # ForEach 通用
features/healthylife/src/main/ets/views/task/EditTaskComponent.ets    # taskBaseInfoList[param.taskId] 通用
features/healthylife/src/main/ets/views/dialog/TaskClockCustomDialog.ets  # dialog backgroundImage 通用
features/healthylife/src/main/ets/views/dialog/DayTaskProgressDialog.ets  # ForEach 通用
products/default/src/main/ets/agency/pages/AgencyCard.ets             # taskBaseInfoList[taskId] 通用
```

**Structure Decision**: 仅改 commons/common 配置数据+资源;所有 features/products UI 组件零改动,依赖 taskBaseInfoList 通用索引。

## Complexity Tracking

无 Constitution Check 违规;本功能为纯配置增量,不引入新模块/新依赖/新持久化表/新业务逻辑。

## Research & Decisions

### D1: taskId=6 追加到现有0-5之后
- **Decision**: 跑步任务 taskId=6,追加在早睡(taskId=5)之后。
- **Rationale**: taskId 为数组索引(taskBaseInfoList[taskId]),顺序追加不影响现有索引映射;TaskInfoApi.clockTask 等用 taskId 查数组,只需数组长度≥7。
- **Alternatives considered**: 插入中间位置(破坏现有索引,所有后续 taskId 需重映射,不可行)。

### D2: TASK_NUM 从6改为7
- **Decision**: `CommonConstants.TASK_NUM` 从6更新为7。
- **Rationale**: `checkDefaultTask()` 用 `Const.TASK_NUM` 判断任务列表是否完整(若 taskList.length < TASK_NUM 则补插缺失);改为7后,旧数据库(6条)升级时自动检测到缺失 taskId=6 并补插 `defaultTaskInfoList[6]`;新安装直接插入7条。实现升级兼容零迁移。
- **Alternatives considered**: 单独写迁移逻辑(不必要,checkDefaultTask 已内置补插机制)。

### D3: 跑步为次数型任务(step=1)
- **Decision**: `step=1`,每次打卡 finValue += 1;isDone = finValue >= Number(targetValue)。
- **Rationale**: 与吃苹果/刷牙/微笑等次数型任务完全一致;clockTask 已有 step>0 分支自动处理累加;targetValue='1'-'5'对应1-5公里目标。
- **Alternatives considered**: step=0 布尔型(不符合"每次打卡1公里"需求)。

### D4: 图标素材由用户提供
- **Decision**: 用户承诺提供 ic_task_run.png(任务列表图标)和 ic_dialog_run.png(打卡弹窗背景图);实现期若暂缺,先复制现有 ic_task_apple.png 作为占位确保编译。
- **Rationale**: 现有6个任务均有专属图标,跑步也应有一致风格;TaskClockCustomDialog 用 backgroundImage(taskBaseInfoList[taskId].dialog)渲染弹窗背景,必须有 dialog 图标。
- **Alternatives considered**: 用纯色/无图弹窗(与现有风格不一致)。

### D5: 单位"公里"(app.string.unit_km)
- **Decision**: 新增资源串 `unit_km`(中文"公里",英文"km"),供跑步任务及进度展示使用。
- **Rationale**: 国际单位;中文"公里"为日常用语;与现有 unit_liter/unit_number/unit_times 格式一致。
- **Alternatives considered**: 用"km"不分中英文(不够本地化);用"千米"(偏书面)。

### D6: 所有页面通用渲染无需改动
- **Decision**: AddTaskComponent/EditTaskComponent/AgencyCard/DayTaskProgressDialog/TaskClockCustomDialog 等所有 UI 组件通过 `taskBaseInfoList[taskId]` 通用索引渲染,无需为跑步单独适配代码。
- **Rationale**: 这些组件均用 `ForEach(taskList)` + `taskBaseInfoList[item.taskId]` 取 name/icon/unit/step/dialog 等;只要 taskBaseInfoList 有 index 6,所有页面自动正确渲染。TargetSettingDialog 的 Picker 通用读取 `pickerRange`。
- **Alternatives considered**: 为跑步在各页面加特殊分支(违反 DRY,增加维护成本)。

## Data Model

复用现有实体,无新增持久化表/列:

- **TaskBaseInfo(taskBaseInfoList[6])**: 新增条目 — id=6; name=$r('app.string.task_run'); icon=$r('app.media.ic_task_run'); dialog=$r('app.media.ic_dialog_run'); unit=$r('app.string.unit_km'); step=1; limit=''; pickerType=PickerType.TEXT; pickerRange=Const.PICKER_RANGE_RUN。
- **TaskInfo(defaultTaskInfoList[6])**: 新增默认条目 — taskId=6; isOpen=false; targetValue='1'; finValue=''; isDone=false; isAlert=false; alertStartTime=''; alertEndTime=''; alertFrequency=''; reminderId=-1; isRepeat=false。
- **PICKER_RANGE_RUN**: 新增常量 ['1','2','3','4','5']。
- **TASK_NUM**: 从6更新为7。

升级兼容:
- 旧数据库(6条 taskId 0-5):`checkDefaultTask()` 检测 taskList.length(6) ≠ TASK_NUM(7) → 补插 defaultTaskInfoList[6] → taskId=6 记录自动创建。
- 新安装:直接 batchInsert 7 条。

## Contracts & Interfaces

无新增接口;改动均为数据配置:

- `CommonConstants.ets`:
  - `TASK_NUM`: 6 → 7
  - 新增 `PICKER_RANGE_RUN: string[] = ['1','2','3','4','5']`

- `TaskBaseModel.ets`:
  - `taskBaseInfoList` 数组末尾追加 `new TaskBaseInfo(6, $r('app.string.task_run'), $r('app.media.ic_task_run'), $r('app.media.ic_dialog_run'), $r('app.string.unit_km'), 1, '', PickerType.TEXT, Const.PICKER_RANGE_RUN)`

- `TaskInfo.ets`:
  - `defaultTaskInfoList` 数组末尾追加 `new TaskInfo(6, false, '1', '', false, false, '', '', '', -1, false)`

- `string.json`(base / en_US / zh_CN):
  - 新增 `task_run`(中文"跑步",英文"Run")
  - 新增 `unit_km`(中文"公里",英文"km")

- 图标素材:
  - `ic_task_run.png` → `commons/common/src/main/resources/base/media/`
  - `ic_dialog_run.png` → `commons/common/src/main/resources/base/media/`

复用接口(不改):
- `TaskInfoApi.checkDefaultTask()`: 用 TASK_NUM 判断完整性,自动补插
- `TaskInfoApi.clockTask(date, taskId=6)`: step=1 分支自动处理
- `TaskInfoApi.openTask/closeTask/deleteTask`: 通用,taskId=6 自动适配
- `HomeStore.initCurrentDateInfo()`: seed 用 queryOpenedTaskInfo + queryRepeatTaskInfo,自动含 taskId=6
- `DayTaskProgressDialog.getDayTaskProgress()`: step>0 分支自动处理
- `EditTaskComponent.finishTaskEdit()`: 通用,taskBaseInfoList[6] 自动生效
