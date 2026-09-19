import 'package:flutter/material.dart';
import '../services/openai_chat_service.dart';

class AIPage extends StatefulWidget {
	const AIPage({super.key});

	@override
	State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
	final TextEditingController _messageController = TextEditingController();
	final ScrollController _scrollController = ScrollController();
	final OpenAIChatService _chatService = OpenAIChatService();
	final List<_ChatMessage> _messages = [
		const _ChatMessage(
			text: 'สวัสดีครับ ผมคือ Nisit Hub AI มีอะไรให้ช่วยไหมครับ',
			isUser: false,
		),
	];
	bool _isReplying = false;

	@override
	void dispose() {
		_messageController.dispose();
		_scrollController.dispose();
		super.dispose();
	}

	Future<void> _sendMessage() async {
		final text = _messageController.text.trim();
		if (text.isEmpty || _isReplying) return;

		setState(() {
			_messages.add(_ChatMessage(text: text, isUser: true));
			_messageController.clear();
			_isReplying = true;
		});
		_scrollToBottom();

		final conversation = _messages
				.map(
					(message) => {
						'role': message.isUser ? 'user' : 'assistant',
						'content': message.text,
					},
				)
				.toList();

		String reply;
		try {
			reply = await _chatService.sendMessage(conversation);
		} on OpenAIChatException catch (error) {
			reply = error.message;
		} catch (_) {
			reply = 'เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่อีกครั้ง';
		}
		if (!mounted) return;

		setState(() {
			_messages.add(_ChatMessage(text: reply, isUser: false));
			_isReplying = false;
		});
		_scrollToBottom();
	}

	void _scrollToBottom() {
		WidgetsBinding.instance.addPostFrameCallback((_) {
			if (!_scrollController.hasClients) return;
			_scrollController.animateTo(
				_scrollController.position.maxScrollExtent,
				duration: const Duration(milliseconds: 250),
				curve: Curves.easeOut,
			);
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Row(
					children: [
						Icon(Icons.smart_toy_outlined),
						SizedBox(width: 8),
						Text('Nisit Hub AI'),
					],
				),
			),
			body: Column(
				children: [
					Expanded(
						child: ListView.builder(
							controller: _scrollController,
							padding: const EdgeInsets.all(16),
							itemCount: _messages.length,
							itemBuilder: (context, index) {
								final message = _messages[index];
								return Align(
									alignment: message.isUser
											? Alignment.centerRight
											: Alignment.centerLeft,
									child: Container(
										constraints: const BoxConstraints(maxWidth: 500),
										margin: const EdgeInsets.only(bottom: 12),
										padding: const EdgeInsets.symmetric(
											horizontal: 50,
											vertical: 12,
										),
										decoration: BoxDecoration(
											color: message.isUser
													? Theme.of(context).colorScheme.primary
													: Theme.of(context).colorScheme.surfaceContainerHighest,
											borderRadius: BorderRadius.circular(16),
										),
										child: Text(
											message.text,
											style: TextStyle(
												color: message.isUser
														? Theme.of(context).colorScheme.onPrimary
														: Theme.of(context).colorScheme.onSurface,
											),
										),
									),
								);
							},
						),
					),
					if (_isReplying)
						const Padding(
							padding: EdgeInsets.only(left: 16, bottom: 8),
							child: Align(
								alignment: Alignment.centerLeft,
								child: Text('กำลังตอบกลับ...'),
							),
						),
					SafeArea(
						child: Padding(
							padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
							child: Row(
								crossAxisAlignment: CrossAxisAlignment.end,
								children: [
									Expanded(
										child: TextField(
											controller: _messageController,
											textInputAction: TextInputAction.send,
											minLines: 1,
											maxLines: 100,
											onSubmitted: (_) => _sendMessage(),
											decoration: const InputDecoration(
												hintText: 'พิมพ์ข้อความ...',
												border: OutlineInputBorder(),
											),
										),
									),
									const SizedBox(width: 8),
									IconButton.filled(
										onPressed: _isReplying ? null : _sendMessage,
										tooltip: 'ส่งข้อความ',
										icon: const Icon(Icons.send),
									),
								],
							),
						),
					),
				],
			),
		);
	}
}

class _ChatMessage {
	const _ChatMessage({required this.text, required this.isUser});

	final String text;
	final bool isUser;
}
