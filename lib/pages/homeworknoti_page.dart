import 'package:flutter/material.dart';
import 'package:nisit_hub/widgets/responsive_page.dart';
import 'package:intl/intl.dart';

import '../models/deadline_record.model.dart';
import '../services/deadline_service.dart';
import '../services/notification_service.dart';

class HomeworkNotiPage extends StatelessWidget {
	const HomeworkNotiPage({super.key});

	@override
	Widget build(BuildContext context) {
		return ResponsiveScaffold(
			appBar: AppBar(
				title: const Text('งานที่ต้องส่ง'),
				actions: [
					IconButton(
						tooltip: 'ทดสอบการแจ้งเตือน',
						icon: const Icon(Icons.notifications_active_outlined),
						onPressed: () async {
							try {
								await NotificationService.instance.showTestNotification();
								if (context.mounted) {
									ScaffoldMessenger.of(context).showSnackBar(
										const SnackBar(content: Text('ส่งการแจ้งเตือนทดสอบแล้ว')),
									);
								}
							} catch (error) {
								if (context.mounted) {
									ScaffoldMessenger.of(context).showSnackBar(
										SnackBar(content: Text('ทดสอบการแจ้งเตือนไม่สำเร็จ: $error')),
									);
								}
							}
						},
					),
				],
			),
			body: StreamBuilder<List<DeadlineRecord>>(
				stream: DeadlineService().watchDeadlines(),
				builder: (context, snapshot) {
					if (snapshot.hasError) {
						return Center(child: Text('โหลดรายการงานไม่สำเร็จ\n${snapshot.error}'));
					}
					if (!snapshot.hasData) {
						return const Center(child: CircularProgressIndicator());
					}
					final records = snapshot.data!;
					if (records.isEmpty) {
						return const Center(child: Text('ยังไม่มีงานที่ต้องส่ง\nกด + เพื่อเพิ่มงานใหม่', textAlign: TextAlign.center));
					}
					return ListView.builder(
						padding: const EdgeInsets.all(16),
						itemCount: records.length,
						itemBuilder: (context, index) => _DeadlineCard(record: records[index]),
					);
				},
			),
			floatingActionButton: FloatingActionButton.extended(
				onPressed: () => Navigator.of(context).push(
					MaterialPageRoute(builder: (_) => const AddHomeworkPage()),
				),
				icon: const Icon(Icons.add),
				label: const Text('เพิ่มงาน'),
			),
		);
	}
}

class _DeadlineCard extends StatelessWidget {
	const _DeadlineCard({required this.record});

	final DeadlineRecord record;

	Future<void> _delete(BuildContext context) async {
		final confirmed = await showDialog<bool>(
			context: context,
			builder: (dialogContext) => AlertDialog(
				title: const Text('ลบงานนี้?'),
				content: Text('ต้องการลบ "${record.title}" หรือไม่'),
				actions: [
					TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('ยกเลิก')),
					FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('ลบ')),
				],
			),
		);
		if (confirmed == true && record.id != null) {
			await NotificationService.instance.cancelFor(record.notificationId);
			await DeadlineService().deleteDeadline(record.id!);
		}
	}

	Future<void> _toggleCompleted() async {
		if (record.id == null) return;
		await DeadlineService().updateDeadline(
			record.id!,
			record.copyWith(completed: !record.completed),
		);
	}

	@override
	Widget build(BuildContext context) {
		final overdue = !record.completed && record.deadline.isBefore(DateTime.now());
		final color = record.completed ? Colors.green : overdue ? Colors.red : Colors.orange;
		return Card(
			margin: const EdgeInsets.only(bottom: 12),
			child: Column(
				children: [
					ListTile(
						leading: Checkbox(
							value: record.completed,
							onChanged: record.id == null ? null : (_) => _toggleCompleted(),
						),
						title: Text(
							record.title,
							style: TextStyle(fontWeight: FontWeight.bold, decoration: record.completed ? TextDecoration.lineThrough : null),
						),
						subtitle: Text(
							'${record.subject.isEmpty ? 'ไม่ระบุวิชา' : record.subject}\nส่งภายใน ${DateFormat('d/M/yyyy HH:mm').format(record.deadline)}\n${record.completed ? 'ส่งแล้ว' : overdue ? 'เลยกำหนดส่ง' : _remainingText(record.deadline)}',
							style: TextStyle(color: color),
						),
						isThreeLine: true,
						trailing: PopupMenuButton<String>(
							onSelected: (value) {
								if (value == 'edit') {
									Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddHomeworkPage(record: record)));
								} else {
									_delete(context);
								}
							},
							itemBuilder: (_) => const [
								PopupMenuItem(value: 'edit', child: Text('แก้ไข')),
								PopupMenuItem(value: 'delete', child: Text('ลบ')),
							],
						),
					),
					Padding(
						padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
						child: SizedBox(
							width: double.infinity,
							child: OutlinedButton.icon(
								onPressed: record.id == null ? null : _toggleCompleted,
								icon: Icon(record.completed ? Icons.undo : Icons.check),
								label: Text(record.completed ? 'ทำเป็นยังไม่เสร็จ' : 'เสร็จสิ้น'),
							),
						),
					),
				],
			),
		);
	}
}

