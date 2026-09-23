import 'package:flutter/material.dart';
import 'package:nisit_hub/widgets/responsive_page.dart';

import '../models/lost_found_post.dart';
import '../services/lost_found_service.dart';

class AddLostFoundPage extends StatefulWidget {
  const AddLostFoundPage({super.key});

  @override
  State<AddLostFoundPage> createState() => _AddLostFoundPageState();
}

class _AddLostFoundPageState extends State<AddLostFoundPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _service = LostFoundService();

  LostFoundType _type = LostFoundType.lost;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selected != null) setState(() => _date = selected);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _service.addPost(
        type: _type,
        title: _titleController.text,
        description: _descriptionController.text,
        date: _date,
        location: _locationController.text,
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกไม่สำเร็จ: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('โพสต์ของหาย / พบของ')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<LostFoundType>(
              segments: const [
                ButtonSegment(value: LostFoundType.lost, label: Text('ตามหาของหาย'), icon: Icon(Icons.search)),
                ButtonSegment(value: LostFoundType.found, label: Text('ตามหาเจ้าของ'), icon: Icon(Icons.inventory_2_outlined)),
              ],
              selected: {_type},
              onSelectionChanged: (selected) => setState(() => _type = selected.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'ชื่อสิ่งของ', border: OutlineInputBorder()),
              validator: (value) => value == null || value.trim().isEmpty ? 'กรุณาระบุชื่อสิ่งของ' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              maxLength: 120,
              decoration: const InputDecoration(labelText: 'สถานที่หาย / พบ', border: OutlineInputBorder()),
              validator: (value) => value == null || value.trim().isEmpty ? 'กรุณาระบุสถานที่' : null,
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('วันที่หาย / พบ'),
              subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
              trailing: OutlinedButton(onPressed: _pickDate, child: const Text('เลือกวันที่')),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLength: 500,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'รายละเอียดเพิ่มเติม', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.publish),
              label: Text(_saving ? 'กำลังบันทึก...' : 'โพสต์ประกาศ'),
            ),
          ],
        ),
      ),
    );
  }
}
