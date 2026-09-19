import 'package:flutter/material.dart';
import 'package:nisit_hub/pages/AI_page.dart';
import 'package:nisit_hub/pages/Building_page.dart';
import 'package:nisit_hub/pages/community_page.dart';
import 'package:nisit_hub/pages/profile_page.dart';
import '../services/authentication_service.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';
import 'login_page.dart';
import 'schedule_page.dart';

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
              width: 44,
              height: 44,
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

              if (page == 'AI') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AIPage()),
                );
                return;
              }

              if (page == 'ตึกเรียน') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BuildingPage()),
                );
                return;
              }

              if (page == 'ชุมชน') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CommunityPage()),
                );
                return;
              }
              
              if (page == 'โปรไฟล์') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
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
              PopupMenuItem(value: 'Home', child: Text('หน้าหลัก')),
              PopupMenuItem(value: 'AI', child: Text('AI')),
              PopupMenuItem(value: 'ตึกเรียน', child: Text('ตึกเรียน')),
              PopupMenuItem(value: 'ชุมชน', child: Text('ชุมชน')),
              PopupMenuItem(value: 'โปรไฟล์', child: Text('โปรไฟล์')),
              PopupMenuItem(value: 'Logout', child: Text('ออกจากระบบ')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: AuthenticationService().getCurrentUserFullName(),
          builder: (context, nameSnapshot) {
            final fullName = nameSnapshot.data?.isNotEmpty == true
                ? nameSnapshot.data!
                : AuthenticationService.userName;
            return Column(
              children: [
                const SizedBox(height: 14),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Khun $fullName',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(children: [
                        Icon(Icons.calendar_month_outlined),
                        SizedBox(width: 6),
                        Text("Today's Schedule", style: TextStyle(fontSize: 18)),
                      ]),
                      IconButton(
                        tooltip: 'จัดการตารางเรียน',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SchedulePage()),
                        ),
                        icon: const Icon(Icons.edit_calendar_outlined),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<ScheduleModel>>(
                    stream: ScheduleService().watchSchedules(),
                    builder: (context, scheduleSnapshot) {
                      if (scheduleSnapshot.hasError) {
                        return Center(child: Text('โหลดตารางเรียนไม่สำเร็จ\n${scheduleSnapshot.error}'));
                      }
                      if (!scheduleSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final today = DateTime.now().weekday;
                      final schedules = scheduleSnapshot.data!
                          .where((schedule) => schedule.weekday == today)
                          .toList();
                      if (schedules.isEmpty) {
                        return Center(
                          child: Text(
                            'วันนี้ไม่มีตารางเรียน\nกดไอคอนแก้ไขเพื่อเพิ่มวิชา',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        itemCount: schedules.length,
                        itemBuilder: (context, index) => ScheduleTile(schedule: schedules[index]),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 14,
                    alignment: WrapAlignment.center,
                    children: [
                      _homeButton(
                        context,
                        'งานที่ต้องส่ง',
                        Icons.assignment_outlined,
                        () => _showUnavailable(context, 'งานที่ต้องส่ง'),
                      ),
                      _homeButton(
                        context,
                        'ตึกเรียน',
                        Icons.business_outlined,
                        () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const BuildingPage()),
                        ),
                      ),
                      _homeButton(
                        context,
                        'AI ติวเตอร์',
                        Icons.auto_awesome_outlined,
                        () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AIPage()),
                        ),
                      ),
                      _homeButton(
                        context,
                        'ชุมชน',
                        Icons.people_outline,
                        () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CommunityPage()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _homeButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 145,
      height: 48,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  void _showUnavailable(BuildContext context, String pageName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$pageName ยังไม่มีหน้าจอ')),
    );
  }
}

class ScheduleTile extends StatelessWidget {
  const ScheduleTile({super.key, required this.schedule});

  final ScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xffffef91),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${SchedulePageLabels.weekdays[schedule.weekday - 1]}  ${_formatMinutes(schedule.startMinutes)}-${_formatMinutes(schedule.endMinutes)}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text('${schedule.courseCode} | ${schedule.courseName}'),
            Text('ห้อง ${schedule.room.isEmpty ? '-' : schedule.room} | Sec ${schedule.section.isEmpty ? '-' : schedule.section}'),
          ],
        ),
      ),
    );
  }
}

String _formatMinutes(int minutes) {
  final hour = minutes ~/ 60;
  final minute = minutes % 60;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}