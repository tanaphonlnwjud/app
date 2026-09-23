import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/lost_found_post.dart';
import '../services/lost_found_service.dart';
import 'add_lost_found_page.dart';

class LostFoundPage extends StatelessWidget {
  const LostFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = LostFoundService();
    return Scaffold(
      appBar: AppBar(title: const Text('ของหายและพบของ')),
      body: StreamBuilder<List<LostFoundPost>>(
        stream: service.watchPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('โหลดรายการไม่สำเร็จ\n${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final posts = snapshot.data!;
          if (posts.isEmpty) {
            return const Center(child: Text('ยังไม่มีประกาศของหายหรือพบของ'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: posts.length,
            itemBuilder: (context, index) => _LostFoundCard(
              post: posts[index],
              service: service,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddLostFoundPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('โพสต์ประกาศ'),
      ),
    );
  }
}

class _LostFoundCard extends StatelessWidget {
  const _LostFoundCard({required this.post, required this.service});

  final LostFoundPost post;
  final LostFoundService service;

  bool get _isOwner => FirebaseAuth.instance.currentUser?.uid == post.authorId;

  String get _typeLabel => post.type == LostFoundType.lost ? 'ของหาย' : 'พบของ';

  String get _statusLabel => post.status == LostFoundStatus.found ? 'พบแล้ว' : 'ยังไม่พบ';

  Future<void> _showDetails(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(post.title),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('ประเภท: $_typeLabel'),
              Text('สถานะ: $_statusLabel'),
              Text('วันที่: ${DateFormat('d/M/yyyy').format(post.date)}'),
              Text('สถานที่: ${post.location}'),
              const SizedBox(height: 12),
              Text(post.description.isEmpty ? 'ไม่มีรายละเอียดเพิ่มเติม' : post.description),
            ],
          ),
        ),
        actions: [
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showComments(context);
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('คอมเมนต์บอกเบาะแส'),
          ),
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('ปิด')),
        ],
      ),
    );
  }

  Future<void> _showComments(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LostFoundCommentsSheet(post: post, service: service),
    );
  }

  Future<void> _changeStatus(BuildContext context) async {
    final status = post.status == LostFoundStatus.found
        ? LostFoundStatus.searching
        : LostFoundStatus.found;
    try {
      await service.updateStatus(post.id, status);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('แก้สถานะไม่สำเร็จ: $error')),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ลบประกาศนี้?'),
        content: Text('ต้องการลบประกาศ "${post.title}" หรือไม่'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('ยกเลิก')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('ลบ')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await service.deletePost(post.id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบไม่สำเร็จ: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(post.type == LostFoundType.lost ? Icons.search : Icons.inventory_2_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    post.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Chip(label: Text(_statusLabel)),
                if (_isOwner)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'status') _changeStatus(context);
                      if (value == 'delete') _delete(context);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'status', child: Text('เปลี่ยนสถานะ')),
                      PopupMenuItem(value: 'delete', child: Text('ลบประกาศ')),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text('สถานที่: ${post.location}'),
            Text('วันที่: ${DateFormat('d/M/yyyy').format(post.date)}'),
            Text('ผู้โพสต์: ${post.alias}'),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showDetails(context),
                icon: const Icon(Icons.info_outline),
                label: const Text('ดูรายละเอียดเพิ่มเติม'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LostFoundCommentsSheet extends StatefulWidget {
  const _LostFoundCommentsSheet({required this.post, required this.service});

  final LostFoundPost post;
  final LostFoundService service;

  @override
  State<_LostFoundCommentsSheet> createState() => _LostFoundCommentsSheetState();
}

class _LostFoundCommentsSheetState extends State<_LostFoundCommentsSheet> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await widget.service.addComment(widget.post.id, content);
      _controller.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ส่งคอมเมนต์ไม่สำเร็จ: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('คอมเมนต์: ${widget.post.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: widget.service.watchComments(widget.post.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text('โหลดคอมเมนต์ไม่สำเร็จ\n${snapshot.error}'));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  if (snapshot.data!.docs.isEmpty) return const Center(child: Text('ยังไม่มีคอมเมนต์'));
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: snapshot.data!.docs.map((document) {
                      final data = document.data();
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                        title: Text(data['alias'] as String? ?? 'ผู้ใช้นิรนาม'),
                        subtitle: Text(data['content'] as String? ?? ''),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.viewInsetsOf(context).bottom + 8),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: _controller, maxLength: 300, decoration: const InputDecoration(hintText: 'เขียนเบาะแสหรือความคิดเห็น...'))),
                  IconButton(onPressed: _sending ? null : _send, icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
