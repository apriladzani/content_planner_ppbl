import 'package:flutter/material.dart';

class UnsupportedScreen extends StatelessWidget {
  const UnsupportedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unsupported Platform')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Icon(Icons.block, size: 72, color: Colors.redAccent),
            SizedBox(height: 24),
            Text(
              'Aplikasi ini menggunakan SQLite melalui sqflite.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Sqflite tidak didukung di Flutter Web. Silakan jalankan aplikasi di perangkat Android/iOS atau emulator untuk menggunakan database SQLite.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
