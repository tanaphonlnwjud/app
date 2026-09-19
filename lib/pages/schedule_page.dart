import 'package:flutter/material.dart';

import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตารางเรียน')),
      body: StreamBuilder<List<ScheduleModel>>(
        stream: ScheduleService().watchSchedules(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('โหลดตารางเรียนไม่สำเร็จ\n${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final schedules = snapshot.data!;
          if (schedules.isEmpty) {
            return const Center(child: Text('ยังไม่มีตารางเรียน'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schedules.length,
            itemBuilder: (context, index) => _ScheduleCard(schedule: schedules[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddSchedulePage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มวิชา'),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule});

  final ScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xffffef91),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          '${SchedulePageLabels.weekdays[schedule.weekday - 1]}  ${_formatMinutes(schedule.startMinutes)}-${_formatMinutes(schedule.endMinutes)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${schedule.courseCode.isEmpty ? '' : '${schedule.courseCode} | '}${schedule.courseName}\nห้อง ${schedule.room.isEmpty ? '-' : schedule.room} | Sec ${schedule.section.isEmpty ? '-' : schedule.section}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: schedule.id == null
              ? null
              : () => ScheduleService().deleteSchedule(schedule.id!),
        ),
      ),
    );
  }
}

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _courseName = TextEditingController();
  final _courseCode = TextEditingController();
  final _room = TextEditingController();
  final _section = TextEditingController();
  int _weekday = DateTime.now().weekday;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _saving = false;

  @override
  void dispose() {
    _courseName.dispose();
    _courseCode.dispose();
    _room.dispose();
    _section.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      _showMessage('กรุณาเลือกเวลาเริ่มและเวลาเลิก');
      return;
    }
    if (_minutes(_endTime!) <= _minutes(_startTime!)) {
      _showMessage('เวลาเลิกต้องมากกว่าเวลาเริ่ม');
      return;
    }

    setState(() => _saving = true);
    try {
      await ScheduleService().addSchedule(ScheduleModel(
        weekday: _weekday,
        startMinutes: _minutes(_startTime!),
        endMinutes: _minutes(_endTime!),
        courseName: _courseName.text.trim(),
        courseCode: _courseCode.text.trim(),
        room: _room.text.trim(),
        section: _section.text.trim(),
      ));
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      _showMessage('บันทึกไม่สำเร็จ: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มตารางเรียน')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<int>(
              value: _weekday,
              decoration: const InputDecoration(labelText: 'วันเรียน'),
              items: List.generate(7, (index) => DropdownMenuItem(
                value: index + 1,
                child: Text(SchedulePageLabels.weekdays[index]),
              )),
              onChanged: (value) => setState(() => _weekday = value!),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _timeButton('เวลาเริ่ม', _startTime, () => _pickTime(start: true))),
              const SizedBox(width: 12),
              Expanded(child: _timeButton('เวลาเลิก', _endTime, () => _pickTime(start: false))),
            ]),
            const SizedBox(height: 12),
            _textField(_courseName, 'ชื่อวิชา', required: true),
            _textField(_courseCode, 'รหัสวิชา'),
            _textField(_room, 'ห้องเรียน'),
            _textField(_section, 'Section'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator()) : const Icon(Icons.save),
              label: const Text('บันทึกตารางเรียน'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeButton(String label, TimeOfDay? time, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text('$label\n${time == null ? 'เลือกเวลา' : time.format(context)}'),
    );
  }

  Widget _textField(TextEditingController controller, String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: required ? (value) => value == null || value.trim().isEmpty ? 'กรุณากรอก$label' : null : null,
      ),
    );
  }
}

class SchedulePageLabels {
  static const weekdays = ['จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์'];
}

String _formatMinutes(int minutes) {
  final hour = minutes ~/ 60;
  final minute = minutes % 60;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
