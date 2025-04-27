const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

// 记录所有请求
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  console.log('Headers:', req.headers);
  if (req.body && Object.keys(req.body).length > 0) {
    console.log('Body:', JSON.stringify(req.body));
  }
  if (req.query && Object.keys(req.query).length > 0) {
    console.log('Query:', req.query);
  }
  next();
});

// 登录API
app.post('/auth/login', (req, res) => {
  const { username, password } = req.body;
  
  // 简单的验证
  if (username === 'testuser' && password === 'password123') {
    res.json({
      success: true,
      userId: 'test_user_123',
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
    });
  } else {
    res.json({
      success: false,
      message: '用户名或密码错误',
    });
  }
});

// 登出API
app.post('/auth/logout', (req, res) => {
  res.json({
    success: true
  });
});

// 会员信息API
app.post('/member/info', (req, res) => {
  // 验证授权头（在实际项目中应该验证token）
  const authHeader = req.headers.authorization;
  
  if (authHeader && authHeader.startsWith('Bearer ')) {
    res.json({
      success: true,
      data: {
        userId: 'test_user_123',
        level: 'premium',
        expiryDate: '2023-12-31T23:59:59Z',
        points: 1000,
      },
    });
  } else {
    res.json({
      success: false,
      message: '未授权',
    });
  }
});

// 支付API
app.post('/pay/order', (req, res) => {
  const { orderId, amount, currency } = req.body;
  
  // 模拟特定订单号的失败情况
  if (orderId === 'fail_order') {
    res.json({
      success: false,
      message: '余额不足',
    });
    return;
  }
  
  // 简单验证
  if (orderId && amount) {
    res.json({
      success: true,
      transactionId: 'test_transaction_' + Date.now(),
    });
  } else {
    res.json({
      success: false,
      message: '订单信息不完整',
    });
  }
});

// 查询支付结果API
app.get('/pay/query', (req, res) => {
  const { orderId } = req.query;
  
  // 模拟特定订单号的不同状态
  if (orderId === 'pending_order') {
    res.json({
      success: true,
      data: {
        orderId: orderId,
        transactionId: 'test_transaction_pending',
        status: 'pending',
      },
    });
    return;
  }
  
  if (orderId) {
    res.json({
      success: true,
      data: {
        orderId: orderId,
        transactionId: 'test_transaction_' + orderId.substring(orderId.length - 3),
        status: 'completed',
      },
    });
  } else {
    res.json({
      success: false,
      message: '订单ID不能为空',
    });
  }
});

// 用户角色测试API - 非会员
app.post('/member/info/none', (req, res) => {
  res.json({
    success: true,
    data: {
      userId: 'test_user_123',
      level: 'none',
      points: 0,
    },
  });
});

// 用户角色测试API - VIP会员
app.post('/member/info/vip', (req, res) => {
  res.json({
    success: true,
    data: {
      userId: 'test_user_123',
      level: 'vip',
      expiryDate: '2050-12-31T23:59:59Z',
      points: 10000,
    },
  });
});

// 健康检查API
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.listen(port, () => {
  console.log(`Mock服务器运行在http://localhost:${port}`);
  console.log('可用的测试端点:');
  console.log('- POST /auth/login');
  console.log('- POST /auth/logout');
  console.log('- POST /member/info');
  console.log('- POST /member/info/none (非会员)');
  console.log('- POST /member/info/vip (VIP会员)');
  console.log('- POST /pay/order');
  console.log('- GET /pay/query');
  console.log('- GET /health (健康检查)');
});