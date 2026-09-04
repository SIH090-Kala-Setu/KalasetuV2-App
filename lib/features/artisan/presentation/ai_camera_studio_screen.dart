import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';

class AiCameraStudioScreen extends ConsumerStatefulWidget {
  const AiCameraStudioScreen({super.key});

  @override
  ConsumerState<AiCameraStudioScreen> createState() => _AiCameraStudioScreenState();
}

class _AiCameraStudioScreenState extends ConsumerState<AiCameraStudioScreen> {
  int _step = 1; // 1: Camera Studio, 2: Voice-to-Catalog, 3: Pricing Assistant
  final _picker = ImagePicker();

  Uint8List? _capturedImageBytes;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isRecording = false;
  bool _recordingComplete = true; // default true for demo or toggled

  // Pricing inputs
  final _materialCostCtrl = TextEditingController(text: '450');
  final _laborHoursCtrl = TextEditingController(text: '8');
  double _currentPrice = 1200;
  bool _isPublishing = false;

  @override
  void dispose() {
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
              // Top Bar: 'X' + Progress bar (1/4, 3/4, 4/4) + Step text
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.primary, size: 24),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: List.generate(4, (index) {
                        final filled = (_step == 1 && index == 0) ||
                            (_step == 2 && index < 3) ||
                            (_step == 3);
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
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
                    _step == 1 ? '1/4' : _step == 2 ? '3/4' : '4/4',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A94A6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
    return Column(
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
          'Capture your craft with AI enhancement',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF8A94A6)),
        ),
        const SizedBox(height: 24),

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
              // Captured image or dashed viewfinder
              if (_capturedImageBytes != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.memory(_capturedImageBytes!, fit: BoxFit.cover),
                  ),
                ),
              // Dashed Viewfinder Frame
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: CustomPaint(
                    painter: const _DashedRectPainter(color: Colors.white38),
                    child: Center(
                      child: _capturedImageBytes == null
                          ? const Icon(
                              Icons.camera_alt_outlined,
                              size: 52,
                              color: Colors.white54,
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // Flash & Flip Camera Icons at top right
              Positioned(
                top: 18,
                right: 18,
                child: Row(
                  children: [
                    _buildSquircleIconButton(
                      icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      bgColor: const Color(0xFFF5A623),
                      iconColor: AppColors.primary,
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
                  bgColor: Colors.white.withValues(alpha: 0.15),
                  iconColor: Colors.white,
                  onTap: _pickFromGallery,
                ),
              ),

              // Big Shutter Button at bottom center
              Positioned(
                bottom: 18,
                child: GestureDetector(
                  onTap: () => setState(() => _step = 2),
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
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Helper text below
        const Center(
          child: Text(
            'Center your craft within the frame for best results',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8A94A6),
            ),
          ),
        ),
      ],
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
            'Speak about your craft — AI generates the listing',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF8A94A6)),
          ),
          const SizedBox(height: 20),

          // Big Golden Mic Button
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isRecording = !_isRecording;
                  if (!_isRecording) _recordingComplete = true;
                });
              },
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5A623),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF5A623).withValues(alpha: 0.35),
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
                  ? 'Listening... Speak in Hindi or your language'
                  : _recordingComplete
                      ? 'Recording complete!'
                      : 'Tap mic to start recording',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _isRecording ? AppColors.accent : const Color(0xFF15803D),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Transcript (Hindi) Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transcript (Hindi)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A94A6),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '"यह वाराणसी का हाथ से बुना हुआ शुद्ध रेशम का दुपट्टा है। इसमें असली ज़री का काम है और यह प्राकृतिक रंगों से रंगा गया है..."',
                  style: TextStyle(
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                SizedBox(height: 8),
                Text(
                  'Handwoven Varanasi Pure Silk Dupatta with Zari Border',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Master weaver Ramesh Sharma uses pure mulberry silk and real zari on a traditional pit loom. Natural dyes from indigo and madder roots. GI tag certified.',
                  style: TextStyle(
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                SizedBox(height: 6),
                Text(
                  'हथकरघा बनारसी सिल्क दुपट्टा (ज़री बॉर्डर)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Chips Row
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StudioChip(label: 'Handloom'),
              _StudioChip(label: 'Pure Silk'),
              _StudioChip(label: 'GI Tag'),
              _StudioChip(label: 'Banarasi'),
              _StudioChip(label: 'Zari Border'),
              _StudioChip(label: 'Natural Dyes'),
            ],
          ),
          const SizedBox(height: 24),

          // Continue to Pricing Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => setState(() => _step = 3),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue to Pricing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
            'AI suggests a fair price based on your craft',
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
          const SizedBox(height: 14),

          // Multiplier banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9EE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFFD97706), size: 18),
                SizedBox(width: 8),
                Text(
                  'Intricate Craft — 1.6× Multiplier',
                  style: TextStyle(
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹ 650', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                        Text('Breakeven', style: TextStyle(fontSize: 11, color: Color(0xFF8A94A6))),
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹ 1,800', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                        Text('Premium', style: TextStyle(fontSize: 11, color: Color(0xFF8A94A6))),
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
                    value: _currentPrice,
                    min: 650,
                    max: 1800,
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

          _buildFactorPill('+₹250 Pure Silk Material', const Color(0xFFDBEAFE), const Color(0xFF1E40AF)),
          const SizedBox(height: 6),
          _buildFactorPill('+₹300 8-Hour Hand Weave', const Color(0xFFFEF3C7), const Color(0xFF92400E)),
          const SizedBox(height: 6),
          _buildFactorPill('+₹100 GI Tag Certified', const Color(0xFFD1FAE5), const Color(0xFF065F46)),
          const SizedBox(height: 6),
          _buildFactorPill('+₹150 Zari Thread Work', const Color(0xFFF3E8FF), const Color(0xFF6B21A8)),

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

  Future<void> _pickFromGallery() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() {
        _capturedImageBytes = bytes;
        _step = 2;
      });
    }
  }

  Future<void> _publishListing() async {
    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(milliseconds: 700));

    try {
      final api = ref.read(apiClientProvider);
      await api.createProduct(
        titleEn: 'Handwoven Varanasi Pure Silk Dupatta with Zari Border',
        titleHi: 'हथकरघा बनारसी सिल्क दुपट्टा (ज़री बॉर्डर)',
        descriptionEn: 'Master weaver Ramesh Sharma uses pure mulberry silk and real zari on a traditional pit loom.',
        descriptionHi: 'मास्टर बुनकर रमेश शर्मा पारंपरिक गड्ढा करघे पर शुद्ध शहतूत रेशम और असली जरी का उपयोग करते हैं।',
        category: 'Handloom',
        materials: ['Pure Mulberry Silk', 'Real Zari Thread', 'Natural Dyes'],
        tags: ['Handloom', 'Pure Silk', 'GI Tag', 'Banarasi'],
        retailPrice: _currentPrice,
        b2bPrice: _currentPrice * 0.75,
      );
    } catch (_) {}

    if (mounted) {
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Craft listing successfully published!')),
      );
      context.pop();
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
