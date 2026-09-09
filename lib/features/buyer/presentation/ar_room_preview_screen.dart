import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../core/theme/app_colors.dart';

/// 2.5D AR Room Visualizer — places the artisan product image interactively
/// over the live camera feed so buyers can visualize it in their own room.
///
/// Gestures supported:
///   - [PanGesture]   → drag to reposition
///   - [ScaleGesture] → pinch to resize (two fingers)
///   - [RotateGesture] → two-finger twist to rotate
///
/// Capture → composes the live viewfinder + overlay into a PNG and shows
/// a share / save bottom sheet.
class ArRoomPreviewScreen extends StatefulWidget {
  /// Network URL (or empty string) of the product image.
  final String imageUrl;

  /// Display title of the product (shown in the top bar).
  final String productTitle;

  /// Optional estimated physical dimensions string, e.g. "~35 × 45 cm"
  final String? estimatedSize;

  const ArRoomPreviewScreen({
    super.key,
    required this.imageUrl,
    required this.productTitle,
    this.estimatedSize,
  });

  @override
  State<ArRoomPreviewScreen> createState() => _ArRoomPreviewScreenState();
}

class _ArRoomPreviewScreenState extends State<ArRoomPreviewScreen>
    with TickerProviderStateMixin {
  // ── Camera ──────────────────────────────────────────────────────
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _cameraPermissionDenied = false;

  // ── Product overlay transforms ───────────────────────────────────
  Offset _position = Offset.zero;
  double _scale = 1.0;
  double _rotation = 0.0;

  // Scale state during gesture
  double _baseScale = 1.0;
  double _baseRotation = 0.0;

  // Whether overlay has been placed (false = show placement hint)
  bool _isPlaced = false;

  // ── Capture ──────────────────────────────────────────────────────
  final GlobalKey _repaintKey = GlobalKey();
  bool _isCapturing = false;
  bool _showCaptureFlash = false;

  // ── Help overlay ─────────────────────────────────────────────────
  bool _showHelp = true;

  // ── Animation ────────────────────────────────────────────────────
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Camera Init ─────────────────────────────────────────────────
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) setState(() => _cameraPermissionDenied = true);
        return;
      }
      final backCam = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      final controller = CameraController(
        backCam,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _cameraController = controller;
      await controller.initialize();
      if (mounted) setState(() => _isCameraReady = true);
    } catch (_) {
      if (mounted) setState(() => _cameraPermissionDenied = true);
    }
  }

  // ── Gesture Handlers ─────────────────────────────────────────────
  void _onScaleStart(ScaleStartDetails details) {
    _baseScale = _scale;
    _baseRotation = _rotation;
    if (!_isPlaced) setState(() => _isPlaced = true);
    if (_showHelp) setState(() => _showHelp = false);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_baseScale * details.scale).clamp(0.2, 4.0);
      _rotation = _baseRotation + details.rotation;
      _position += details.focalPointDelta;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isPlaced) setState(() => _isPlaced = true);
    if (_showHelp) setState(() => _showHelp = false);
    setState(() => _position += details.delta);
  }

  void _resetTransform() {
    final size = MediaQuery.of(context).size;
    setState(() {
      _position = Offset(size.width / 2, size.height / 2);
      _scale = 1.0;
      _rotation = 0.0;
      _showHelp = false;
      _isPlaced = false;
    });
  }

  // ── Capture ──────────────────────────────────────────────────────
  Future<void> _captureSnapshot() async {
    if (_isCapturing) return;
    setState(() {
      _isCapturing = true;
      _showCaptureFlash = true;
    });

    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) setState(() => _showCaptureFlash = false);

    try {
      final boundary =
          _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/kala_ar_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        _showShareSheet(pngBytes, file.path);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not capture snapshot. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _showShareSheet(Uint8List pngBytes, String filePath) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SnapshotShareSheet(
        imageBytes: pngBytes,
        filePath: filePath,
        productTitle: widget.productTitle,
      ),
    );
  }

  // ── Flip Camera ──────────────────────────────────────────────────
  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    final cur = _cameraController?.description.lensDirection;
    final next = _cameras.firstWhere(
      (c) => c.lensDirection != cur,
      orElse: () => _cameras.first,
    );
    setState(() => _isCameraReady = false);
    await _cameraController?.dispose();
    final ctrl = CameraController(next, ResolutionPreset.high, enableAudio: false);
    _cameraController = ctrl;
    await ctrl.initialize();
    if (mounted) setState(() => _isCameraReady = true);
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_position == Offset.zero) {
      _position = Offset(size.width / 2, size.height * 0.45);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: Camera Feed ────────────────────────────────
          RepaintBoundary(
            key: _repaintKey,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildBackground(size),
                if (widget.imageUrl.isNotEmpty) _buildProductOverlay(size),
                if (_showCaptureFlash) Container(color: Colors.white),
              ],
            ),
          ),

          // ── Layer 2: Help Hint (not captured) ──────────────────
          if (!_isPlaced && _isCameraReady)
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showHelp ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded, color: Colors.white70, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Drag  •  Pinch to Scale  •  Twist to Rotate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Background ───────────────────────────────────────────────────
  Widget _buildBackground(Size size) {
    if (_isCameraReady && _cameraController != null) {
      return CameraPreview(_cameraController!);
    }
    if (_cameraPermissionDenied) {
      return _buildFallbackRoom(size);
    }
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
            SizedBox(height: 14),
            Text('Starting camera…',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackRoom(Size size) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.65, 0.65, 1.0],
          colors: [
            Color(0xFFF5ECD7),
            Color(0xFFF5ECD7),
            Color(0xFFD4B896),
            Color(0xFFBFA07A),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: size.height * 0.65,
            child: Container(height: 3, color: const Color(0xFFB8976A)),
          ),
          Positioned(
            top: 110,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Enable camera permission to use your live room',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Product Overlay ──────────────────────────────────────────────
  Widget _buildProductOverlay(Size size) {
    final shadowBlur = (20 * _scale).clamp(8.0, 60.0);
    final shadowOpacity = (0.35 * (_scale / 1.5)).clamp(0.05, 0.5);
    final overlaySize = size.width * 0.45;
    final halfSize = (overlaySize * _scale) / 2;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onPanUpdate: _onPanUpdate,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Product image
          Positioned(
            left: _position.dx - halfSize,
            top: _position.dy - halfSize,
            child: Transform.rotate(
              angle: _rotation,
              child: Container(
                width: overlaySize * _scale,
                height: overlaySize * _scale,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: shadowOpacity),
                      blurRadius: shadowBlur,
                      offset: Offset(0, 12 * _scale),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular((6 * _scale).clamp(2.0, 18.0)),
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.accent.withValues(alpha: 0.25),
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: AppColors.accent, size: 48),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Size pill
          if (widget.estimatedSize != null)
            Positioned(
              top: 90,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.straighten_rounded,
                        size: 12, color: AppColors.accent),
                    const SizedBox(width: 5),
                    Text(
                      widget.estimatedSize!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.view_in_ar_rounded, color: AppColors.accent, size: 14),
              SizedBox(width: 5),
              Text(
                'Try in Your Room',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Text(
            widget.productTitle,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Bottom Toolbar ───────────────────────────────────────────────
  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        height: 88,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ToolbarButton(
              icon: Icons.restart_alt_rounded,
              label: 'Reset',
              onTap: _resetTransform,
            ),
            // Shutter button
            GestureDetector(
              onTap: _captureSnapshot,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  color: _isCapturing
                      ? AppColors.accent
                      : Colors.white.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: _isCapturing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Icon(Icons.camera_rounded,
                          color: Colors.white, size: 28),
                ),
              ),
            ),
            _ToolbarButton(
              icon: Icons.flip_camera_ios_rounded,
              label: 'Flip',
              onTap: _cameras.length > 1 ? _flipCamera : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Toolbar button
// ─────────────────────────────────────────────────────────────────────────────
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _ToolbarButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: enabled ? Colors.black54 : Colors.black26,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon,
                color: enabled ? Colors.white : Colors.white38, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Share Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _SnapshotShareSheet extends StatelessWidget {
  final Uint8List imageBytes;
  final String filePath;
  final String productTitle;
  const _SnapshotShareSheet({
    required this.imageBytes,
    required this.filePath,
    required this.productTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              imageBytes,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            productTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          const Text(
            'Captured using KalaSeṭu AR Room Preview',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.save_alt_rounded, size: 18),
                  label: const Text('Save Photo'),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saved: $filePath'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Share'),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📸 Saved! Share it with your family.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
