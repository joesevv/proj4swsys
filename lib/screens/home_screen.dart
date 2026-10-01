import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/board.dart';
import '../services/auth_service.dart';
import '../services/board_service.dart';
import '../services/write_service.dart';
import 'board_screen.dart';

/// lists users board, create and join button at bottom
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BoardService _boards = BoardService();
  late final WriteService _writer;

  /// AuthGate only shows this screen while someone is signed in.
  String get _uid => widget.auth.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _writer = WriteService(uid: _uid, name: widget.auth.currentName);
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openBoard(Board board) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => BoardScreen(board: board, auth: widget.auth)),
    );
  }

  /// return the text or null when cancelled or left empty.
  Future<String?> _askText({
    required String title,
    required String label,
    required String action,
    required int maxLength,
    bool uppercase = false,
  }) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: maxLength,
          textCapitalization: uppercase ? TextCapitalization.characters : TextCapitalization.sentences,
          decoration: InputDecoration(labelText: label),
          onSubmitted: (_) => Navigator.pop(ctx, controller.text),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: Text(action)),
        ],
      ),
    );
    final trimmed = text?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _createBoard() async {
    final name = await _askText(title: 'Create board', label: 'Board name', action: 'Create', maxLength: 50);
    if (name == null) return;
    try {
      final code = await _writer.createBoard(name);
      final board = Board(id: code, name: name, members: [_uid], createdBy: _uid);
      if (mounted) await _showCode(board);
    } catch (e) {
      _snack('$e');
    }
  }

  Future<void> _showCode(Board board) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('"${board.name}" created'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Share this code so others can join:'),
          const SizedBox(height: 12),
          SelectableText(
            board.code,
            style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(letterSpacing: 4),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.copy),
          label: const Text('Copy'),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: board.code));
            _snack('Code copied');
          },
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            _openBoard(board);
          },
          child: const Text('Open board'),
        ),
      ],
    ),
  );

  Future<void> _joinBoard() async {
    final code = await _askText(
      title: 'Join board',
      label: '6-character code',
      action: 'Join',
      maxLength: WriteService.codeLength,
      uppercase: true,
    );
    if (code == null) return;
    try {
      final boardId = await _writer.joinBoard(code.toUpperCase());
      final board = await _boards.board(boardId);
      if (mounted) _openBoard(board);
    } catch (e) {
      _snack('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Boards'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(widget.auth.currentName),
            ),
          ),
          IconButton(tooltip: 'Sign out', icon: const Icon(Icons.logout), onPressed: widget.auth.signOut),
        ],
      ),
      body: StreamBuilder<List<Board>>(
        stream: _boards.myBoards(_uid),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Could not load boards: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final boards = snap.data!;
          if (boards.isEmpty) {
            return const Center(child: Text('No boards yet. Create one or join with a code.'));
          }
          return ListView.builder(
            itemCount: boards.length,
            itemBuilder: (context, i) {
              final board = boards[i];
              return ListTile(
                leading: const Icon(Icons.dashboard_outlined),
                title: Text(board.name),
                subtitle: Text('Code: ${board.code}'),
                onTap: () => _openBoard(board),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _createBoard,
                  icon: const Icon(Icons.add),
                  label: const Text('Create board'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _joinBoard,
                  icon: const Icon(Icons.group_add),
                  label: const Text('Join board'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
