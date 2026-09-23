import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/community_post.dart';
import '../services/community_service.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _service = CommunityService();
  int _tab = 0;

  Future<void> _createPost() async {
    final controller = TextEditingController();
    final content = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('สร้างโพสต์นิรนาม'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(hintText: 'เล่าเรื่องที่อยากพูดคุย...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('ยกเลิก')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text), child: const Text('โพสต์')),
        ],
      ),
    );
    controller.dispose();
    if (content == null || content.trim().isEmpty) return;
    try {
      await _service.addPost(content);
    } catch (error) {
      if (mounted) _showMessage('โพสต์ไม่สำเร็จ: $error');
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ชุมชน')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('โพสต์ล่าสุด'), icon: Icon(Icons.schedule)),
                ButtonSegment(value: 1, label: Text('ติดเทรน'), icon: Icon(Icons.trending_up)),
              ],
              selected: {_tab},
              onSelectionChanged: (selected) => setState(() => _tab = selected.first),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CommunityPost>>(
              stream: _service.watchPosts(trending: _tab == 1),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('โหลดโพสต์ไม่สำเร็จ\n${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.isEmpty) return const Center(child: Text('ยังไม่มีโพสต์\nกด + เพื่อเริ่มพูดคุย', textAlign: TextAlign.center));
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (_, index) => _PostCard(post: snapshot.data![index], service: _service),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPost,
        tooltip: 'สร้างโพสต์',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.service});

  final CommunityPost post;
  final CommunityService service;

  bool get _isOwner => FirebaseAuth.instance.currentUser?.uid == post.authorId;

  String _relativeTime() {
    final difference = DateTime.now().difference(post.createdAt);
    if (difference.inMinutes < 1) return 'เมื่อสักครู่นี้';
    if (difference.inHours < 1) return '${difference.inMinutes} นาทีที่แล้ว';
    if (difference.inDays < 1) return '${difference.inHours} ชั่วโมงที่แล้ว';
    return DateFormat('d/M/yyyy HH:mm').format(post.createdAt);
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ลบโพสต์นี้?'),
        content: const Text('ต้องการลบโพสต์นี้หรือไม่'),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ลบไม่สำเร็จ: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const CircleAvatar(child: Icon(Icons.person_outline)),
              const SizedBox(width: 10),
              Expanded(child: Text('${post.alias}\n${_relativeTime()}', style: const TextStyle(fontSize: 13))),
              if (_isOwner)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') _delete(context);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'delete', child: Text('ลบโพสต์')),
                  ],
                ),
            ]),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(post.content, style: const TextStyle(fontSize: 16))),
            Row(children: [
              StreamBuilder<bool>(
                stream: service.watchLiked(post.id),
                builder: (context, snapshot) {
                  final liked = snapshot.data ?? false;
                  return TextButton.icon(
                    onPressed: () => service.toggleLike(post.id, liked),
                    icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.red : null),
                    label: Text('${post.likesCount}'),
                  );
                },
              ),
              TextButton.icon(
                onPressed: () => showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => _CommentsSheet(post: post, service: service)),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text('${post.commentsCount}'),
              ),
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined), label: Text('${post.sharesCount}')),
            ]),
          ],
        ),
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.post, required this.service});
  final CommunityPost post;
  final CommunityService service;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await widget.service.addComment(widget.post.id, text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .7,
        child: Column(children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('ความคิดเห็น', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: widget.service.watchComments(widget.post.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data();
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
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'เขียนความคิดเห็น...'))),
              IconButton(onPressed: _send, icon: const Icon(Icons.send)),
            ]),
          ),
        ]),
      ),
    );
  }
}