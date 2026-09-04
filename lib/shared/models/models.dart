/// KalaSetuV2 — All Shared Data Models
///
/// Each model uses defensive fromJson factories that handle:
/// - Null values with safe defaults
/// - Type coercion (int/double mismatch)
/// - Missing fields
/// - Malformed data
library;

// ── UserModel ─────────────────────────────────────────────────
class UserModel {
  final String id;
  final String username;
  final String role; // 'Artisan' | 'Aggregator' | 'Buyer'
  final String fullName;
  final String? email;
  final String? phone;
  final String preferredLang;
  final String? craftType;
  final String? region;
  final String? district;
  final String kycStatus; // 'verified' | 'pending' | 'draft'
  final bool isVerified;
  final String? avatarUrl;
  final String? clusterName;
  final int? experienceYears;
  final String? village;
  final String? bio;
  final double? monthlyEarnings;
  final int? activeListings;
  final int? totalViews;

  const UserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.fullName,
    this.email,
    this.phone,
    this.preferredLang = 'en',
    this.craftType,
    this.region,
    this.district,
    this.kycStatus = 'draft',
    this.isVerified = false,
    this.avatarUrl,
    this.clusterName,
    this.experienceYears,
    this.village,
    this.bio,
    this.monthlyEarnings,
    this.activeListings,
    this.totalViews,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] ?? json['user_id'] ?? '').toString(),
        username: (json['username'] ?? '').toString(),
        role: (json['role'] ?? 'Artisan').toString(),
        fullName: (json['full_name'] ?? json['fullName'] ?? json['username'] ?? '').toString(),
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        preferredLang: (json['preferred_lang'] ?? json['preferredLang'] ?? 'en').toString(),
        craftType: json['craft_type'] as String? ?? json['craftType'] as String?,
        region: json['region'] as String?,
        district: json['district'] as String?,
        kycStatus: (json['kyc_status'] ?? json['kycStatus'] ?? 'draft').toString(),
        isVerified: json['is_verified'] as bool? ?? json['verified'] as bool? ?? false,
        avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String?,
        clusterName: json['cluster_name'] as String? ?? json['cluster'] as String?,
        experienceYears: (json['experience_years'] ?? json['experienceYears'] as num?)?.toInt(),
        village: json['village'] as String?,
        bio: json['bio'] as String?,
        monthlyEarnings: (json['monthly_earnings'] ?? json['monthlyEarnings'] as num?)?.toDouble(),
        activeListings: (json['active_listings'] ?? json['activeListings'] as num?)?.toInt(),
        totalViews: (json['total_views'] ?? json['totalViews'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'role': role,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'preferred_lang': preferredLang,
        'craft_type': craftType,
        'region': region,
        'district': district,
        'kyc_status': kycStatus,
        'is_verified': isVerified,
        'avatar_url': avatarUrl,
        'cluster_name': clusterName,
        'experience_years': experienceYears,
        'village': village,
        'bio': bio,
      };
}

