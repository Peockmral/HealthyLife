# Implementation Plan: 个人资料编辑功能

**Input**: Feature specification from `spec/profile-edit/spec.md`

## Summary

在 Mine 页面实现完整的个人资料编辑功能。用户点击"个人资料"行进入资料列表页（PersonalDataComponent），展示6个字段（头像、昵称、性别、出生日期、身高、体重），每个字段点击后跳转独立编辑页面。使用 Preferences 持久化用户资料数据，ProfileStore（@Observed）通过 @Provide/@Consume 在组件树传递，编辑后返回新实例触发 UI 刷新（与 HomeStore/AchievementStore 一致模式）。头像选择使用 PhotoViewPicker，选中后将图片复制到应用沙箱持久化目录。

## Technical Context

**Language/Version**: ArkTS (HarmonyOS SDK API 12+)
**Primary Dependencies**: ArkUI 框架, @kit.ArkData (Preferences), @kit.MediaLibraryKit (PhotoViewPicker), @kit.CoreFileKit (fs 文件操作)
**Storage**: Preferences 键值对（profileStore 实例），应用沙箱 filesDir（头像图片持久化）
**Testing**: DevEco Studio 模拟器手动验证
**Target Platform**: HarmonyOS
**Project Type**: 移动应用 (HealthyLife)
**Constraints**: @Consume 只观测引用变化；PhotoViewPicker 返回临时 URI 需复制到沙箱；Preferences 只存 string 类型
**Scale/Scope**: 7个新页面 + 2个修改页面 + 1个新数据模型 + 1个新 ViewModel

## Project Structure

### Documentation (this feature)

```text
spec/profile-edit/
├── spec.md
├── plan.md
└── tasks.md
```

### Source Code (repository root)

```text
features/healthylife/src/main/ets/
├── model/
│   └── UserProfile.ets                           # [NEW] 用户资料数据模型
├── viewmodel/
│   └── ProfileStore.ets                          # [NEW] @Observed ProfileStore + init/update 函数
├── views/
│   ├── MineComponent.ets                         # [MODIFY] "个人资料"行加 onClick + @Consume profileStore
│   ├── mine/
│   │   ├── UserInfoComponent.ets                 # [MODIFY] 动态显示头像+昵称，@Consume profileStore
│   │   └── PersonalDataComponent.ets             # [NEW] 个人资料列表页（6个字段行）
│   └── profile/
│       ├── AvatarEditComponent.ets               # [NEW] 头像编辑页（PhotoViewPicker）
│       ├── NicknameEditComponent.ets             # [NEW] 昵称编辑页（TextInput + 保存）
│       ├── GenderSelectComponent.ets             # [NEW] 性别选择页（男/女单选）
│       ├── BirthdayEditComponent.ets             # [NEW] 出生日期编辑页（DatePicker）
│       ├── HeightEditComponent.ets               # [NEW] 身高编辑页（TextPicker 100-250cm）
│       └── WeightEditComponent.ets               # [NEW] 体重编辑页（TextPicker 20-300kg）
├── pages/
│   └── HealthyLifePage.ets                       # [MODIFY] @Provide profileStore

commons/common/src/main/ets/
├── constants/CommonConstants.ets                 # [MODIFY] 新增 Preferences 键名常量
├── utils/PreferencesUtils.ets                    # [MODIFY] 扩展为支持多个 Preferences store（或复用现有 store）

commons/common/src/main/resources/
├── base/element/string.json                      # [MODIFY] 新增资料相关英文字符串
├── zh_CN/element/string.json                     # [MODIFY] 新增资料相关中文字符串
├── en_US/element/string.json                     # [MODIFY] 新增资料相关英文字符串

features/healthylife/src/main/resources/base/profile/
└── router_map.json                               # [MODIFY] 注册7个新路由
```

