import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/playlist_service.dart';

class PlaylistCreationSheet extends StatefulWidget {
  const PlaylistCreationSheet({super.key});

  // 🔥 helper to show the sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PlaylistCreationSheet(),
    );
  }

  @override
  State<PlaylistCreationSheet> createState() =>
      _PlaylistCreationSheetState();
}

class _PlaylistCreationSheetState extends State<PlaylistCreationSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _createPlaylist() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    // TODO: hook ObjectBox here
    PlaylistService().createPlaylist(name);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.32,
        decoration: const BoxDecoration(
          color: Color(0xFFFFE695),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            _header(),
            _buildInput(),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  // ───────────────── UI PARTS ─────────────────

  Widget _handle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFF342E1B),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Text(
            'Create a playlist',
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.w500,
              fontSize: 26,
              color: const Color(0xFF342E1B),
            ),
          ),
          const Spacer(),
          ClipOval(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    CupertinoIcons.chevron_down,
                    size: 24,
                    color: Color(0xFF342E1B),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        style: GoogleFonts.rubik(
          fontSize: 18,
          color: const Color(0xFF342E1B),
        ),
        decoration: InputDecoration(
          labelText: 'Name e.g Fav, Sad...',
          labelStyle: GoogleFonts.rubik(
            color: const Color(0xFF342E1B),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF342E1B),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF342E1B),
              width: 2,
            ),
          ),
        ),
        onSubmitted: (_) => _createPlaylist(),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: const Color(0xFF342E1B),
            child: InkWell(
              onTap: _createPlaylist,
              splashColor:
              Colors.white.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Add',
                    style: GoogleFonts.rubik(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
