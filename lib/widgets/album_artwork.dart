import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../model/song.dart';
import '../services/artwork_service.dart';

class AlbumArtwork extends StatefulWidget {
  final Song song;
  final double size;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? nullIconColor;

  const AlbumArtwork({
    super.key,
    required this.song,
    this.size = 50,
    this.borderRadius,
    this.backgroundColor,
    this.nullIconColor = Colors.white,
  });

  @override
  State<AlbumArtwork> createState() => _AlbumArtworkState();
}

class _AlbumArtworkState extends State<AlbumArtwork> {
  Uint8List? _artwork;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  @override
  void didUpdateWidget(AlbumArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.filePath != widget.song.filePath) {
      _loadArtwork();
    }
  }

  Future<void> _loadArtwork() async {
    setState(() => _isLoading = true);

    // Check if song already has artwork
    if (widget.song.albumArt != null) {
      setState(() {
        _artwork = widget.song.albumArt;
        _isLoading = false;
      });
      return;
    }

    // Try to extract artwork
    final artwork = await ArtworkService.extractArtwork(widget.song.filePath);

    if (mounted) {
      setState(() {
        _artwork = artwork;
        widget.song.albumArt = artwork; // Cache it in the song
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? const Color(0xFF342E1B),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        child: _isLoading
            ? Center(
          child: SizedBox(
            width: widget.size * 0.4,
            height: widget.size * 0.4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.backgroundColor != null
                    ? Colors.white
                    : const Color(0xFFFFE695),
              ),
            ),
          ),
        )
            : _artwork != null
            ? Image.memory(
          _artwork!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.music_note_rounded,
      color: widget.nullIconColor!.withValues(alpha: 0.8),
      size: widget.size * 0.5,
    );
  }
}
