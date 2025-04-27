import 'package:flutter/material.dart';
import 'package:flutter_member_payment_sdk/flutter_member_payment_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDK测试应用',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SdkTestPage(),
    );
  }
}

class SdkTestPage extends StatefulWidget {
  const SdkTestPage({Key? key}) : super(key: key);

  @override
  _SdkTestPageState createState() => _SdkTestPageState();
}

class _SdkTestPageState extends State<SdkTestPage> {
  final _sdk = FlutterMemberPaymentSDK.instance;
  bool _isInitialized = false;
  String _logMessage = '';
  
  TextEditingController _usernameController = TextEditingController(text: 'testuser');
  TextEditingController _passwordController = TextEditingController(text: 'password123');
  TextEditingController _orderIdController = TextEditingController(text: 'test_order_001');
  TextEditingController _amountController = TextEditingController(text: '99.99');
  TextEditingController _serverUrlController = TextEditingController(text: 'http://localhost:3000');

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initializeSDK() async {
    try {
      final serverUrl = _serverUrlController.text.trim();
      
      if (serverUrl.isEmpty) {
        _appendLog('❌ 服务器URL不能为空');
        return;
      }
      
      final config = SDKConfig.dev(
        appId: 'test_app_id',
        serverUrl: serverUrl,
        debug: true,
      );
      
      await _sdk.initialize(config);
      
      setState(() {
        _isInitialized = true;
        _logMessage = '✅ SDK初始化成功';
      });
    } catch (e) {
      setState(() {
        _logMessage = '❌ SDK初始化失败: $e';
      });
    }
  }

  Future<void> _login() async {
    if (!_isInitialized) {
      _appendLog('请先初始化SDK');
      return;
    }
    
    try {
      final result = await _sdk.auth.login(
        _usernameController.text,
        _passwordController.text,
      );
      
      if (result.success) {
        _appendLog('✅ 登录成功: ${result.userId}');
      } else {
        _appendLog('❌ 登录失败: ${result.errorMessage}');
      }
    } catch (e) {
      _appendLog('❌ 登录异常: $e');
    }
  }

  Future<void> _fetchMemberInfo() async {
    if (!_isInitialized) {
      _appendLog('请先初始化SDK');
      return;
    }
    
    if (!_sdk.auth.isLoggedIn()) {
      _appendLog('请先登录');
      return;
    }
    
    try {
      final result = await _sdk.member.fetchMemberInfo(forceRefresh: true);
      
      if (result.success) {
        final memberInfo = result.memberInfo!;
        _appendLog('✅ 会员信息: ${memberInfo.levelName}, 积分: ${memberInfo.points}');
        _appendLog('  用户ID: ${memberInfo.userId}');
        _appendLog('  到期日期: ${memberInfo.expiryDate?.toIso8601String() ?? "无"}');
        _appendLog('  会员状态: ${memberInfo.isActive ? "有效" : "无效"}');
      } else {
        _appendLog('❌ 获取会员信息失败: ${result.errorMessage}');
      }
    } catch (e) {
      _appendLog('❌ 获取会员信息异常: $e');
    }
  }

  Future<void> _payOrder() async {
    if (!_isInitialized) {
      _appendLog('请先初始化SDK');
      return;
    }
    
    if (!_sdk.auth.isLoggedIn()) {
      _appendLog('请先登录');
      return;
    }
    
    try {
      final orderId = _orderIdController.text;
      double amount;
      try {
        amount = double.parse(_amountController.text);
      } catch (e) {
        _appendLog('❌ 金额格式错误');
        return;
      }
      
      final result = await _sdk.payment.payOrder(
        orderId,
        amount: amount,
      );
      
      if (result.success) {
        _appendLog('✅ 支付成功:');
        _appendLog('  订单ID: ${result.orderId}');
        _appendLog('  交易ID: ${result.transactionId}');
      } else {
        _appendLog('❌ 支付失败: ${result.errorMessage}');
      }
    } catch (e) {
      _appendLog('❌ 支付异常: $e');
    }
  }

  Future<void> _queryPayment() async {
    if (!_isInitialized) {
      _appendLog('请先初始化SDK');
      return;
    }
    
    if (!_sdk.auth.isLoggedIn()) {
      _appendLog('请先登录');
      return;
    }
    
    try {
      final orderId = _orderIdController.text;
      
      final result = await _sdk.payment.queryPaymentResult(orderId);
      
      if (result.success) {
        _appendLog('✅ 查询支付结果成功:');
        _appendLog('  订单ID: ${result.orderId}');
        _appendLog('  交易ID: ${result.transactionId}');
      } else {
        _appendLog('❌ 查询支付结果失败: ${result.errorMessage}');
      }
    } catch (e) {
      _appendLog('❌ 查询支付结果异常: $e');
    }
  }

  Future<void> _logout() async {
    if (!_isInitialized) {
      _appendLog('请先初始化SDK');
      return;
    }
    
    try {
      final result = await _sdk.auth.logout();
      
      if (result) {
        _appendLog('✅ 登出成功');
      } else {
        _appendLog('❌ 登出失败');
      }
    } catch (e) {
      _appendLog('❌ 登出异常: $e');
    }
  }

  void _appendLog(String message) {
    setState(() {
      _logMessage = '$message\n$_logMessage';
    });
  }

  void _clearLog() {
    setState(() {
      _logMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SDK测试'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SDK状态: ${_isInitialized ? "已初始化" : "未初始化"}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('登录状态: ${_sdk.isInitialized && _sdk.auth.isLoggedIn() ? "已登录" : "未登录"}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('SDK初始化', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _serverUrlController,
                      decoration: const InputDecoration(
                        labelText: '服务器URL',
                        hintText: 'http://localhost:3000',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _initializeSDK,
                      child: const Text('初始化SDK'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('登录测试', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: '用户名'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: '密码'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _login,
                            child: const Text('登录'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('登出'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('会员测试', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchMemberInfo,
                      child: const Text('获取会员信息'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('支付测试', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _orderIdController,
                      decoration: const InputDecoration(
                        labelText: '订单ID',
                        hintText: '输入fail_order测试失败场景',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '金额'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _payOrder,
                            child: const Text('支付订单'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _queryPayment,
                            child: const Text('查询支付结果'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('日志', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: _clearLog,
                          child: const Text('清除'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: SingleChildScrollView(
                        child: Text(_logMessage),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}