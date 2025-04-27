# Flutter会员支付SDK

一个用于Flutter应用的通用移动端SDK，提供登录、会员管理和支付功能。

## 功能特点

- 用户认证（登录/登出）
- 会员信息管理
- 支付处理
- Token自动管理
- 错误处理

## 安装

在`pubspec.yaml`文件中添加依赖：

```yaml
dependencies:
  flutter_member_payment_sdk:
    path: [SDK路径]  # 本地开发使用
    # 或使用Git仓库
    # git:
    #  url: [Git仓库URL]
    #  ref: [分支或标签]
```

## 快速开始

### 初始化SDK

```dart
import 'package:flutter_member_payment_sdk/flutter_member_payment_sdk.dart';

// 获取SDK实例
final sdk = FlutterMemberPaymentSDK.instance;

// 初始化SDK
await sdk.initialize(
  SDKConfig.dev(
    appId: 'your_app_id',
    serverUrl: 'https://your-api-server.com',
    debug: true, // 开发环境建议开启
  ),
);
```

### 用户认证

```dart
// 登录
final loginResult = await sdk.auth.login('username', 'password');
if (loginResult.success) {
  print('登录成功: ${loginResult.userId}');
} else {
  print('登录失败: ${loginResult.errorMessage}');
}

// 检查是否登录
bool isLoggedIn = sdk.auth.isLoggedIn();

// 登出
await sdk.auth.logout();
```

### 会员功能

```dart
// 获取会员信息
final memberResult = await sdk.member.fetchMemberInfo();
if (memberResult.success) {
  final memberInfo = memberResult.memberInfo!;
  print('会员等级: ${memberInfo.levelName}');
  print('积分: ${memberInfo.points}');
  print('是否有效: ${memberInfo.isActive}');
} else {
  print('获取会员信息失败: ${memberResult.errorMessage}');
}

// 强制刷新会员信息（不使用缓存）
final refreshedResult = await sdk.member.fetchMemberInfo(forceRefresh: true);

// 清除会员信息缓存
sdk.member.clearCache();
```

### 支付功能

```dart
// 支付订单
final paymentResult = await sdk.payment.payOrder(
  'order_12345',
  amount: 99.99,
  currency: 'CNY',
);

if (paymentResult.success) {
  print('支付成功: ${paymentResult.transactionId}');
} else {
  print('支付失败: ${paymentResult.errorMessage}');
}

// 查询支付结果
final queryResult = await sdk.payment.queryPaymentResult('order_12345');
if (queryResult.success) {
  print('交易ID: ${queryResult.transactionId}');
} else {
  print('查询支付结果失败: ${queryResult.errorMessage}');
}
```

## 实际项目集成测试

### 1. 启动Mock服务器

我们提供了一个Mock服务器用于测试，位于`example/mock_server`目录：

```bash
cd example/mock_server
npm install
npm start
```

服务器将在`http://localhost:3000`启动。

### 2. 运行测试应用

我们提供了一个测试应用用于展示SDK功能，位于`example/sdk_test_app`目录：

```bash
cd example/sdk_test_app
flutter pub get
flutter run
```

在测试应用中：

1. 首先初始化SDK，输入Mock服务器的URL（如：`http://localhost:3000`）
2. 使用测试账号登录：用户名`testuser`，密码`password123`
3. 尝试获取会员信息
4. 尝试支付订单（可使用`fail_order`作为订单ID测试失败场景）
5. 查询支付结果

## 配置选项

### 环境配置

SDK提供三种环境配置选项：

```dart
// 开发环境
SDKConfig.dev(appId: 'app_id', serverUrl: 'dev_url', debug: true);

// 测试环境
SDKConfig.staging(appId: 'app_id', serverUrl: 'staging_url');

// 生产环境
SDKConfig.production(appId: 'app_id', serverUrl: 'prod_url');
```

## 常见问题

### 1. SDK初始化失败

- 确保`serverUrl`正确
- 确保网络连接正常

### 2. 登录失败

- 验证用户名密码是否正确
- 检查服务器端API是否正常工作

### 3. Token相关问题

- SDK会自动管理Token，如果遇到认证问题，可尝试重新登录

## 开发说明

### 目录结构

```
lib/
 ├─ auth/            - 认证相关服务
 ├─ member/          - 会员相关服务
 ├─ payment/         - 支付相关服务
 ├─ common/          - 通用工具类
 ├─ config/          - 配置相关
 └─ flutter_member_payment_sdk.dart - SDK入口
```