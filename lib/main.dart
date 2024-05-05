import 'package:flutter/material.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxy Toggle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProxyToggleScreen(),
    );
  }
}

class ProxyToggleScreen extends StatefulWidget {
  @override
  _ProxyToggleScreenState createState() => _ProxyToggleScreenState();
}

class _ProxyToggleScreenState extends State<ProxyToggleScreen> {
  bool _proxyEnabled = false;
  TextEditingController _proxyController = TextEditingController();
  List<String> _logMessages = [];

  void _toggleProxy() async {
    // 检测是否已设置系统代理
    try {
      final result = await Process.run('NET', ['SESSION']);
      if (result.exitCode != 0) {
        print('系统代理未设置');
        _addLogMessage('系统代理未设置');
        return;
      }
    } catch (e) {
      print('检测系统代理时出错：$e');
      _addLogMessage('检测系统代理时出错：$e');
      return;
    }

    // 切换代理状态
    if (_proxyEnabled) {
      // 取消代理
      await Process.run('git', ['config', '--global', '--unset', 'http.proxy']);
      await Process.run('git', ['config', '--global', '--unset', 'https.proxy']);
      print('Git 代理已关闭');
      _addLogMessage('Git 代理已关闭');
    } else {
      // 获取用户输入的代理地址和端口
      String proxy = _proxyController.text;
      if (proxy.isEmpty) {
        print('请输入代理地址和端口号');
        _addLogMessage('请输入代理地址和端口号');
        return;
      }

      // 设置代理
      await Process.run('git', ['config', '--global', 'http.proxy', proxy]);
      await Process.run('git', ['config', '--global', 'https.proxy', proxy]);
      print('Git 代理已启用');
      _addLogMessage('Git 代理已启用');
    }

    setState(() {
      _proxyEnabled = !_proxyEnabled;
    });
  }

  void _addLogMessage(String message) {
    setState(() {
      _logMessages.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proxy Toggle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.asset(
              _proxyEnabled ? 'assets/logo_enabled.gif' : 'assets/logo_disabled.png',
              height: 200,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _proxyController,
              decoration: InputDecoration(
                labelText: '代理服务器地址和端口号',
                hintText: '例如：127.0.0.1:7890',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _toggleProxy,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_proxyEnabled ? Icons.stop : Icons.play_arrow),
                  SizedBox(width: 8.0),
                  Text(_proxyEnabled ? '关闭代理' : '开启代理'),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: _logMessages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_logMessages[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _proxyController.dispose();
    super.dispose();
  }
}
