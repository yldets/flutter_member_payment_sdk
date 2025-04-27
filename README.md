# Flutter会员支付SDK (v0.1.0)

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
    git:
      url: [Git仓库URL]  # 请将[Git仓库URL]替换为实际的Git仓库地址
      ref: v0.1.0        # 指定版本
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

## 重要文档

- [团队使用指南](./团队使用指南.md) - 详细的API使用说明和最佳实践
- [实际项目集成指南](./实际项目集成指南.md) - 将SDK集成到实际项目的步骤
- [提交到Git仓库指南](./提交到Git仓库指南.md) - 如何将SDK提交到Git仓库
- [贡献指南](./CONTRIBUTING.md) - 如何参与SDK开发

## 示例应用

在`example`目录下提供了示例应用和Mock服务器，用于测试SDK功能。

## 版本历史

有关版本更新内容，请参阅[CHANGELOG.md](./CHANGELOG.md)文件。

## 许可证

本项目采用MIT许可证 - 详见[LICENSE](./LICENSE)文件。