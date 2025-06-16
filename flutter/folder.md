
---

## 📁 推荐目录结构

```
lib/
├── main.dart
│
├── core/                     # 核心库，全局通用组件或工具类
│   ├── constants/            # 全局常量（如 API 地址、字符串、颜色等）
│   ├── utils/                # 工具函数（日期、格式化、网络处理等）
│   ├── exceptions/           # 自定义异常类
│   └── services/             # 核心服务（如本地存储、日志、网络请求封装）
│
├── shared/                   # 可跨模块复用的 UI 组件和模型
│   ├── widgets/              # 可复用的小部件（如按钮、输入框、加载指示器）
│   └── models/               # 公共数据模型（如 User, ResponseModel）
│
├── routes/                   # 路由相关逻辑
│   ├── app_router.dart       # 使用 go_router 或 auto_route 管理导航
│   └── route_names.dart      # 定义路由名称常量
│
├── features/                 # 功能模块（每个模块独立，高内聚低耦合）
│   ├── login/                # 登录模块
│   │   ├── screens/          # 页面组件
│   │   ├── widgets/          # 模块内部小部件（不对外暴露）
│   │   ├── models/           # 数据模型
│   │   ├── services/         # 网络或业务逻辑
│   │   └── controllers/      # 控制器（如 BLoC / Provider / GetX controller）
│   │
│   ├── production/           # 生产模块
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── models/
│   │   ├── services/
│   │   └── controllers/
│   │
│   ├── inventory/            # 库存模块
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── models/
│   │   ├── services/
│   │   └── controllers/
│   │
│   ├── maintenance/          # 设备维修模块
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── models/
│   │   ├── services/
│   │   └── controllers/
│   │
│   └── settings/             # 设置模块
│       ├── screens/
│       ├── widgets/
│       ├── models/
│       ├── services/
│       └── controllers/
│
└── main_app.dart             # 主 App Widget（分离 main.dart 和主界面）
```

---

## 🧩 各目录说明与作用

| 目录名        | 用途说明                                                                 |
|---------------|--------------------------------------------------------------------------|
| `main.dart`   | 应用入口文件，通常只引入 `main_app.dart` 并运行 `runApp()`              |
| `core/`       | 存放全局核心组件，如常量、工具类、异常处理、基础服务等                   |
| `shared/`     | 存放跨模块复用的 UI 组件和数据模型                                       |
| `routes/`     | 管理应用的路由逻辑，包括导航配置和路由命名                               |
| `features/`   | 按功能划分的各个业务模块（登录、生产、库存、设备等），每个模块自成体系   |

---

## 🎯 每个功能模块（feature）的子目录结构

以 `production/` 模块为例：

```
production/
├── screens/
│   └── production_list_screen.dart    # 生产列表页面
├── widgets/
│   └── order_card_widget.dart         # 显示订单信息的卡片组件
├── models/
│   └── production_order.dart          # 生产订单模型
├── services/
│   └── production_service.dart        # 调用后端 API 获取数据
└── controllers/
    └── production_controller.dart     # 状态管理控制器（BLoC / Provider / GetX）
```

---

## ✅ 命名建议（回顾）

| 类型             | 命名规范         | 示例                          |
|------------------|------------------|-------------------------------|
| 文件/目录        | snake_case       | `production_list_screen.dart` |
| 类               | PascalCase       | `ProductionOrder`, `ProductionService` |
| 变量/方法        | camelCase        | `userName`, `fetchOrders()`   |
| 常量             | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`             |
| 枚举类型         | PascalCase       | `ThemeMode`                   |
| 枚举值           | UPPER_SNAKE_CASE | `LIGHT`, `DARK`               |

---

## 🛠️ 技术选型建议（可选）

- **状态管理**：推荐使用 `Provider` + `ChangeNotifier` 或 `Riverpod`，中大型项目可用 `Bloc`。
- **路由管理**：推荐使用 `go_router` 或 `auto_route` 实现声明式导航。
- **网络请求**：封装统一的 `HttpService`，支持拦截器、错误处理。
- **数据持久化**：使用 `shared_preferences` 或 `hive` 存储本地数据。
- **国际化**：使用 `flutter_gen/gen_l10n` 支持多语言。
- **依赖注入**：可选 `get_it` 配合 `injectable` 实现 DI。

---

## 💡 小贴士

- **模块隔离**：每个 feature 是一个独立包，方便后期抽离为插件或模块化打包。
- **测试友好**：各层清晰，便于做单元测试和 widget 测试。
- **易于维护**：结构清晰，新人也能快速理解代码逻辑。

---