**Structure Decision**: 遵循现有项目架构。现有项目使用 views/ 目录组织页面组件，viewmodel/ 组织状态管理，model/ 组织数据模型。profile/ 子目录新增于 views/ 下，与 mine/、home/、task/、dialog/ 平级，存放资料编辑相关的7个页面组件。

## Complexity Tracking

无违规需说明。

## Research & Decisions

### D1: 数据持久化方案

**Decision**: 使用现有 PreferencesUtils（同一个 `achievementStore` Preferences 实例）存储用户资料，每个字段一个 key。

**Rationale**: 用户资料是单用户、低频写入场景，Preferences 键值对比 RDB 表更轻量。现有 PreferencesUtils 已提供通用的 put/get 方法，只需新增 key 常量即可。复用同一个 store 避免创建多个 Preferences 实例。

**Alternatives considered**:
- 新建 RDB 表：对单用户场景过度设计，且需新增 TableApi 类、RdbConstants 配置，改动面大。
- 新建独立 Preferences store：可行但不必要，现有 store 可直接扩展。

### D2: ProfileStore 状态管理

**Decision**: 新建 `@Observed ProfileStore` 类，通过 `@Provide/@Consume` 在组件树传递。编辑后调用 `updateProfileStore()` 返回新实例，调用方赋值触发 @Consume 刷新（与 AchievementStore 修复模式一致）。

**Rationale**: 与现有 HomeStore、AchievementStore 完全一致的模式。@Consume 只观测引用变化，必须返回新实例。

**Alternatives considered**:
- 使用 @ObjectLink 观测属性变化：需重构组件层级，改动过大。
- 使用 AppStorage：全局污染命名空间，不符合现有模式。

### D3: 头像图片持久化

**Decision**: PhotoViewPicker 选择图片后，使用 `fs.copyFileSync` 将图片从临时 URI 复制到 `context.filesDir + '/avatar/'` 目录，存储沙箱路径到 Preferences。

**Rationale**: PhotoViewPicker 返回的 URI 是临时授权的媒体库路径，应用重启后可能失效。必须将图片复制到应用沙箱持久化目录（filesDir）才能保证重启后可用。

**Alternatives considered**:
- 只存 URI 不复制：URI 在应用重启后可能失效。
- 使用 photoAccessHelper.getAssets 持久访问：需申请 READ_IMAGEVIDEO 权限，过于重量级。

### D4: 编辑页面导航模式

**Decision**: 每个编辑字段使用独立的 NavDestination 页面，通过 router_map.json 注册，pushPathByName 跳转。编辑完成后 pop 返回，通过 NavDestination 的 onPop 回调或 onShown 事件刷新资料列表页。

**Rationale**: 与现有 AchievementComponent 导航模式一致。用户明确要求"每个字段跳转编辑"。

**Alternatives considered**:
- 使用弹窗编辑：不符合用户"跳转编辑"需求。
- 单页面列表内就地编辑：不符合用户需求。

### D5: 性别选择页交互

**Decision**: 性别选择页展示"男"和"女"两个选项行，带单选指示器（类似设置页风格），选中后自动保存并 pop 返回。

**Rationale**: 用户要求两选项男/女，选中自动保存返回，无需额外保存按钮。这是移动端设置类应用的常见交互模式。

### D6: 身高体重滑轮选择器

**Decision**: 身高使用 TextPicker，range 为 ['100', '101', ..., '250']，步进1cm，选中后点击保存按钮确认。体重使用 TextPicker，range 为 ['20.0', '20.1', ..., '300.0']，步进0.1kg，同样需保存按钮。

**Rationale**: 用户要求滑轮选择器。TextPicker 支持 string[] range，创建连续数值字符串数组即可。体重需0.1精度，生成281个元素的数组（20.0到300.0）。

**Alternatives considered**:
- 使用 DatePicker 模式的自定义 PickerColumn：DatePicker 只支持日期，不适合数字范围。
- 直接输入数字：不符合用户"滑轮选择器"需求。

### D7: 出生日期选择器

