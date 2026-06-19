📘 Vault Finance（VTF）iOS开发指令文档（给Claude执行版）
1. 📌 项目目标（必须严格执行）

请你（Claude）直接生成一个完整 iOS App 工程，项目名称为：

Vault Finance

这是一个 iPhone 专用的个人财务记录应用。

2. 🚨 强制技术约束（必须遵守）
开发语言：Swift
UI框架：UIKit（禁止SwiftUI）
最低版本：iOS 14.0
设备限制：仅 iPhone（禁止 iPad 适配）
屏幕方向：仅竖屏（Portrait Lock）
架构：MVC
存储方式：UserDefaults + JSON
网络：完全禁止（无API / 无联网 / 无云同步）
登录系统：禁止
3. 📛 命名规范（强制）
类名规则：

所有类必须以 VTF 开头

例如：

VTFDashboardViewController
VTFAddTransactionViewController
VTFStorageManager
方法规则：

所有方法必须以 vtf 开头

例如：

vtfSetupUI()
vtfLoadData()
vtfSaveTransaction()
vtfCalculateBalance()
Key规则：

所有存储key必须以 vtf 开头

例如：

vtf.transactions
4. 📱 App功能需求（必须全部实现）

你需要生成一个完整可运行App，包含以下5个页面：

4.1 Dashboard（首页）

功能：

显示总余额
显示本月收入
显示本月支出
显示最近10条交易记录

逻辑：

余额 = income总和 - expense总和
4.2 Transactions（交易列表）

功能：

UITableView展示所有交易
支持删除（swipe delete）
支持刷新数据
4.3 Add Transaction（新增交易）

功能：
用户可新增一条记录：

字段：

title（标题）
amount（金额）
type（income / expense）
category（分类）
date（日期）
note（可选）

保存流程：

读取本地数组
append新数据
写回UserDefaults
4.4 Statistics（统计页）

功能：

income总和
expense总和
net balance
category分类统计
4.5 Settings（设置页）

功能：

清空所有数据
显示版本号
预留货币设置入口
5. 🧾 数据模型（必须使用）
VTFTransaction
id: UUID
title: String
amount: Double
type: income / expense
category: String
date: Date
note: String?
VTFCategory（固定）
Food
Transport
Shopping
Entertainment
Bills
Salary
Other
6. 💾 存储层（必须实现）

必须创建：

VTFStorageManager

功能：

vtfSave([VTFTransaction])
vtfLoad() -> [VTFTransaction]

实现要求：

使用 UserDefaults
使用 JSONEncoder / Decoder
key = vtf.transactions
7. 🧠 核心计算逻辑
余额计算：
income总和 - expense总和
月度筛选：

基于 Date + Calendar 过滤当前月份数据

8. 🏠 导航结构（必须UINavigationController）

启动结构：

VTFDashboardViewController（Root）
Push 到其他页面

禁止 TabBar（除非你明确优化UI）

9. 🎨 UI要求（必须遵守）

风格：

极简金融风
类似 Apple Wallet / Revolut

颜色：

背景：白色或 #0F1115
income：绿色
expense：红色
主色：蓝色渐变

布局：

必须 AutoLayout
必须适配 iPhone Safe Area
禁止横屏布局代码
10. 🚫 禁止行为（重要）

你不能做以下事情：

❌ SwiftUI
❌ 网络请求
❌ 后端 API
❌ 登录系统
❌ iPad适配
❌ 横屏支持
❌ CloudKit
11. 📦 输出要求（非常重要）

请你直接生成：

完整 Xcode iOS 工程代码结构
所有 Swift 文件代码
所有 ViewController 实现
Storage 实现
Model 实现
可运行（不需要补代码）
12. 🎯 最终目标

生成一个：

👉 可直接运行的 iOS 14+ Swift UIKit App
👉 iPhone竖屏
👉 本地记账系统
👉 无任何依赖服务
