import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/models.dart';
import 'artisan_catalogue_screen.dart';
import '../../buyer/presentation/buyer_marketplace_screen.dart';

class AiCameraStudioScreen extends ConsumerStatefulWidget {
  const AiCameraStudioScreen({super.key});

  @override
  ConsumerState<AiCameraStudioScreen> createState() => _AiCameraStudioScreenState();
}

class _AiCameraStudioScreenState extends ConsumerState<AiCameraStudioScreen> {
  int _step = 1; // 1: Camera Studio, 2: Voice-to-Catalog, 3: Pricing Assistant
  final _picker = ImagePicker();
  late final AudioRecorder _audioRecorder;

  // Step 1: Camera & Image state
  Uint8List? _capturedImageBytes;
  Uint8List? _enhancedImageBytes;
  bool _showEnhanced = true;
  bool _isEnhancing = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  // Step 2: Voice & Catalog state
  bool _isRecording = false;
  bool _recordingComplete = false;
  bool _isCataloging = false;
  final _manualDescCtrl = TextEditingController();

  String _titleEn = 'Handwoven Varanasi Pure Silk Dupatta with Zari Border';
  String _titleHi = 'हथकरघा बनारसी सिल्क दुपट्टा (ज़री बॉर्डर)';
  String _descriptionEn =
      'Master weaver Ramesh Sharma uses pure mulberry silk and real zari on a traditional pit loom. Natural dyes from indigo and madder roots. GI tag certified.';
  String _descriptionHi =
      'मास्टर बुनकर रमेश शर्मा पारंपरिक गड्ढा करघे पर शुद्ध शहतूत रेशम और असली जरी का उपयोग करते हैं।';
  String _category = 'Handloom';
  List<String> _materials = ['Pure Mulberry Silk', 'Real Zari Thread', 'Natural Dyes'];
  List<String> _tags = ['Handloom', 'Pure Silk', 'GI Tag', 'Banarasi', 'Zari Border'];
  String _transcript =
      '"यह वाराणसी का हाथ से बुना हुआ शुद्ध रेशम का दुपट्टा है। इसमें असली ज़री का काम है और यह प्राकृतिक रंगों से रंगा गया है..."';

