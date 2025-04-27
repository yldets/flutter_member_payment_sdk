# Flutter会员支付SDK示例

本目录包含以下内容：

## 1. Mock服务器 (mock_server/)

一个简单的Node.js Mock API服务器，用于测试SDK功能。

**启动方法：**

```bash
cd mock_server
npm install
npm start
```

服务器将在http://localhost:3000端口启动。

详细信息请参阅：[Mock服务器文档](./mock_server/README.md)

## 2. 测试应用 (sdk_test_app/)

一个Flutter应用，演示如何集成和使用SDK。

**运行方法：**

```bash
cd sdk_test_app
flutter pub get
flutter run
```

详细信息请参阅：[测试应用文档](./sdk_test_app/README.md)

## 测试流程

1. 先启动Mock服务器
2. 运行测试应用
3. 在应用中完成"登录-获取会员信息-支付"流程测试

## 特殊测试用例

Mock服务器提供了一些特殊测试用例：

- 使用`fail_order`作为订单ID可测试支付失败场景
- 使用`pending_order`作为订单ID可测试支付状态为"待处理"

## 其他说明

- 测试应用默认连接到localhost:3000，如需修改服务器地址，请在应用初始化页面修改
- 默认测试账号：用户名`testuser`，密码`password123`