String _remainingText(DateTime deadline) {
	final days = deadline.difference(DateTime.now()).inDays;
	if (days == 0) return 'ครบกำหนดภายในวันนี้';
	if (days == 1) return 'เหลืออีก 1 วัน';
	return 'เหลืออีก $days วัน';
}

class AddHomeworkPage extends StatefulWidget {
	const AddHomeworkPage({super.key, this.record});

	final DeadlineRecord? record;

	@override
	State<AddHomeworkPage> createState() => _AddHomeworkPageState();
}

class _AddHomeworkPageState extends State<AddHomeworkPage> {
	final _formKey = GlobalKey<FormState>();
	final _title = TextEditingController();
	final _subject = TextEditingController();
	final _description = TextEditingController();
	DateTime _deadline = DateTime.now().add(const Duration(days: 3));
	bool _saving = false;

	bool get _isEditing => widget.record != null;

	@override
	void initState() {
		super.initState();
		final record = widget.record;
		if (record == null) return;
		_title.text = record.title;
		_subject.text = record.subject;
		_description.text = record.description;
		_deadline = record.deadline;
	}

	@override
	void dispose() {
		_title.dispose();
		_subject.dispose();
		_description.dispose();
		super.dispose();
	}

	Future<void> _pickDeadline() async {
		final date = await showDatePicker(
			context: context,
			firstDate: DateTime.now(),
			lastDate: DateTime.now().add(const Duration(days: 3650)),
			initialDate: _deadline.isBefore(DateTime.now()) ? DateTime.now() : _deadline,
		);
		if (date == null || !mounted) return;
		final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_deadline));
		if (time == null) return;
		setState(() => _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute));
	}

	Future<void> _save() async {
		if (!_formKey.currentState!.validate()) return;
		if (!_isEditing && !_deadline.isAfter(DateTime.now())) {
			_showMessage('กรุณาเลือก deadline ที่ยังไม่ผ่านไป');
			return;
		}
		setState(() => _saving = true);
		try {
			final record = DeadlineRecord(
				id: widget.record?.id,
				title: _title.text.trim(),
				subject: _subject.text.trim(),
				description: _description.text.trim(),
				deadline: _deadline,
				completed: widget.record?.completed ?? false,
				notificationId: widget.record?.notificationId ?? DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
			);
			if (_isEditing) {
				await DeadlineService().updateDeadline(widget.record!.id!, record);
			} else {
				await DeadlineService().addDeadline(record);
			}
			await NotificationService.instance.scheduleFor(record);
			if (mounted) Navigator.pop(context);
		} catch (error) {
			_showMessage('บันทึกไม่สำเร็จ: $error');
		} finally {
			if (mounted) setState(() => _saving = false);
		}
	}

	void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

	@override
	Widget build(BuildContext context) {
		return ResponsiveScaffold(
			appBar: AppBar(title: Text(_isEditing ? 'แก้ไขงาน' : 'เพิ่มงานที่ต้องส่ง')),
			body: Form(
				key: _formKey,
				child: ListView(
					padding: const EdgeInsets.all(20),
					children: [
						_field(_title, 'ชื่องาน', required: true),
						_field(_subject, 'วิชา'),
						_field(_description, 'รายละเอียดเพิ่มเติม', maxLines: 3),
						const SizedBox(height: 8),
						OutlinedButton.icon(
							onPressed: _pickDeadline,
							icon: const Icon(Icons.event_outlined),
							label: Text('กำหนดส่ง: ${DateFormat('d/M/yyyy HH:mm').format(_deadline)}'),
						),
						const SizedBox(height: 20),
						FilledButton.icon(
							onPressed: _saving ? null : _save,
							icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator()) : const Icon(Icons.save_outlined),
							label: Text(_isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มงาน'),
						),
						const SizedBox(height: 12),
						const Text('ระบบจะแจ้งเตือนก่อนกำหนดส่ง 2 วัน และ 1 วัน', textAlign: TextAlign.center),
					],
				),
			),
		);
	}

	Widget _field(TextEditingController controller, String label, {bool required = false, int maxLines = 1}) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 12),
			child: TextFormField(
				controller: controller,
				maxLines: maxLines,
				decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
				validator: required ? (value) => value == null || value.trim().isEmpty ? 'กรุณากรอก$label' : null : null,
			),
		);
	}
}
