import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_profile.dart';

class RegisterFormData {
	const RegisterFormData({
		required this.firstName,
		required this.lastName,
		required this.nickname,
		required this.birthDate,
		required this.email,
		required this.password,
		required this.phone,
	});

	final String firstName;
	final String lastName;
	final String nickname;
	final DateTime birthDate;
	final String email;
	final String password;
	final String phone;

	UserProfile toProfile() => UserProfile(
				firstName: firstName,
				lastName: lastName,
				nickname: nickname,
				birthDate: birthDate,
				email: email,
				phone: phone,
			);
}

class RegisterForm extends StatefulWidget {
	const RegisterForm({super.key, required this.onSubmit, required this.isLoading});

	final Future<void> Function(RegisterFormData data) onSubmit;
	final bool isLoading;

	@override
	State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
	final _formKey = GlobalKey<FormState>();
	final _firstName = TextEditingController();
	final _lastName = TextEditingController();
	final _nickname = TextEditingController();
	final _email = TextEditingController();
	final _password = TextEditingController();
	final _phone = TextEditingController();
	DateTime? _birthDate;
	bool _hasSubmitted = false;

	@override
	void dispose() {
		for (final controller in [_firstName, _lastName, _nickname, _email, _password, _phone]) {
			controller.dispose();
		}
		super.dispose();
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

	String? _required(String? value, String message) =>
		value == null || value.trim().isEmpty ? message : null;

	String? _validateEmail(String? value) {
		final requiredMessage = _required(value, 'กรุณากรอก Email');
		if (requiredMessage != null) return requiredMessage;
		final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
		return emailPattern.hasMatch(value!.trim())
			? null
			: 'กรุณากรอก Email ให้ถูกต้อง เช่น name@example.com';
	}

	String? _validatePhone(String? value) {
		final requiredMessage = _required(value, 'กรุณากรอกเบอร์โทร');
		if (requiredMessage != null) return requiredMessage;
		return RegExp(r'^0[0-9]{9}$').hasMatch(value!)
			? null
			: 'กรุณากรอกเบอร์โทรให้ถูกต้อง (ตัวเลข 10 หลัก และขึ้นต้นด้วย 0)';
	}

	String? _validatePassword(String? value) {
		final requiredMessage = _required(value, 'กรุณากรอกรหัสผ่าน');
		if (requiredMessage != null) return requiredMessage;
		final password = value!;
		final missingConditions = <String>[];
		if (password.length < 8) {
			missingConditions.add('ตัวอักษรอย่างน้อย 8 ตัว');
		}
		if (!RegExp(r'[A-Z]').hasMatch(password)) {
			missingConditions.add('ตัวพิมพ์ใหญ่อย่างน้อย 1 ตัว');
		}
		if (!RegExp(r'[a-z]').hasMatch(password)) {
			missingConditions.add('ตัวพิมพ์เล็กอย่างน้อย 1 ตัว');
		}
		if (!RegExp(r'[@#!_\-]').hasMatch(password)) {
			missingConditions.add('ตัวอักษรพิเศษอย่างน้อย 1 ตัว');
		}
		if (!RegExp(r'[0-9]').hasMatch(password)) {
			missingConditions.add('ตัวเลขอย่างน้อย 1 ตัว');
		}
		if (missingConditions.isEmpty) return null;
		return 'รหัสผ่านจะต้องมี :\n${missingConditions.map((condition) => '- $condition').join('\n')}';
	}

	Future<void> _submit() async {
		setState(() => _hasSubmitted = true);
		if (!_formKey.currentState!.validate()) return;
		if (_birthDate == null) {
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาเลือกวันเกิด')));
			return;
		}
		await widget.onSubmit(RegisterFormData(
			firstName: _firstName.text,
			lastName: _lastName.text,
			nickname: _nickname.text,
			birthDate: _birthDate!,
			email: _email.text,
			password: _password.text,
			phone: _phone.text,
		));
	}

	@override
	Widget build(BuildContext context) {
		return Form(
			key: _formKey,
			autovalidateMode: _hasSubmitted
				? AutovalidateMode.onUserInteraction
				: AutovalidateMode.disabled,
			child: Column(
				children: [
					_field(_firstName, 'ชื่อจริง', 'กรุณากรอกชื่อจริง'),
					_field(_lastName, 'นามสกุล', 'กรุณากรอกนามสกุล'),
					_field(_nickname, 'ชื่อเล่น', 'กรุณากรอกชื่อเล่น'),
					TextFormField(
						readOnly: true,
						controller: TextEditingController(text: _birthDate == null ? '' : DateFormat('dd/MM/yyyy').format(_birthDate!)),
						decoration: const InputDecoration(labelText: 'วันเดือนปีเกิด', suffixIcon: Icon(Icons.calendar_month)),
						onTap: _pickBirthDate,
						validator: (_) => _birthDate == null ? 'กรุณาเลือกวันเดือนปีเกิด' : null,
					),
					_field(
						_email,
						'Email',
						'กรุณากรอก Email',
						keyboardType: TextInputType.emailAddress,
						validator: _validateEmail,
					),
					_field(
						_phone,
						'เบอร์โทร',
						'กรุณากรอกเบอร์โทร',
						keyboardType: TextInputType.phone,
						validator: _validatePhone,
					),
					_field(
						_password,
						'รหัสผ่าน',
						'กรุณากรอกรหัสผ่าน',
						obscureText: true,
						validator: _validatePassword,
					),
					const SizedBox(height: 24),
					SizedBox(
						width: double.infinity,
						child: FilledButton(
							onPressed: widget.isLoading ? null : _submit,
							child: widget.isLoading ? const CircularProgressIndicator() : const Text('สมัครสมาชิก'),
						),
					),
				],
			),
		);
	}

	Widget _field(
		TextEditingController controller,
		String label,
		String requiredMessage, {
		TextInputType? keyboardType,
		bool obscureText = false,
		String? Function(String?)? validator,
	}) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 16),
			child: TextFormField(
				controller: controller,
				keyboardType: keyboardType,
				obscureText: obscureText,
				decoration: InputDecoration(labelText: label),
				validator: validator ?? (value) => _required(value, requiredMessage),
			),
		);
	}
}
