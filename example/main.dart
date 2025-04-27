import 'package:flutter/material.dart';
import 'package:flutter_member_payment_sdk/flutter_member_payment_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _sdk = FlutterMemberPaymentSDK.instance;
  bool _isInitialized = false;
  String _statusMessage = '初始化中...';

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    try {
      // 创建开发环境配置，连接到本地Mock服务器
      final config = SDKConfig.dev(
        appId: 'test_app_id',
        serverUrl: 'http://localhost:3000',
        debug: true,
      );

      // 初始化SDK
      await _sdk.initialize(config);

      setState(() {
        _isInitialized = true;
        _statusMessage = 'SDK初始化成功';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '初始化失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDK示例',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('会员支付SDK示例'),
        ),
        body: _isInitialized
            ? const SDKDemoScreen()
            : Center(child: Text(_statusMessage)),
      ),
    );
  }
}

class SDKDemoScreen extends StatefulWidget {
  const SDKDemoScreen({Key? key}) : super(key: key);

  @override
  State<SDKDemoScreen> createState() => _SDKDemoScreenState();
}

class _SDKDemoScreenState extends State<SDKDemoScreen> {
  final _sdk = FlutterMemberPaymentSDK.instance;
  final _usernameController = TextEditingController(text: 'testuser'); // 预填测试账号
  final _passwordController = TextEditingController(text: 'password123'); // 预填测试密码

  bool _isLoggedIn = false;
  String _statusMessage = '';
  MemberInfo? _memberInfo;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    setState(() {
      _isLoggedIn = _sdk.auth.isLoggedIn();
      if (_isLoggedIn) {
        _statusMessage = '已登录';
        _fetchMemberInfo();
      } else {
        _statusMessage = '未登录';
      }
    });
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _statusMessage = '用户名和密码不能为空';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = '登录中...';
      });

      final result = await _sdk.auth.login(
        _usernameController.text,
        _passwordController.text,
      );

      setState(() {
        if (result.success) {
          _isLoggedIn = true;
          _statusMessage = '登录成功';
          _fetchMemberInfo();
        } else {
          _statusMessage = '登录失败: ${result.errorMessage}';
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = '登录错误: $e';
      });
    }
  }

  Future<void> _logout() async {
    try {
      setState(() {
        _statusMessage = '登出中...';
      });

      final success = await _sdk.auth.logout();

      setState(() {
        _isLoggedIn = false;
        _memberInfo = null;
        _statusMessage = success ? '登出成功' : '登出失败，但已清除本地登录状态';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '登出错误: $e';
      });
    }
  }

  Future<void> _fetchMemberInfo() async {
    if (!_isLoggedIn) {
      setState(() {
        _statusMessage = '请先登录';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = '获取会员信息中...';
      });

      final result = await _sdk.member.fetchMemberInfo(forceRefresh: true);

      setState(() {
        if (result.success) {
          _memberInfo = result.memberInfo;
          _statusMessage = '获取会员信息成功';
        } else {
          _statusMessage = '获取会员信息失败: ${result.errorMessage}';
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = '获取会员信息错误: $e';
      });
    }
  }

  Future<void> _mockPayment() async {
    if (!_isLoggedIn) {
      setState(() {
        _statusMessage = '请先登录';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = '支付中...';
      });

      // 生成一个模拟订单ID
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      
      final result = await _sdk.payment.payOrder(
        orderId,
        amount: 99.99,
      );

      setState(() {
        if (result.success) {
          _statusMessage = '支付成功，订单ID: ${result.orderId}';
        } else {
          _statusMessage = '支付失败: ${result.errorMessage}';
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = '支付错误: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '状态: $_statusMessage',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '登录状态: ${_isLoggedIn ? '已登录' : '未登录'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_memberInfo != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '会员信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('会员ID: ${_memberInfo!.userId}'),
                    Text('会员等级: ${_memberInfo!.levelName}'),
                    Text('会员有效期: ${_memberInfo!.expiryDate?.toString() ?? '永久'}'),
                    Text('会员积分: ${_memberInfo!.points}'),
                    Text('会员状态: ${_memberInfo!.isActive ? '有效' : '已过期'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (!_isLoggedIn) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '登录',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        hintText: '请输入用户名',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '密码',
                        hintText: '请输入密码',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Text('登录'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _fetchMemberInfo,
                    child: const Text('获取会员信息'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _mockPayment,
                    child: const Text('模拟支付'),
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}