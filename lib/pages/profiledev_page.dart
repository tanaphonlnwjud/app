import 'package:flutter/material.dart';
import 'package:nisit_hub/widgets/responsive_page.dart';

class DevProfilePage extends StatefulWidget {
  const DevProfilePage({super.key});

  @override
  State<DevProfilePage> createState() => _DevProfilePageState();
}

class _DevProfilePageState extends State<DevProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _studentIdController1 = TextEditingController(text: '6721602415');
  final _nameController1 = TextEditingController(text: 'นายธนพนธ์ โถแก้ว');
  final _numberController1 = TextEditingController(text: '14');
  final _classController1 = TextEditingController(text: '700');

  final _studentIdController2 = TextEditingController(text: '6721602563');
  final _nameController2 = TextEditingController(text: 'นายรชต ไชยปัญญา');
  final _numberController2 = TextEditingController(text: '27');
  final _classController2 = TextEditingController(text: '700');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _studentIdController1.dispose();
    _nameController1.dispose();
    _numberController1.dispose();
    _classController1.dispose();
    _studentIdController2.dispose();
    _nameController2.dispose();
    _numberController2.dispose();
    _classController2.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์ผู้สร้าง'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              final profileCards = [
                _ProfileCard(
                  title: 'คนที่ 1',
                  studentIdController: _studentIdController1,
                  nameController: _nameController1,
                  numberController: _numberController1,
                  classController: _classController1,
                ),
                _ProfileCard(
                  title: 'คนที่ 2',
                  studentIdController: _studentIdController2,
                  nameController: _nameController2,
                  numberController: _numberController2,
                  classController: _classController2,
                ),
              ];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: profileCards[0]),
                          const SizedBox(width: 20),
                          Expanded(child: profileCards[1]),
                        ],
                      )
                    : Column(
                        children: profileCards
                            .map((card) => Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: card,
                                ))
                            .toList(),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.title,
    required this.studentIdController,
    required this.nameController,
    required this.numberController,
    required this.classController,
  });

  final String title;
  final TextEditingController studentIdController;
  final TextEditingController nameController;
  final TextEditingController numberController;
  final TextEditingController classController;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'รหัสนิสิต',
              controller: studentIdController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'ชื่อ-นามสกุล',
              controller: nameController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'เลขที่',
              controller: numberController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'หมู่เรียน',
              controller: classController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: false,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
        hintStyle: const TextStyle(color: Colors.black),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}