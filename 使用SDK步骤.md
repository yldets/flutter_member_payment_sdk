# 使用Flutter会员支付SDK的步骤

本文档提供给团队成员使用SDK的简明步骤指南。

## 第一步：获取SDK

已为您准备好SDK包，包含以下内容：

- `lib/` - SDK源码
- `pubspec.yaml` - 依赖配置
- `README.md` - 基本使用说明
- `团队使用指南.md` - 详细API使用说明
- `实际项目集成指南.md` - 详细集成步骤
- `提交到Git仓库指南.md` - Git仓库提交说明
- `example/` - 示例和Mock服务器

## 第二步：将SDK添加到团队的Git仓库

按照[提交到Git仓库指南.md](./提交到Git仓库指南.md)中的步骤，将SDK代码提交到团队的私有Git仓库。

## 第三步：在Flutter项目中引用SDK

在您的Flutter项目的`pubspec.yaml`文件中添加以下依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 从团队Git仓库引用SDK
  flutter_member_payment_sdk:
    git:
      url: https://团队仓库地址/flutter_member_payment_sdk.git
      ref: v0.1.0  # 指定版本标签
```

执行依赖更新：

```bash
flutter pub get
```

## 第四步：初始化SDK

在应用启动时（通常在`main.dart`文件中），初始化SDK：

```dart
import 'package:flutter_member_payment_sdk/flutter_member_payment_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化SDK
  await initializeSDK();
  
  runApp(MyApp());
}

Future<void> initializeSDK() async {
  final sdk = FlutterMemberPaymentSDK.instance;
  
  final config = SDKConfig.dev(  // 开发阶段使用dev环境
    appId: '您的应用ID',
    serverUrl: '您的API服务器地址',
    debug: true,  // 开发阶段建议启用调试
  );
  
  try {
    await sdk.initialize(config);
    print('SDK初始化成功');
  } catch (e) {
    print('SDK初始化失败: $e');
  }
}
```

## 第五步：使用SDK功能

### 用户登录

```dart
Future<void> login(String username, String password) async {
  final sdk = FlutterMemberPaymentSDK.instance;
  
  final result = await sdk.auth.login(username, password);
  
  if (result.success) {
    // 登录成功，进行后续操作
  } else {
    // 登录失败，显示错误信息
  }
}
```

### 获取会员信息

```dart
Future<void> getMemberInfo() async {
  final sdk = FlutterMemberPaymentSDK.instance;
  
  final result = await sdk.member.fetchMemberInfo();
  
  if (result.success) {
    // 使用会员信息
    final memberInfo = result.memberInfo!;
    // 更新UI等操作
  } else {
    // 处理错误
  }
}
```

### 处理支付

```dart
Future<void> processPayment(String orderId, double amount) async {
  final sdk = FlutterMemberPaymentSDK.instance;
  
  final result = await sdk.payment.payOrder(
    orderId,
    amount: amount,
  );
  
  if (result.success) {
    // 支付成功，进行后续操作
  } else {
    // 支付失败，处理错误
  }
}
```

## 第六步：测试SDK集成

1. 启动示例中的Mock服务器：
   ```bash
   cd example/mock_server
   npm install
   npm start
   ```

2. 修改SDK初始化配置，指向Mock服务器：
   ```dart
   final config = SDKConfig.dev(
     appId: 'test_app_id',
     serverUrl: 'http://localhost:3000',
     debug: true,
   );
   ```

3. 使用测试账号登录：
   - 用户名：`testuser`
   - 密码：`password123`

4. 测试会员和支付功能

## 第七步：查阅详细文档

如需更多详细信息，请参阅：

- [团队使用指南.md](./团队使用指南.md) - 完整API文档和最佳实践
- [实际项目集成指南.md](./实际项目集成指南.md) - 详细集成步骤和问题排查

## 问题反馈

如在使用过程中遇到问题，请联系SDK开发团队并提供：

1. 问题描述
2. 复现步骤
3. 相关代码片段
4. 错误日志（如有）