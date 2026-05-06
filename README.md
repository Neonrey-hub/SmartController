# SmartController（智慧控制器）

一款基于 **HarmonyOS / OpenHarmony (ArkTS)** 开发的工业物联网智能控制应用，集成了语音交互、环境数据监测、设备远程控制等功能。

---

## 目录

- [项目简介](#项目简介)
- [功能特性](#功能特性)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [环境要求](#环境要求)
- [环境部署](#环境部署)
  - [1. 安装 DevEco Studio](#1-安装-deveco-studio)
  - [2. 配置 HarmonyOS SDK](#2-配置-harmonyos-sdk)
  - [3. 配置签名证书](#3-配置签名证书)
  - [4. 克隆项目](#4-克隆项目)
  - [5. 安装依赖](#5-安装依赖)
- [项目配置](#项目配置)
  - [1. 后端服务器地址](#1-后端服务器地址)
  - [2. 讯飞语音开放平台凭证](#2-讯飞语音开放平台凭证)
  - [3. 签名证书配置](#3-签名证书配置)
- [运行步骤](#运行步骤)
  - [方式一：使用 DevEco Studio 运行](#方式一使用-deveco-studio-运行)
  - [方式二：使用命令行构建](#方式二使用命令行构建)
- [页面说明](#页面说明)
- [网络通信协议](#网络通信协议)
  - [HTTP 接口](#http-接口)
  - [WebSocket 通信](#websocket-通信)
- [权限说明](#权限说明)
- [第三方依赖](#第三方依赖)
- [常见问题](#常见问题)
- [许可证](#许可证)

---

## 项目简介

SmartController 是一款面向工业物联网场景的智能控制终端应用，运行于 HarmonyOS / OpenHarmony 系统。应用通过 WebSocket 与后端 "小智" AI 服务保持长连接，结合讯飞语音实时识别（ASR）技术，实现语音对话式设备控制。同时支持十合一工业传感器数据的实时监测与可视化展示，以及远程执行器控制。

---

## 功能特性

### 语音对话控制
- 集成讯飞语音实时语音识别（ASR），支持中文普通话识别
- 通过 WebSocket 将语音指令发送至后端 AI 服务，实现语音控制设备
- 支持语音输入按钮交互，实时显示识别文本和 AI 回复

### 环境数据监测
- 实时获取十合一工业传感器数据：二氧化碳、TVOC、甲醛、PM2.5、湿度、温度、PM10、PM1.0、光照度、噪声
- 舒适指数计算与展示
- 数据质量监控与报警信息提示
- 趋势图表展示历史数据变化

### 设备远程控制
- 远程控制执行器：蜂鸣器、红/绿/黄灯、亮度、风扇
- 支持三种控制模式切换：场景模式、开关模式、模拟量模式
- 实时状态指示器反馈设备状态

### 实时通信
- WebSocket 长连接，支持心跳检测（20秒间隔）
- WiFi 断线自动重连（1.5秒延迟）
- HTTP 轮询传感器数据（1秒间隔），请求失败时自动降级为模拟数据

---

## 技术栈

| 项目 | 说明 |
|------|------|
| 开发语言 | ArkTS (TypeScript 扩展) |
| UI 框架 | ArkUI（声明式） |
| 状态管理 | `@ObservedV2` + `@Trace` + `@ComponentV2` + `@Local` |
| 导航模式 | Navigation + NavPathStack（Stack 模式） |
| SDK 版本 | compileSdkVersion 12 / compatibleSdkVersion 12 / targetSdkVersion 12 |
| 运行系统 | OpenHarmony |
| 支持设备 | default（手机）、tablet（平板） |
| IDE | DevEco Studio |
| 构建工具 | Hvigor |
| 包管理 | ohpm |

---

## 项目结构

```
SmartController/
├── AppScope/                          # 应用全局配置
│   ├── resources/                     # 全局资源
│   │   ├── element/string.json        # 全局字符串资源
│   │   └── media/                     # 全局图标资源
│   └── app.json5                      # 应用配置（bundleName、版本等）
├── entry/                             # 主模块
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/
│   │   │   │   └── EntryAbility.ets   # 应用入口 Ability
│   │   │   ├── entrybackupability/
│   │   │   │   └── EntryBackupAbility.ets  # 备份恢复能力
│   │   │   ├── common/
│   │   │   │   └── Constants.ets      # 常量定义 + 讯飞配置
│   │   │   ├── pages/
│   │   │   │   ├── Index.ets          # 主框架（底部 Tab 导航）
│   │   │   │   ├── ChatPage.ets       # 对话页（语音聊天 + AI 对话）
│   │   │   │   ├── DataHomePage.ets   # 数据页（传感器 + 舒适指数）
│   │   │   │   ├── DeviceHomePage.ets # 设备页（控制台 + 日志）
│   │   │   │   └── TrendChartCard.ets # 趋势图表组件
│   │   │   ├── network/
│   │   │   │   ├── API_URL.ets        # 服务器 IP 配置
│   │   │   │   ├── network_connect.ets # WebSocket 连接管理
│   │   │   │   ├── get_data.ets       # HTTP 数据获取 + 数据模型
│   │   │   │   ├── isconnect.ets      # 网络状态检测
│   │   │   │   └── API_risc.ets       # API 备用
│   │   │   ├── managers/
│   │   │   │   ├── XfyunAuth.ets      # 讯飞鉴权 URL 生成
│   │   │   │   ├── AsrWebSocketManager.ets # 讯飞 ASR WebSocket 管理
│   │   │   │   ├── AudioCaptureManager.ets  # 音频采集管理
│   │   │   │   └── PermissionManager.ets    # 权限管理
│   │   │   ├── models/
│   │   │   │   ├── ControlState.ets   # 设备控制状态模型
│   │   │   │   └── ChatMessage.ets    # 聊天消息模型
│   │   │   ├── components/
│   │   │   │   ├── chat/              # 聊天相关组件
│   │   │   │   │   ├── VoiceInputButton.ets   # 语音输入按钮
│   │   │   │   │   └── ChatMessageBubble.ets  # 聊天消息气泡
│   │   │   │   ├── sensor/            # 传感器相关组件
│   │   │   │   │   ├── IndustrialSensorCard.ets # 工业传感器卡片
│   │   │   │   │   └── EdgeDataQuality.ets      # 数据质量组件
│   │   │   │   ├── control/           # 控制相关组件
│   │   │   │   │   ├── ControlConsole.ets  # 控制台
│   │   │   │   │   ├── ControlButtons.ets  # 控制按钮
│   │   │   │   │   ├── ControlSlider.ets   # 滑块控制器
│   │   │   │   │   ├── ControlTabs.ets     # 控制模式 Tab
│   │   │   │   │   └── StatusIndicator.ets # 状态指示器
│   │   │   │   ├── actuator/          # 执行器相关组件
│   │   │   │   │   ├── ActuatorOccupancy.ets # 执行器占用率
│   │   │   │   │   ├── RingChart.ets         # 环形图
│   │   │   │   │   └── MetricCard.ets        # 指标卡片
│   │   │   │   ├── device/            # 设备相关组件
│   │   │   │   │   ├── DeviceInfoCard.ets    # 设备信息卡片
│   │   │   │   │   └── DeviceOnlineTag.ets   # 在线标签
│   │   │   │   └── log/               # 日志相关组件
│   │   │   │       ├── AlarmQueue.ets        # 报警队列
│   │   │   │       └── EventLog.ets          # 事件日志
│   │   │   ├── utils/
│   │   │   │   ├── AlarmUtils.ets     # 报警生成工具
│   │   │   │   ├── DateUtils.ets      # 日期工具
│   │   │   │   └── VoiceRecognizer.ets # 语音识别封装
│   │   │   └── constants/
│   │   │       ├── AppColors.ets      # 颜色常量
│   │   │       └── AppDimensions.ets  # 尺寸常量
│   │   ├── resources/                 # 模块资源文件
│   │   │   ├── base/element/          # 颜色、字符串、浮点数资源
│   │   │   ├── base/media/            # 图片资源
│   │   │   ├── base/profile/          # 配置文件
│   │   │   └── dark/element/          # 暗色模式资源
│   │   └── module.json5               # 模块配置（权限、Ability 等）
│   ├── build-profile.json5            # 模块构建配置
│   ├── hvigorfile.ts                  # Hvigor 构建脚本
│   └── oh-package.json5               # 模块依赖声明
├── hvigor/                            # Hvigor 构建工具配置
│   └── hvigor-config.json5
├── oh_modules/                        # ohpm 依赖包
├── build-profile.json5                # 项目构建配置（签名、SDK 版本等）
├── oh-package.json5                   # 项目依赖声明
├── hvigorfile.ts                      # 项目级 Hvigor 脚本
└── code-linter.json5                  # 代码检查配置
```

---

## 环境要求

### 硬件要求

| 项目 | 最低要求 |
|------|----------|
| 内存 | 8 GB 及以上（推荐 16 GB） |
| 磁盘空间 | 10 GB 及以上可用空间 |
| 操作系统 | Windows 10 64 位 / Windows 11 64 位 |

### 软件要求

| 软件 | 版本要求 | 说明 |
|------|----------|------|
| DevEco Studio | 5.0.0 及以上 | HarmonyOS 官方 IDE |
| HarmonyOS SDK | API 12 | 在 DevEco Studio 中通过 SDK Manager 安装 |
| Node.js | 14.19.1 及以上 | 构建工具依赖（DevEco Studio 通常自带） |
| ohpm | 随 DevEco Studio 安装 | HarmonyOS 包管理器 |
| Hvigor | 随 DevEco Studio 安装 | 构建工具 |

### 设备要求

- HarmonyOS / OpenHarmony 设备（真机或模拟器）
- 设备需支持 WiFi 连接
- 设备需配备麦克风（语音功能需要）

---

## 环境部署

### 1. 安装 DevEco Studio

1. 前往 [HarmonyOS 开发者官网](https://developer.huawei.com/consumer/cn/deveco-studio/) 下载 DevEco Studio 安装包
2. 运行安装程序，按照向导完成安装
3. 首次启动时，根据提示完成初始配置（同意协议、安装 SDK 等）

### 2. 配置 HarmonyOS SDK

1. 打开 DevEco Studio，进入 **File > Settings > HarmonyOS SDK**
2. 在 SDK Manager 中确保已安装以下组件：
   - **API 12**（或更高版本）的 SDK Platform
   - **Previewer**（用于预览器调试）
   - **Toolchains**（构建工具链）
3. 如需真机调试，还需安装对应的 **Driver**（USB 驱动）

### 3. 配置签名证书

> **注意**：项目中的签名证书为示例证书，不可用于正式发布。你需要配置自己的签名证书。

1. 在 DevEco Studio 中进入 **File > Project Structure > Signing Configs**
2. 勾选 **Automatically generate signature**，登录华为开发者账号
3. 或者手动配置签名信息：
   - 登录 [AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html) 创建应用
   - 下载签名证书文件（`.cer`、`.p7b`、`.p12`）
   - 在 `build-profile.json5` 中填入证书路径和密码

### 4. 克隆项目

```bash
git clone <你的仓库地址>
cd SmartController
```

### 5. 安装依赖

项目使用 ohpm（HarmonyOS 包管理器）管理依赖。在 DevEco Studio 中打开项目后，IDE 会自动下载依赖。

如需手动安装依赖，在项目根目录执行：

```bash
ohpm install
```

依赖包括：
- `@ohos/crypto-js` (^2.0.0) — 用于讯飞 API HMAC-SHA256 签名
- `@ohos/hypium` (1.0.25) — 单元测试框架（开发依赖）
- `@ohos/hamock` (1.0.0) — 测试 Mock 工具（开发依赖）

---

## 项目配置

在运行项目之前，需要根据你的实际环境修改以下配置。

### 1. 后端服务器地址

修改文件 `entry/src/main/ets/network/API_URL.ets`：

```typescript
// 将 IP 地址改为你自己的后端服务器地址
export let API_URL = "119.29.15.120"
```

该地址用于：
- **HTTP 接口**：`http://{API_URL}:8090/api/status` — 获取传感器数据
- **WebSocket 通信**：`ws://{API_URL}:8000/xiaozhi/v1/` — 与后端 AI 服务通信

> **确保你的后端服务已启动并监听对应端口（8090 和 8000）。**

### 2. 讯飞语音开放平台凭证

修改文件 `entry/src/main/ets/common/Constants.ets`：

```typescript
// 替换为你自己在讯飞开放平台申请的凭证
static readonly XFYUN_APP_ID: string = "你的APPID"
static readonly XFYUN_API_KEY: string = "你的APIKey"
static readonly XFYUN_API_SECRET: string = "你的APISecret"
```

**获取方式**：
1. 前往 [讯飞开放平台](https://www.xfyun.cn/) 注册账号
2. 创建应用，开通 **实时语音转写（WebSocket）** 服务
3. 在控制台获取 `APPID`、`APIKey`、`APISecret`

### 3. 签名证书配置

修改项目根目录 `build-profile.json5` 中的 `signingConfigs`：

```json5
"signingConfigs": [
  {
    "name": "default",
    "material": {
      "certpath": "你的证书路径.cer",
      "keyAlias": "你的密钥别名",
      "keyPassword": "你的密钥密码",
      "profile": "你的profile路径.p7b",
      "signAlg": "SHA256withECDSA",
      "storeFile": "你的p12文件路径.p12",
      "storePassword": "你的store密码"
    }
  }
]
```

---

## 运行步骤

### 方式一：使用 DevEco Studio 运行（推荐）

1. **打开项目**
   - 启动 DevEco Studio
   - 选择 **File > Open**，选择项目根目录
   - 等待 IDE 自动同步和索引项目

2. **连接设备**
   - **真机调试**：通过 USB 连接 HarmonyOS/OpenHarmony 设备，在设备上开启开发者模式和 USB 调试
   - **模拟器**：在 DevEco Studio 中通过 **Tools > Device Manager** 创建并启动远程模拟器或本地模拟器

3. **运行应用**
   - 点击工具栏的 **Run** 按钮（绿色三角形），或按 `Shift + F10`
   - 选择目标设备，等待编译和安装
   - 应用将自动安装到设备并启动

4. **预览调试**
   - 打开任意 `.ets` 页面文件
   - 点击编辑器右侧的 **Previewer** 按钮
   - 可实时预览 UI 效果（部分功能如网络请求、语音在预览器中不可用）

### 方式二：使用命令行构建

```bash
# 1. 进入项目根目录
cd SmartController

# 2. 安装依赖
ohpm install

# 3. 清理构建缓存（可选）
hvigorw clean

# 4. 构建项目（Debug 模式）
hvigorw assembleHap --mode module -p module=entry@default -p product=default

# 5. 构建产物位于
# entry/build/default/outputs/default/entry-default-signed.hap
```

构建完成后，通过 HDC（HarmonyOS Device Connector）安装到设备：

```bash
# 查看已连接设备
hdc list targets

# 安装 HAP 包
hdc install entry/build/default/outputs/default/entry-default-signed.hap

# 启动应用
hdc shell aa start -a EntryAbility -b com.smartcontroller.app
```

---

## 页面说明

应用采用底部 Tab 导航架构，包含三个主要页面：

| Tab | 页面 | 文件 | 功能描述 |
|-----|------|------|----------|
| 对话 | ChatPage | `pages/ChatPage.ets` | 语音聊天界面，支持语音输入和 AI 对话，显示聊天记录 |
| 数据 | DataHomePage | `pages/DataHomePage.ets` | 传感器数据展示，包含十合一传感器卡片、舒适指数、趋势图表、数据质量监控 |
| 设备 | DeviceHomePage | `pages/DeviceHomePage.ets` | 设备控制台，支持执行器控制（蜂鸣器、灯光、风扇等）、控制模式切换、报警队列和事件日志 |

默认首屏为 **对话页（ChatPage）**。

---

## 网络通信协议

### HTTP 接口

| 项目 | 说明 |
|------|------|
| 地址 | `http://{API_URL}:8090/api/status` |
| 方法 | GET |
| 轮询频率 | 每 1 秒请求一次 |
| 返回数据 | `meta`（元信息）、`sensor`（传感器数据，含 `pretty` 数组）、`actuators`（执行器状态） |
| 降级策略 | 请求失败时自动生成随机模拟数据 |

### WebSocket 通信

| 项目 | 说明 |
|------|------|
| 地址 | `ws://{API_URL}:8000/xiaozhi/v1/` |
| 连接参数 | Header: `Protocol-Version: 1`、`device-id`（WiFi MAC）、`client-id`（随机 UUID） |
| 心跳间隔 | 20 秒，发送 `{"type": "hello"}` 帧 |
| 重连策略 | WiFi 恢复后 1.5 秒自动重连 |
| 消息格式 | JSON，通过 `type` 字段区分：`tts`（服务端回复）、`hello`（握手）、`listen`（用户发送） |

---

## 权限说明

应用在 `entry/src/main/module.json5` 中声明了以下权限：

| 权限名称 | 用途 | 申请时机 |
|----------|------|----------|
| `ohos.permission.MICROPHONE` | 语音采集（讯飞 ASR） | 使用时动态申请 |
| `ohos.permission.INTERNET` | 网络通信（HTTP + WebSocket） | 安装时自动授予 |
| `ohos.permission.GET_WIFI_INFO` | 获取 WiFi 连接信息 | 安装时自动授予 |
| `ohos.permission.GET_WIFI_LOCAL_MAC` | 获取设备 WiFi MAC 地址（作为 device-id） | 安装时自动授予 |

> **注意**：麦克风权限为动态权限，首次使用语音功能时会弹出授权对话框，用户需手动允许。

---

## 第三方依赖

### 运行时依赖

| 库名 | 版本 | 用途 |
|------|------|------|
| `@ohos/crypto-js` | ^2.0.0 | 讯飞 API HMAC-SHA256 签名计算 |

### 开发依赖

| 库名 | 版本 | 用途 |
|------|------|------|
| `@ohos/hypium` | 1.0.25 | HarmonyOS 单元测试框架 |
| `@ohos/hamock` | 1.0.0 | 测试 Mock 工具 |

### 系统 SDK 模块

| 模块 | 用途 |
|------|------|
| `@kit.NetworkKit` (webSocket) | WebSocket 通信 |
| `@ohos.net.http` | HTTP 请求 |
| `@ohos.net.webSocket` | 讯飞 ASR WebSocket |
| `@ohos.wifiManager` | WiFi 状态监听 |
| `@kit.ArkTS` (util) | UUID 生成、Base64 编解码 |
| `@kit.ArkUI` (promptAction) | Toast 提示 |
| `@kit.AbilityKit` | UIAbility 生命周期 |
| `@ohos.multimedia.audio` | 音频采集 |

---

## 常见问题

### Q: 编译报错 "SDK not found"
**A**: 打开 DevEco Studio > File > Settings > HarmonyOS SDK，确保已安装 API 12 的 SDK Platform。

### Q: 真机无法安装应用
**A**: 确保设备已开启开发者模式和 USB 调试模式。部分设备需要在拨号界面输入特定代码开启开发者选项。

### Q: 语音功能无法使用
**A**: 检查以下几点：
1. 确认麦克风权限已授予
2. 确认 `Constants.ets` 中的讯飞凭证配置正确
3. 确认设备已连接网络（讯飞 ASR 需要 WebSocket 连接）

### Q: 传感器数据不更新
**A**: 检查以下几点：
1. 确认 `API_URL.ets` 中的服务器地址正确
2. 确认后端服务已启动（端口 8090）
3. 确认设备与服务器在同一网络或服务器可公网访问
4. 如果后端不可用，应用会自动降级为模拟数据模式

### Q: WebSocket 连接失败
**A**: 检查以下几点：
1. 确认后端 WebSocket 服务已启动（端口 8000）
2. 确认服务器防火墙已放行 8000 端口
3. 查看设备日志中 WebSocket 连接错误信息

### Q: ohpm install 失败
**A**: 检查网络连接，ohpm 需要访问 HarmonyOS 包仓库。如在国内网络环境下，确保网络代理配置正确，或尝试切换网络。

---

## 许可证

本项目仅供学习和研究使用。
