import 'package:flutter/material.dart';
import 'package:nisit_hub/widgets/responsive_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/authentication_service.dart';
import '../widgets/register_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;

  Future<void> _register(RegisterFormData data) async {
    setState(() => _isLoading = true);
    try {
      final success = await AuthenticationService().register(
        email: data.email,
        password: data.password,
        firstName: data.firstName,
        lastName: data.lastName,
        nickname: data.nickname,
        phoneNumber: data.phone,
        birthDate: data.birthDate,
      );
      if (!success) throw StateError('ไม่สามารถสร้างบัญชีได้');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('สมัครสมาชิกสำเร็จ')));
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'email-already-in-use' => 'อีเมลนี้ถูกใช้งานแล้ว',
        'weak-password' => 'รหัสผ่านไม่ปลอดภัยเพียงพอ',
        'invalid-email' => 'รูปแบบอีเมลไม่ถูกต้อง',
        _ => 'สมัครสมาชิกไม่สำเร็จ (${error.code})',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseException catch (error) {
      if (!mounted) return;
      final message = error.code == 'permission-denied'
          ? 'ไม่มีสิทธิ์บันทึกข้อมูล โปรดตรวจสอบ Firestore Rules'
          : 'บันทึกข้อมูลไม่สำเร็จ (${error.code})';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลไม่สำเร็จ กรุณาลองใหม่')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9D9D9),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('สมัครสมาชิก'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
          child: RegisterForm(onSubmit: _register, isLoading: _isLoading),
        ),
      ),
    );
  }
}
