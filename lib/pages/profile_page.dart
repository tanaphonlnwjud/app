import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _nickname = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  DateTime? _birthDate;
  bool _editing = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  DocumentReference<Map<String, dynamic>>? get _profileReference {
    final user = _auth.currentUser;
    return user == null ? null : _firestore.collection('users').doc(user.uid);
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _nickname.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final reference = _profileReference;
    final authUser = _auth.currentUser;
    if (reference == null || authUser == null) {
      setState(() {
        _loading = false;
        _error = 'กรุณาเข้าสู่ระบบก่อน';
      });
      return;
    }

    try {
      final snapshot = await reference.get();
      final data = snapshot.data() ?? <String, dynamic>{};
      _firstName.text = data['firstName'] as String? ?? '';
      _lastName.text = data['lastName'] as String? ?? '';
      _nickname.text = data['nickname'] as String? ?? '';
      _email.text = data['email'] as String? ?? authUser.email ?? '';
      _phone.text = data['phoneNumber'] as String? ?? data['phone'] as String? ?? '';
      final birthDate = data['birthDate'];
      _birthDate = birthDate is Timestamp ? birthDate.toDate() : null;
    } catch (error) {
      _error = 'โหลดข้อมูลไม่สำเร็จ: $error';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final reference = _profileReference;
    if (reference == null) return;
    setState(() => _saving = true);
    try {
      await reference.set({
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'nickname': _nickname.text.trim(),
        'email': _email.text.trim(),
        'phoneNumber': _phone.text.trim(),
        if (_birthDate != null) 'birthDate': Timestamp.fromDate(_birthDate!),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลแล้ว')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('บันทึกไม่สำเร็จ: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: _birthDate ?? DateTime(2000),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _editing ? 'บันทึก' : 'แก้ไขโปรไฟล์',
            onPressed: _loading || _saving ? null : (_editing ? _saveProfile : () => setState(() => _editing = true)),
            icon: Icon(_editing ? Icons.check : Icons.edit),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, textAlign: TextAlign.center))
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                    children: [
                      const _ProfileAvatar(),
                      const SizedBox(height: 28),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final twoColumns = constraints.maxWidth >= 430;
                          final fields = [
                            _field('First Name', _firstName),
                            _field('Last Name', _lastName),
                            _field('Nickname', _nickname),
                            _field('Email', _email, enabled: false),
                            _field('Phone', _phone),
                            _birthDateField(),
                          ];
                          return twoColumns
                              ? Wrap(spacing: 16, runSpacing: 14, children: fields.map((field) => SizedBox(width: (constraints.maxWidth - 16) / 2, child: field)).toList())
                              : Column(children: fields);
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _field(String label, TextEditingController controller, {bool enabled = true}) {
    return TextFormField(
      controller: controller,
      enabled: _editing && enabled,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        labelStyle: const TextStyle(color: Colors.black),
        border: const OutlineInputBorder(borderSide: BorderSide.none),
      ),
      validator: (value) => label == 'First Name' && (value == null || value.trim().isEmpty) ? 'กรุณากรอกชื่อ' : null,
    );
  }

  Widget _birthDateField() {
    return TextFormField(
      readOnly: true,
      enabled: _editing,
      onTap: _editing ? _pickBirthDate : null,
      controller: TextEditingController(text: _birthDate == null ? '' : DateFormat('dd/MM/yyyy').format(_birthDate!)),
      style: const TextStyle(color: Colors.black),
      decoration: const InputDecoration(
        labelText: 'Birth-Date',
        filled: true,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 142,
        height: 142,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 6)),
        child: const Icon(Icons.person_outline, size: 108, color: Colors.black),
      ),
    );
  }
}
