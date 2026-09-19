import 'package:flutter/material.dart';
import '../services/authentication_service.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text('Nisit Hub'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (page) {
              if (page == 'Home') {
                return;
              }

              if (page == 'Logout') {
                AuthenticationService().logout().then((_) {
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                });
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$page ยังไม่พร้อมใช้งาน')),
              );
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'หน้าหลัก', child: Text('หน้าหลัก')),
              PopupMenuItem(value: 'AI', child: Text('AI')),
              PopupMenuItem(value: 'ตึกเรียน', child: Text('ตึกเรียน')),
              PopupMenuItem(value: 'ชุมชน', child: Text('ชุมชน')),
              PopupMenuItem(value: 'โปรไฟล์', child: Text('โปรไฟล์')),
              PopupMenuItem(value: 'ออกจากระบบ', child: Text('ออกจากระบบ')),
            ],
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: AuthenticationService().getCurrentUserFullName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final fullName = snapshot.data?.isNotEmpty == true
                ? snapshot.data!
                : AuthenticationService.userName;
            return Text(
              'Welcome back\nKhun ''$fullName',
              textAlign: TextAlign.center,
            );
          },
        ),
      ),
    );
  }
}