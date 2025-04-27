# Flutter会员支付SDK Mock服务器

这是一个为测试Flutter会员支付SDK而创建的简单Mock API服务器。

## 安装与运行

1. 确保已安装Node.js（建议12.x版本以上）
2. 在当前目录下运行以下命令安装依赖：

```bash
npm install
```

3. 启动服务器：

```bash
npm start
```

服务器将在localhost:3000端口启动。

## 可用的API端点

### 认证相关

- **POST /auth/login** - 用户登录
  - 请求体: `{ "username": "testuser", "password": "password123" }`
  - 成功响应: `{ "success": true, "userId": "test_user_123", "accessToken": "test_access_token", "refreshToken": "test_refresh_token" }`
  - 失败响应: `{ "success": false, "message": "用户名或密码错误" }`

- **POST /auth/logout** - 用户登出
  - 响应: `{ "success": true }`

### 会员相关

- **POST /member/info** - 获取会员信息
  - 需要在请求头中设置: `Authorization: Bearer test_access_token`
  - 成功响应: 
  ```json
  {
    "success": true,
    "data": {
      "userId": "test_user_123",
      "level": "premium",
      "expiryDate": "2023-12-31T23:59:59Z",
      "points": 1000
    }
  }
  ```
  - 失败响应: `{ "success": false, "message": "未授权" }`

- **POST /member/info/none** - 获取非会员信息（测试专用）
- **POST /member/info/vip** - 获取VIP会员信息（测试专用）

### 支付相关

- **POST /pay/order** - 支付订单
  - 请求体: `{ "orderId": "test_order_123", "amount": 99.99, "currency": "CNY" }`
  - 成功响应: `{ "success": true, "transactionId": "test_transaction_123456" }`
  - 失败响应: `{ "success": false, "message": "订单信息不完整" }`
  - 注意: 使用`orderId`为`fail_order`将模拟支付失败情况

- **GET /pay/query** - 查询支付结果
  - 查询参数: `?orderId=test_order_123`
  - 成功响应: 
  ```json
  {
    "success": true,
    "data": {
      "orderId": "test_order_123",
      "transactionId": "test_transaction_123",
      "status": "completed"
    }
  }
  ```
  - 失败响应: `{ "success": false, "message": "订单ID不能为空" }`
  - 注意: 使用`orderId`为`pending_order`将返回待处理状态

### 系统相关

- **GET /health** - 健康检查API
  - 响应: `{ "status": "ok", "timestamp": "2023-07-21T10:00:00.000Z", "version": "1.0.0" }`

## 特殊测试参数

- 使用`fail_order`作为订单ID将模拟支付失败场景
- 使用`pending_order`作为订单ID将模拟支付结果查询返回待处理状态