// ── ProductModel ──────────────────────────────────────────────
class ProductModel {
  final String id;
  final String titleEn;
  final String titleHi;
  final String? imageUrl;
  final String category;
  final String? craft;
  final String? region;
  final String? state;
  final double retailPrice;
  final double b2bPrice;
  final int moq;
  final int stock;
  final String status; // 'Active' | 'Draft' | 'Sold Out' | 'Archived'
  final String? artisanId;
  final String? artisanName;
  final bool giTag;
  final double rating;
  final int reviewCount;
  final String? descriptionEn;
  final String? descriptionHi;
  final List<String> materials;
  final List<String> tags;
  final String? complexity;
  final double? aiScore;
  final int? viewCount;
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    required this.titleEn,
    required this.titleHi,
    this.imageUrl,
    required this.category,
    this.craft,
    this.region,
    this.state,
    required this.retailPrice,
    required this.b2bPrice,
    this.moq = 10,
    this.stock = 0,
    this.status = 'Draft',
    this.artisanId,
    this.artisanName,
    this.giTag = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.descriptionEn,
    this.descriptionHi,
    this.materials = const [],
    this.tags = const [],
    this.complexity,
    this.aiScore,
    this.viewCount,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle both base64 data URIs and remote URLs
    String? imageUrl = json['image_url'] as String? ??
        json['imageUrl'] as String? ??
        json['image'] as String?;

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      titleEn: (json['title_en'] ?? json['titleEn'] ?? json['title'] ?? 'Unnamed Product').toString(),
      titleHi: (json['title_hi'] ?? json['titleHi'] ?? json['title_en'] ?? '').toString(),
      imageUrl: imageUrl,
      category: (json['category'] ?? 'General').toString(),
      craft: json['craft'] as String?,
      region: json['region'] as String?,
      state: json['state'] as String?,
      retailPrice: (json['retail_price'] ?? json['retailPrice'] ?? json['price'] ?? 0).toDouble(),
      b2bPrice: (json['b2b_price'] ?? json['b2bPrice'] ?? json['priceBulk'] ?? 0).toDouble(),
      moq: (json['moq'] as num?)?.toInt() ?? 10,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? 'Draft').toString(),
      artisanId: json['artisan_id'] as String? ?? json['artisanId'] as String?,
      artisanName: json['artisan_name'] as String? ?? json['artisanName'] as String?,
      giTag: json['gi_tag'] as bool? ?? json['giTag'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] ?? json['reviews'] as num?)?.toInt() ?? 0,
      descriptionEn: json['description_en'] as String? ?? json['descriptionEn'] as String? ?? json['storyEn'] as String?,
      descriptionHi: json['description_hi'] as String? ?? json['descriptionHi'] as String? ?? json['storyHi'] as String?,
      materials: List<String>.from(json['materials'] as List? ?? []),
      tags: List<String>.from(json['tags'] as List? ?? json['seoTags'] as List? ?? []),
      complexity: json['complexity'] as String?,
      aiScore: (json['ai_score'] ?? json['aiScore'] as num?)?.toDouble(),
      viewCount: (json['view_count'] ?? json['viewCount'] as num?)?.toInt(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}

// ── ProductCatalogGenerated ───────────────────────────────────
class ProductCatalogGenerated {
  final String titleEn;
  final String titleHi;
  final String descriptionEn;
  final String descriptionHi;
  final String category;
  final List<String> tags;
  final List<String> materials;
  final String? rawTranscript;

  const ProductCatalogGenerated({
    required this.titleEn,
    required this.titleHi,
    required this.descriptionEn,
    required this.descriptionHi,
    required this.category,
    this.tags = const [],
    this.materials = const [],
    this.rawTranscript,
  });

  factory ProductCatalogGenerated.fromJson(Map<String, dynamic> json) =>
      ProductCatalogGenerated(
        titleEn: (json['title_en'] ?? json['titleEn'] ?? '').toString(),
        titleHi: (json['title_hi'] ?? json['titleHi'] ?? '').toString(),
        descriptionEn: (json['description_en'] ?? json['descriptionEn'] ?? '').toString(),
        descriptionHi: (json['description_hi'] ?? json['descriptionHi'] ?? '').toString(),
        category: (json['category'] ?? 'General').toString(),
        tags: List<String>.from(json['tags'] as List? ?? []),
        materials: List<String>.from(json['materials'] as List? ?? []),
        rawTranscript: json['raw_transcript'] as String? ?? json['transcript'] as String?,
      );
}

// ── PriceBreakdownModel ───────────────────────────────────────
class PriceBreakdownModel {
  final double suggestedRetailPrice;
  final double suggestedB2bPrice;
  final double materialCost;
  final double laborCost;
  final double overheadCost;
  final double profitMargin;
  final double minPrice;
  final double avgPrice;
  final double maxPrice;
  final String complexity;
  final List<ShapFactor> shapFactors;
  final String? explanation;

  const PriceBreakdownModel({
    required this.suggestedRetailPrice,
    required this.suggestedB2bPrice,
    required this.materialCost,
    required this.laborCost,
    required this.overheadCost,
    required this.profitMargin,
    this.minPrice = 0,
    this.avgPrice = 0,
    this.maxPrice = 0,
    this.complexity = 'Moderate',
    this.shapFactors = const [],
    this.explanation,
  });

