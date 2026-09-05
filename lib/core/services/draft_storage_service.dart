import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDraftKey = 'kalasetu_product_draft';
const _kOfflineQueueKey = 'kalasetu_offline_queue';

final draftStorageServiceProvider = Provider<DraftStorageService>(
  (_) => DraftStorageService(),
);

/// A single product draft spanning the 4-phase AI Studio workflow.
class ProductDraft {
  final String id;
  final int currentPhase; // 1-4
  final String? localImagePath;
  final String? enhancedImageBase64; // base64 of Uint8List
  final String? localAudioPath;
  final String? rawTranscript;
  final String? titleEn;
  final String? titleHi;
  final String? descEn;
  final String? descHi;
  final String? category;
  final List<String> tags;
  final List<String> materials;
  final double? materialCost;
  final double? laborHours;
  final double? retailPrice;
  final double? b2bPrice;
  final DateTime lastSaved;
  final bool isQueuedForSync;

  const ProductDraft({
    required this.id,
    required this.currentPhase,
    this.localImagePath,
    this.enhancedImageBase64,
    this.localAudioPath,
    this.rawTranscript,
    this.titleEn,
    this.titleHi,
    this.descEn,
    this.descHi,
    this.category,
    this.tags = const [],
    this.materials = const [],
    this.materialCost,
    this.laborHours,
    this.retailPrice,
    this.b2bPrice,
    required this.lastSaved,
    this.isQueuedForSync = false,
  });

  Uint8List? get enhancedBytes {
    if (enhancedImageBase64 == null) return null;
    return base64Decode(enhancedImageBase64!);
  }

  ProductDraft copyWith({
    int? currentPhase,
    String? localImagePath,
    Uint8List? enhancedBytes,
    String? localAudioPath,
    String? rawTranscript,
    String? titleEn,
    String? titleHi,
    String? descEn,
    String? descHi,
    String? category,
    List<String>? tags,
    List<String>? materials,
    double? materialCost,
    double? laborHours,
    double? retailPrice,
    double? b2bPrice,
    bool? isQueuedForSync,
  }) {
    return ProductDraft(
      id: id,
      currentPhase: currentPhase ?? this.currentPhase,
      localImagePath: localImagePath ?? this.localImagePath,
      enhancedImageBase64: enhancedBytes != null
          ? base64Encode(enhancedBytes)
          : enhancedImageBase64,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      titleEn: titleEn ?? this.titleEn,
      titleHi: titleHi ?? this.titleHi,
      descEn: descEn ?? this.descEn,
      descHi: descHi ?? this.descHi,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      materials: materials ?? this.materials,
      materialCost: materialCost ?? this.materialCost,
      laborHours: laborHours ?? this.laborHours,
      retailPrice: retailPrice ?? this.retailPrice,
      b2bPrice: b2bPrice ?? this.b2bPrice,
      lastSaved: DateTime.now(),
      isQueuedForSync: isQueuedForSync ?? this.isQueuedForSync,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'currentPhase': currentPhase,
        'localImagePath': localImagePath,
        'enhancedImageBase64': enhancedImageBase64,
        'localAudioPath': localAudioPath,
        'rawTranscript': rawTranscript,
        'titleEn': titleEn,
        'titleHi': titleHi,
        'descEn': descEn,
        'descHi': descHi,
        'category': category,
        'tags': tags,
        'materials': materials,
        'materialCost': materialCost,
        'laborHours': laborHours,
        'retailPrice': retailPrice,
        'b2bPrice': b2bPrice,
        'lastSaved': lastSaved.toIso8601String(),
        'isQueuedForSync': isQueuedForSync,
      };

  factory ProductDraft.fromJson(Map<String, dynamic> json) => ProductDraft(
        id: json['id'] as String? ?? 'draft_${DateTime.now().millisecondsSinceEpoch}',
        currentPhase: (json['currentPhase'] as num?)?.toInt() ?? 1,
        localImagePath: json['localImagePath'] as String?,
        enhancedImageBase64: json['enhancedImageBase64'] as String?,
        localAudioPath: json['localAudioPath'] as String?,
        rawTranscript: json['rawTranscript'] as String?,
        titleEn: json['titleEn'] as String?,
        titleHi: json['titleHi'] as String?,
        descEn: json['descEn'] as String?,
        descHi: json['descHi'] as String?,
        category: json['category'] as String?,
        tags: List<String>.from(json['tags'] as List? ?? []),
        materials: List<String>.from(json['materials'] as List? ?? []),
        materialCost: (json['materialCost'] as num?)?.toDouble(),
        laborHours: (json['laborHours'] as num?)?.toDouble(),
        retailPrice: (json['retailPrice'] as num?)?.toDouble(),
        b2bPrice: (json['b2bPrice'] as num?)?.toDouble(),
        lastSaved: DateTime.tryParse(json['lastSaved'] as String? ?? '') ?? DateTime.now(),
        isQueuedForSync: json['isQueuedForSync'] as bool? ?? false,
      );
}

/// Service for persisting/resuming AI Studio drafts and offline outbox queue
class DraftStorageService {
  Future<void> saveDraft(ProductDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDraftKey, jsonEncode(draft.toJson()));
  }

  Future<ProductDraft?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kDraftKey);
    if (raw == null) return null;
    try {
      return ProductDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kDraftKey);
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDraftKey);
  }

  // ── Offline Outbox Queue ──────────────────────────────────────
  Future<List<ProductDraft>> loadOfflineQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kOfflineQueueKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ProductDraft.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addToOfflineQueue(ProductDraft draft) async {
    final queue = await loadOfflineQueue();
    queue.add(draft.copyWith(isQueuedForSync: true));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kOfflineQueueKey,
      jsonEncode(queue.map((d) => d.toJson()).toList()),
    );
  }

  Future<void> removeFromOfflineQueue(String draftId) async {
    final queue = await loadOfflineQueue();
    queue.removeWhere((d) => d.id == draftId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kOfflineQueueKey,
      jsonEncode(queue.map((d) => d.toJson()).toList()),
    );
  }

  Future<int> getOfflineQueueCount() async {
    final queue = await loadOfflineQueue();
    return queue.length;
  }
}