**Decision**: 使用 `UIContext.showDatePickerDialog` 弹出日期选择对话框，选择后在编辑页显示，点击保存确认。

**Rationale**: HarmonyOS 提供原生 DatePickerDialog，支持年月日选择，是最标准的日期选择方式。使用 UIContext 版本（非废弃的静态方法）。

### D8: Preferences 键名设计

**Decision**: 新增6个键名常量：`USER_AVATAR_URI`、`USER_NICKNAME`、`USER_GENDER`、`USER_BIRTHDAY`、`USER_HEIGHT`、`USER_WEIGHT`。

**Rationale**: 每个字段独立 key，读写简单。gender 存 '0'(未设置)/'1'(男)/'2'(女) 字符串。height 存 '175' 数字字符串。weight 存 '65.5' 数字字符串。birthday 存 '2000-01-01' 日期字符串。

## Data Model

### UserProfile (新增)

```
UserProfile (普通 class，非 @Observed)
├── avatarUri: string      # 头像沙箱路径，空字符串表示未设置
├── nickname: string       # 昵称，空字符串表示未设置
├── gender: number         # 0=未设置, 1=男, 2=女
├── birthday: string       # YYYY-MM-DD 格式，空字符串表示未设置
├── height: number         # 身高 cm，0 表示未设置
└── weight: number         # 体重 kg，0 表示未设置
```

### ProfileStore (新增)

```
@Observed ProfileStore
├── userProfile: UserProfile  # 当前用户资料快照
```

### Preferences 键值映射

| Key 常量 | 值类型 | 默认值 | 说明 |
|---|---|---|---|
| USER_AVATAR_URI | string | '' | 头像沙箱路径 |
| USER_NICKNAME | string | '' | 昵称 |
| USER_GENDER | string | '0' | 性别 0/1/2 |
| USER_BIRTHDAY | string | '' | YYYY-MM-DD |
| USER_HEIGHT | string | '0' | 身高 cm |
| USER_WEIGHT | string | '0' | 体重 kg |

## Contracts & Interfaces

### initProfileStore()

```
函数: initProfileStore() => Promise<ProfileStore>
```
- 从 Preferences 读取6个字段，构造 ProfileStore 实例返回
- 在 HealthyLifePage.aboutToAppear 中调用

### updateProfileField()

```
函数: updateProfileField(key: string, value: string) => Promise<ProfileStore>
```
- 更新单个字段到 Preferences
- 返回新的 ProfileStore 实例（重新读取所有字段构造）
- 调用方赋值 `this.profileStore = newStore` 触发 @Consume

### 页面导航合约

| 页面名称 | 路由名 | 参数 | 返回 |
|---|---|---|---|
| PersonalDataComponent | PersonalDataComponent | 无 | 无 |
| AvatarEditComponent | AvatarEditComponent | 无 | 无 |
| NicknameEditComponent | NicknameEditComponent | 无 | 无 |
| GenderSelectComponent | GenderSelectComponent | 无 | 无 |
| BirthdayEditComponent | BirthdayEditComponent | 无 | 无 |
| HeightEditComponent | HeightEditComponent | 无 | 无 |
| WeightEditComponent | WeightEditComponent | 无 | 无 |

所有编辑页通过 `@Consume profileStore` 和 `@Consume('pathStack')` 获取状态和导航能力。编辑完成后调用 `updateProfileField()` 赋值新实例 + `pageStack.pop()` 返回。

### UserInfoComponent 修改合约

- 从硬编码 `$r('app.string.user_name')` 和 `$r('app.media.person_crop_circle')` 改为读取 `profileStore.userProfile.nickname` 和 `profileStore.userProfile.avatarUri`
- 有头像时显示圆形裁剪图片，无头像时显示默认占位图标
- 有昵称时显示昵称文本，无昵称时显示"未设置"

### MineComponent 修改合约

- "个人资料"行添加 `.onClick(() => { this.pageStack.pushPathByName('PersonalDataComponent', ''); })`