  factory PriceBreakdownModel.fromJson(Map<String, dynamic> json) {
    final shapList = json['shap_factors'] ?? json['shapFactors'] ?? [];
    return PriceBreakdownModel(
      suggestedRetailPrice: (json['suggested_retail_price'] ??
              json['suggestedRetailPrice'] ??
              json['retail_price'] ??
              json['suggested_price'] ??
              0)
          .toDouble(),
      suggestedB2bPrice: (json['suggested_b2b_price'] ??
              json['suggestedB2bPrice'] ??
              json['b2b_price'] ??
              json['wholesale_price'] ??
              0)
          .toDouble(),
      materialCost: (json['material_cost'] ?? json['materialCost'] ?? 0).toDouble(),
      laborCost: (json['labor_cost'] ?? json['laborCost'] ?? 0).toDouble(),
      overheadCost: (json['overhead_cost'] ?? json['overheadCost'] ?? 0).toDouble(),
      profitMargin: (json['profit_margin'] ?? json['profitMargin'] ?? 0).toDouble(),
      minPrice: (json['min_price'] ?? json['minPrice'] ?? 0).toDouble(),
      avgPrice: (json['avg_price'] ?? json['avgPrice'] ?? 0).toDouble(),
      maxPrice: (json['max_price'] ?? json['maxPrice'] ?? 0).toDouble(),
      complexity: (json['complexity'] ?? 'Moderate').toString(),
      shapFactors: List<ShapFactor>.from(
        (shapList as List).map((e) => ShapFactor.fromJson(e as Map<String, dynamic>)),
      ),
      explanation: json['explanation'] as String?,
    );
  }
}

class ShapFactor {
  final String feature;
  final double value;
  final String? direction; // '+' or '-'

  const ShapFactor({
    required this.feature,
    required this.value,
    this.direction,
  });

  factory ShapFactor.fromJson(Map<String, dynamic> json) => ShapFactor(
        feature: (json['feature'] ?? json['name'] ?? '').toString(),
        value: (json['value'] as num?)?.toDouble() ?? 0.0,
        direction: json['direction'] as String?,
      );
}

// ── InquiryModel ──────────────────────────────────────────────
class InquiryModel {
  final String id;
  final String buyerName;
  final String? buyerOrg;
  final String? buyerEmail;
  final String productId;
  final String productTitle;
  final int quantity;
  final String? targetDate;
  final String status;
  final double? unitPrice;
  final int? leadTime;
  final String? note;
  final String? responseMessage;
  final DateTime? createdAt;
  final String? avatarUrl;

  const InquiryModel({
    required this.id,
    required this.buyerName,
    this.buyerOrg,
    this.buyerEmail,
    required this.productId,
    required this.productTitle,
    required this.quantity,
    this.targetDate,
    required this.status,
    this.unitPrice,
    this.leadTime,
    this.note,
    this.responseMessage,
    this.createdAt,
    this.avatarUrl,
  });

  factory InquiryModel.fromJson(Map<String, dynamic> json) => InquiryModel(
        id: (json['id'] ?? '').toString(),
        buyerName: (json['buyer_name'] ?? json['buyerName'] ?? 'Unknown').toString(),
        buyerOrg: json['buyer_org'] as String? ?? json['buyerOrg'] as String?,
        buyerEmail: json['buyer_email'] as String? ?? json['buyerEmail'] as String?,
        productId: (json['product_id'] ?? json['productId'] ?? '').toString(),
        productTitle: (json['product_title'] ?? json['productTitle'] ?? '').toString(),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        targetDate: json['target_date'] as String? ?? json['targetDate'] as String?,
        status: (json['status'] ?? 'inquiry-sent').toString(),
        unitPrice: (json['unit_price'] ?? json['unitPrice'] as num?)?.toDouble(),
        leadTime: (json['lead_time'] ?? json['leadTime'] as num?)?.toInt(),
        note: json['note'] as String? ?? json['notes'] as String?,
        responseMessage: json['response_message'] as String? ?? json['responseMessage'] as String?,
        createdAt: DateTime.tryParse(
          json['created_at']?.toString() ?? json['timestamp']?.toString() ?? '',
        ),
        avatarUrl: json['avatar'] as String? ?? json['avatar_url'] as String?,
      );
}