  // Step 3: Pricing Assistant state
  final _materialCostCtrl = TextEditingController(text: '450');
  final _laborHoursCtrl = TextEditingController(text: '8');
  double _currentPrice = 1200;
  double _breakevenPrice = 650;
  double _premiumPrice = 1800;
  bool _isCalculatingPrice = false;
  List<ShapFactor> _shapFactors = [];
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _manualDescCtrl.dispose();
    _materialCostCtrl.dispose();
    _laborHoursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Top Bar: 'X' + Progress bar + Step counter
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.primary, size: 24),
                    onPressed: () {
                      if (_step > 1) {
                        setState(() => _step--);
                      } else {
                        context.pop();
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: List.generate(3, (index) {
                        final filled = _step > index;
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                            decoration: BoxDecoration(
                              color: filled ? AppColors.accent : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '$_step/3',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A94A6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: switch (_step) {
                  1 => _buildCameraStep(),
                  2 => _buildVoiceStep(),
                  _ => _buildPricingStep(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1: AI Camera Studio ─────────────────────────────────────
  Widget _buildCameraStep() {
    final displayBytes = (_showEnhanced && _enhancedImageBytes != null)
        ? _enhancedImageBytes
        : _capturedImageBytes;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Camera Studio',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Capture your craft with AI studio lighting & background enhancement',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF8A94A6)),
          ),
          const SizedBox(height: 20),

          // Dark Navy Camera Viewport Container
          Container(
            width: double.infinity,
            height: 380,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Captured or enhanced image preview
                if (displayBytes != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.memory(displayBytes, fit: BoxFit.cover),
                    ),
                  ),

                // Dashed Viewfinder Frame
                if (displayBytes == null)
                  const Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: CustomPaint(
                        painter: _DashedRectPainter(color: Colors.white38),
                        child: Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 52,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Enhancing loading indicator overlay
                if (_isEnhancing)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.accent),
                          SizedBox(height: 12),
                          Text(
                            'AI Studio Enhancement in progress...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Top Flash & Flip Camera Icons
                Positioned(
                  top: 18,
                  right: 18,
                  child: Row(
                    children: [
                      _buildSquircleIconButton(
                        icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        bgColor: _isFlashOn ? const Color(0xFFF5A623) : Colors.white.withValues(alpha: 0.2),
                        iconColor: _isFlashOn ? AppColors.primary : Colors.white,
                        onTap: () => setState(() => _isFlashOn = !_isFlashOn),
                      ),
                      const SizedBox(width: 10),
                      _buildSquircleIconButton(
                        icon: Icons.flip_camera_ios_outlined,
                        bgColor: Colors.white.withValues(alpha: 0.15),
                        iconColor: Colors.white,
                        onTap: () => setState(() => _isFrontCamera = !_isFrontCamera),
                      ),
                    ],
                  ),
                ),

                // Gallery Picker at bottom left
                Positioned(
                  bottom: 24,
                  left: 24,
                  child: _buildSquircleIconButton(
                    icon: Icons.photo_library_outlined,
                    bgColor: Colors.white.withValues(alpha: 0.2),
                    iconColor: Colors.white,
                    onTap: _pickFromGallery,
                  ),
                ),

                // Big Shutter Button at bottom center
                Positioned(
                  bottom: 18,
                  child: GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF334155),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ),
                ),

                // Enhancement toggle button if enhanced image exists
                if (_enhancedImageBytes != null)
                  Positioned(
                    top: 18,
                    left: 18,
                    child: GestureDetector(
                      onTap: () => setState(() => _showEnhanced = !_showEnhanced),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _showEnhanced ? AppColors.accent : Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showEnhanced ? Icons.auto_awesome : Icons.image_outlined,
                              size: 14,
                              color: _showEnhanced ? AppColors.primary : Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _showEnhanced ? '✨ AI Enhanced' : 'Original',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _showEnhanced ? AppColors.primary : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Helper text / Next Step Button
          if (_capturedImageBytes != null) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _step = 2),
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: const Text('Continue to Voice-to-Catalog', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ] else ...[
            const Center(
              child: Text(
                'Center your craft within the frame or pick from gallery',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8A94A6),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _step = 2),
                icon: const Icon(Icons.fast_forward_rounded, size: 16, color: AppColors.primary),
                label: const Text('Skip photo for now', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Step 2: Voice-to-Catalog ─────────────────────────────────────
  Widget _buildVoiceStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Voice-to-Catalog',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Speak about your craft in Hindi or regional language — AI generates the listing',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF8A94A6)),
          ),
          const SizedBox(height: 20),

          // Big Golden Mic Button
          Center(
            child: GestureDetector(
              onTap: _toggleRecording,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: _isRecording ? AppColors.error : const Color(0xFFF5A623),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? AppColors.error : const Color(0xFFF5A623))
                          .withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Center(
            child: Text(
              _isRecording
                  ? 'Listening... Speak in Hindi or your language (Tap to Stop)'
                  : _isCataloging
                      ? 'AI Generating Catalog...'
                      : _recordingComplete
                          ? 'Recording processed with AI!'
                          : 'Tap mic to start recording',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _isRecording
                    ? AppColors.error
                    : _isCataloging
                        ? AppColors.accent
                        : const Color(0xFF15803D),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Sample Notes for easy testing
          Row(
            children: [
              const Text('Quick Samples:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8A94A6))),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickPromptChip('Silk Dupatta', 'वाराणसी का हाथ से बुना शुद्ध रेशम दुपट्टा असली जरी बॉर्डर के साथ'),
                      _buildQuickPromptChip('Terracotta Pot', 'काली मिट्टी से बना गोरखपुर का सजावटी टेराकोटा बर्तन'),
                      _buildQuickPromptChip('Madhubani Art', 'बिहार की पारंपरिक हस्तनिर्मित मधुबनी पेंटिंग प्राकृतिक रंगों से'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isCataloging)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.accent),
                    SizedBox(height: 12),
                    Text('Analyzing craft with Gemini & Multilingual AI...', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )
          else ...[
            // Transcript (Hindi) Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transcript (Hindi)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8A94A6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _transcript,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // AI Generated (English) Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text(
                        'AI Generated (English)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _titleEn,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _descriptionEn,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // AI Generated (Hindi) Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9EE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: Color(0xFF92400E)),
                      SizedBox(width: 6),
                      Text(
                        'AI Generated (Hindi)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _titleHi,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _descriptionHi,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Chips Row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StudioChip(label: _category),
                ..._materials.map((m) => _StudioChip(label: m)),
                ..._tags.map((t) => _StudioChip(label: t)),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // Continue to Pricing Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _step = 3);
                _calculatePriceWithAi();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue to Pricing Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  SizedBox(width: 6),
                  Icon(Icons.chevron_right_rounded, size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Step 3: Fair-Wage Pricing Assistant ──────────────────────────
  Widget _buildPricingStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fair-Wage Pricing Assistant',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'XGBoost & SHAP Explainable AI ensures fair compensation for artisan labor',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF8A94A6)),
          ),
          const SizedBox(height: 20),

          // Cost & Labor Inputs Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Material Cost (₹)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _materialCostCtrl,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) => _calculatePriceWithAi(),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Labor Hours',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _laborHoursCtrl,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) => _calculatePriceWithAi(),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Recalculate button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _isCalculatingPrice ? null : _calculatePriceWithAi,
              icon: _isCalculatingPrice
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Recalculate AI Fair Price', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 6),

          // Multiplier banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9EE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFFD97706), size: 18),
                const SizedBox(width: 8),
                Text(
                  '$_category Craft — 1.6× Fair Labor Multiplier',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Live Market Price Range Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Market Price Range',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 14),
                // Price Range values row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹ ${_breakevenPrice.toInt()}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                        const Text('Breakeven', style: TextStyle(fontSize: 11, color: Color(0xFF8A94A6))),
                      ],
                    ),
                    Column(
                      children: [
                        Text('₹ ${_currentPrice.toInt()}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFFD97706))),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                            SizedBox(width: 2),
                            Text('AI Suggested', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFD97706))),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹ ${_premiumPrice.toInt()}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                        const Text('Premium', style: TextStyle(fontSize: 11, color: Color(0xFF8A94A6))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFF5A623),
                    inactiveTrackColor: const Color(0xFF334155),
                    thumbColor: const Color(0xFFF5A623),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _currentPrice.clamp(_breakevenPrice, _premiumPrice),
                    min: _breakevenPrice,
                    max: _premiumPrice > _breakevenPrice ? _premiumPrice : _breakevenPrice + 100,
                    onChanged: (val) => setState(() => _currentPrice = val),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Wholesale B2B Price (75% of retail) Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wholesale B2B Price (75% of retail)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹ ${(_currentPrice * 0.75).toInt()}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // AI PRICE FACTORS (XAI)
          const Text(
            'AI PRICE FACTORS (XAI)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8A94A6),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          if (_shapFactors.isNotEmpty) ...[
            ..._shapFactors.take(4).map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _buildFactorPill(
                    '${f.value >= 0 ? "+" : ""}₹${f.value.abs().toInt()} ${f.feature}',
                    const Color(0xFFDBEAFE),
                    const Color(0xFF1E40AF),
                  ),
                )),
          ] else ...[
            _buildFactorPill('+₹250 Pure Silk Material', const Color(0xFFDBEAFE), const Color(0xFF1E40AF)),
            const SizedBox(height: 6),
            _buildFactorPill('+₹300 8-Hour Hand Weave', const Color(0xFFFEF3C7), const Color(0xFF92400E)),
            const SizedBox(height: 6),
            _buildFactorPill('+₹100 GI Tag Certified', const Color(0xFFD1FAE5), const Color(0xFF065F46)),
            const SizedBox(height: 6),
            _buildFactorPill('+₹150 Zari Thread Work', const Color(0xFFF3E8FF), const Color(0xFF6B21A8)),
          ],

          const SizedBox(height: 24),

          // Publish to Live Marketplace Button (Amber)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isPublishing ? null : _publishListing,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5A623),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isPublishing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Publish to Live Marketplace',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Helper Widgets ───────────────────────────────────────────────
  Widget _buildQuickPromptChip(String title, String prompt) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        onPressed: () => _generateCatalogFromText(prompt),
      ),
    );
  }

  Widget _buildFactorPill(String label, Color bg, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSquircleIconButton({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }

  // ── Action Handlers ──────────────────────────────────────────────

  Future<void> _takePhoto() async {
    try {
      final img = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1280, maxHeight: 1280);
      if (img != null) {
        final bytes = await img.readAsBytes();
        setState(() {
          _capturedImageBytes = bytes;
          _enhancedImageBytes = null;
        });
        _enhanceImageAsync(bytes);
      } else if (_capturedImageBytes == null) {
        // Fallback for emulator / environments without physical camera: pick from gallery
        _pickFromGallery();
      }
    } catch (_) {
      _pickFromGallery();
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final img = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1280, maxHeight: 1280);
      if (img != null) {
        final bytes = await img.readAsBytes();
        setState(() {
          _capturedImageBytes = bytes;
          _enhancedImageBytes = null;
        });
        _enhanceImageAsync(bytes);
      }
    } catch (_) {}
  }

  Future<void> _enhanceImageAsync(Uint8List bytes) async {
    setState(() => _isEnhancing = true);
    try {
      final api = ref.read(apiClientProvider);
      final enhanced = await api.enhanceImage(imageBytes: bytes);
      if (mounted) {
        setState(() {
          _enhancedImageBytes = enhanced;
          _showEnhanced = true;
        });
      }
    } catch (_) {
      // Keep original image cleanly if offline
    } finally {
      if (mounted) setState(() => _isEnhancing = false);
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      try {
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
          _recordingComplete = true;
        });
        if (path != null) {
          await _processVoiceNote(File(path));
        }
      } catch (_) {
        setState(() => _isRecording = false);
      }
    } else {
      try {
        final hasPermission = await _audioRecorder.hasPermission();
        if (hasPermission) {
          final dir = await getTemporaryDirectory();
          final filePath = '${dir.path}/artisan_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(const RecordConfig(), path: filePath);
          setState(() {
            _isRecording = true;
            _recordingComplete = false;
          });
        } else {
          // If no mic permission, offer sample text prompt
          _generateCatalogFromText('वाराणसी का हाथ से बुना शुद्ध रेशम दुपट्टा असली जरी बॉर्डर के साथ');
        }
      } catch (_) {
        _generateCatalogFromText('वाराणसी का हाथ से बुना शुद्ध रेशम दुपट्टा असली जरी बॉर्डर के साथ');
      }
    }
  }

  Future<void> _processVoiceNote(File audioFile) async {
    setState(() => _isCataloging = true);
    try {
      final api = ref.read(apiClientProvider);
      final catalog = await api.generateCatalog(audioFile: audioFile, lang: 'Hindi');
      _applyCatalog(catalog);
    } catch (_) {
      _generateCatalogFromText('वाराणसी का हाथ से बुना शुद्ध रेशम दुपट्टा असली जरी बॉर्डर के साथ');
    } finally {
      if (mounted) setState(() => _isCataloging = false);
    }
  }

  Future<void> _generateCatalogFromText(String textDesc) async {
    setState(() => _isCataloging = true);
    try {
      final api = ref.read(apiClientProvider);
      final catalog = await api.generateCatalog(textDesc: textDesc, lang: 'Hindi');
      _applyCatalog(catalog);
    } catch (_) {
      // Fallback
      setState(() {
        _transcript = '"$textDesc"';
      });
    } finally {
      if (mounted) setState(() => _isCataloging = false);
    }
  }

  void _applyCatalog(ProductCatalogGenerated catalog) {
    setState(() {
      if (catalog.titleEn.isNotEmpty) _titleEn = catalog.titleEn;
      if (catalog.titleHi.isNotEmpty) _titleHi = catalog.titleHi;
      if (catalog.descriptionEn.isNotEmpty) _descriptionEn = catalog.descriptionEn;
      if (catalog.descriptionHi.isNotEmpty) _descriptionHi = catalog.descriptionHi;
      if (catalog.category.isNotEmpty) _category = catalog.category;
      if (catalog.materials.isNotEmpty) _materials = catalog.materials;
      if (catalog.tags.isNotEmpty) _tags = catalog.tags;
      if (catalog.rawTranscript != null && catalog.rawTranscript!.isNotEmpty) {
        _transcript = '"${catalog.rawTranscript}"';
      }
    });
  }

  Future<void> _calculatePriceWithAi() async {
    setState(() => _isCalculatingPrice = true);
    final matCost = double.tryParse(_materialCostCtrl.text) ?? 450.0;
    final hours = double.tryParse(_laborHoursCtrl.text) ?? 8.0;

    try {
      final api = ref.read(apiClientProvider);
      final breakdown = await api.predictPrice(
        craftCategory: _category,
        rawMaterialCost: matCost,
        laborHours: hours,
        materialType: _materials.isNotEmpty ? _materials.first : 'Silk',
        regionState: 'Uttar Pradesh',
        giTag: _tags.any((t) => t.toLowerCase().contains('gi')),
      );

      if (mounted) {
        setState(() {
          _currentPrice = breakdown.suggestedRetailPrice > 0 ? breakdown.suggestedRetailPrice : 1200;
          _breakevenPrice = (matCost + (hours * 25)).clamp(100, _currentPrice);
          _premiumPrice = _currentPrice * 1.5;
          _shapFactors = breakdown.shapFactors;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _breakevenPrice = matCost + (hours * 25);
          _currentPrice = (matCost * 1.6) + (hours * 60);
          _premiumPrice = _currentPrice * 1.5;
        });
      }
    } finally {
      if (mounted) setState(() => _isCalculatingPrice = false);
    }
  }

  Future<void> _publishListing() async {
    setState(() => _isPublishing = true);

    try {
      final api = ref.read(apiClientProvider);
      await api.createProduct(
        titleEn: _titleEn,
        titleHi: _titleHi,
        descriptionEn: _descriptionEn,
        descriptionHi: _descriptionHi,
        category: _category,
        materials: _materials,
        tags: _tags,
        retailPrice: _currentPrice,
        b2bPrice: _currentPrice * 0.75,
        stock: 10,
      );

      ref.invalidate(artisanProductsProvider);
      ref.invalidate(marketplaceProductsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Craft listing successfully published to marketplace!'),
            backgroundColor: Color(0xFF15803D),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish listing: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }
}

class _StudioChip extends StatelessWidget {
  final String label;
  const _StudioChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  const _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 5.0;

    // Draw top line
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }

    // Draw bottom line
    startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }

    // Draw left line
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }

    // Draw right line
    startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
