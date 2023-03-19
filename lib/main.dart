import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RC Controller App by Angger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.car_rental),
          title: Text('Rc Car Remote by Angger'),
          titleSpacing: 2.0,
        ),
        body: RCControllerWidget(),
      ),
    );
  }
}

class RCControllerWidget extends StatefulWidget {
  @override
  _RCControllerWidgetState createState() => _RCControllerWidgetState();
}

class _RCControllerWidgetState extends State<RCControllerWidget> {
  bool _isConnecting = false;
  bool _isConnected = false;
  String _ipAddress = "";
  String _currentCommand = "";

  Future<http.Response?> _sendCommand(String command) async {
    if (!_isConnected) {
      return null;
    }

    var url = Uri.parse('http://$_ipAddress/?State=$command');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Gagal mengirimkan perintah ke mobile RC');
    }
  }

  Future<bool> _checkConnection() async {
    var url = Uri.parse('http://$_ipAddress/?State=S');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  void _connectToRC() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      var isConnected = await _checkConnection();

      if (isConnected) {
        setState(() {
          _isConnected = true;
        });
      } else {
        throw Exception('Gagal melakukan koneksi ke mobile RC');
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _onButtonPressed(String command) {
    if (command == _currentCommand) {
      _sendCommand("stop");
      _currentCommand = "";
    } else {
      _sendCommand(command);
      _currentCommand = command;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapUp: (_) => _onButtonPressed("S"),
              onTapDown: (_) => _onButtonPressed("F"),
              child: Container(
                width: 60,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapUp: (_) => _onButtonPressed("S"),
              onTapDown: (_) => _onButtonPressed("L"),
              child: Container(
                width: 100,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.keyboard_arrow_left_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.stop,
                color: Colors.white,
                size: 60,
              ),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTapUp: (_) => _onButtonPressed("S"),
              onTapDown: (_) => _onButtonPressed("R"),
              child: Container(
                width: 100,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapUp: (_) => _onButtonPressed("S"),
              onTapDown: (_) => _onButtonPressed("B"),
              child: Container(
                width: 60,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Client RC"),
            SizedBox(width: 16),
            Container(
              width: 200,
              child: TextField(
                onChanged: (value) {
                  _ipAddress = value;
                  setState(() {});
                },
                decoration: InputDecoration(
                  label: Text("IP Address"),
                  hintText: "Contoh: 192.168.1.100",
                ),
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
        SizedBox(height: 16),
        ElevatedButton(
          //atur width agar tombol tidak terlalu lebar
          style: ElevatedButton.styleFrom(
            minimumSize: Size(100, 50),
          ),
          onPressed: _isConnecting || _isConnected ? null : _connectToRC,
          child: _isConnecting
              ? CircularProgressIndicator()
              : Text(_isConnected ? "Terhubung" : "Hubungkan"),
        ),
      ],
    );
  }
}