// ── ReviewModel ───────────────────────────────────────────────
class ReviewModel {
  final String id;
  final String productId;
  final String buyerName;
  final String? buyerOrg;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final bool isVerifiedBuyer;
  final bool isRecommended;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.buyerName,
    this.buyerOrg,
    required this.rating,
    this.comment,
    this.createdAt,
    this.isVerifiedBuyer = false,
    this.isRecommended = true,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: (json['id'] ?? '').toString(),
        productId: (json['product_id'] ?? json['productId'] ?? '').toString(),
        buyerName: (json['buyer_name'] ?? json['buyerName'] ?? json['reviewer_name'] ?? 'Anonymous').toString(),
        buyerOrg: json['buyer_org'] as String? ?? json['buyerOrg'] as String?,
        rating: (json['rating'] as num?)?.toInt() ?? 5,
        comment: json['comment'] as String?,
        createdAt: DateTime.tryParse(
          json['created_at']?.toString() ?? json['timestamp']?.toString() ?? '',
        ),
        isVerifiedBuyer: json['is_verified_buyer'] as bool? ??
            json['verified'] as bool? ??
            false,
        isRecommended: json['is_recommended'] as bool? ??
            json['isRecommended'] as bool? ??
            true,
      );
}

// ── ClusterModel ──────────────────────────────────────────────
class ClusterModel {
  final String id;
  final String clusterName;
  final String? state;
  final String? district;
  final String? craftSpecialization;
  final int? artisanCount;
  final bool isActive;

  const ClusterModel({
    required this.id,
    required this.clusterName,
    this.state,
    this.district,
    this.craftSpecialization,
    this.artisanCount,
    this.isActive = true,
  });

  factory ClusterModel.fromJson(Map<String, dynamic> json) => ClusterModel(
        id: (json['id'] ?? json['cluster_id'] ?? '').toString(),
        clusterName: (json['cluster_name'] ?? json['name'] ?? '').toString(),
        state: json['state'] as String?,
        district: json['district'] as String?,
        craftSpecialization: json['craft_specialization'] as String?,
        artisanCount: (json['artisan_count'] as num?)?.toInt(),
        isActive: json['is_active'] as bool? ?? true,
      );
}

// ── ExhibitionModel ───────────────────────────────────────────
class ExhibitionModel {
  final String id;
  final String name;
  final String? location;
  final String? dates;
  final String status; // 'register' | 'pending' | 'approved'
  final String? boothNumber;
  final String? imageUrl;
  final String? description;

  const ExhibitionModel({
    required this.id,
    required this.name,
    this.location,
    this.dates,
    required this.status,
    this.boothNumber,
    this.imageUrl,
    this.description,
  });

  factory ExhibitionModel.fromJson(Map<String, dynamic> json) => ExhibitionModel(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        location: json['location'] as String?,
        dates: json['dates'] as String?,
        status: (json['status'] ?? 'register').toString(),
        boothNumber: json['booth_number'] as String? ?? json['booth'] as String?,
        imageUrl: json['image'] as String? ?? json['image_url'] as String?,
        description: json['description'] as String?,
      );
}

// ── GovtSchemeModel ───────────────────────────────────────────
class GovtSchemeModel {
  final String id;
  final String name;
  final String? nameHi;
  final String? description;
  final String? deadline;
  final String? category;
  final String? applyUrl;

  const GovtSchemeModel({
    required this.id,
    required this.name,
    this.nameHi,
    this.description,
    this.deadline,
    this.category,
    this.applyUrl,
  });

  factory GovtSchemeModel.fromJson(Map<String, dynamic> json) => GovtSchemeModel(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        nameHi: json['name_hi'] as String? ?? json['nameHi'] as String?,
        description: json['description'] as String?,
        deadline: json['deadline'] as String?,
        category: json['category'] as String?,
        applyUrl: json['apply_url'] as String?,
      );
}

// ── AppNotificationModel ──────────────────────────────────────
class AppNotificationModel {
  final String id;
  final String type; // 'inquiry' | 'govt-scheme' | 'verification' | 'inventory'
  final String title;
  final String message;
  final DateTime? createdAt;
  final bool isRead;

  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.createdAt,
    this.isRead = false,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
      AppNotificationModel(
        id: (json['id'] ?? '').toString(),
        type: (json['type'] ?? 'inquiry').toString(),
        title: (json['title'] ?? '').toString(),
        message: (json['message'] ?? '').toString(),
        createdAt: DateTime.tryParse(
          json['created_at']?.toString() ?? json['timestamp']?.toString() ?? '',
        ),
        isRead: json['read'] as bool? ?? json['is_read'] as bool? ?? false,
      );

  AppNotificationModel copyWithRead() => AppNotificationModel(
        id: id,
        type: type,
        title: title,
        message: message,
        createdAt: createdAt,
        isRead: true,
      );
}
