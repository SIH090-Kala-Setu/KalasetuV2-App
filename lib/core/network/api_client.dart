import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/models.dart';
import 'api_endpoints.dart';
import 'dio_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

class ApiClient {
  final Dio _dio;
  ApiClient(this._dio);

  // ── Auth ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'username': username, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<UserModel> register({
    required String username,
    required String password,
    required String role,
    String? fullName,
    String? preferredLang,
    String? craftType,
    String? region,
    String? district,
    String? aadhaarNumber,
  }) async {
    final response = await _dio.post(ApiEndpoints.register, data: {
      'username': username,
      'password': password,
      'role': role,
      if (fullName != null) 'full_name': fullName,
      'preferred_lang': preferredLang ?? 'hi',
      if (craftType != null) 'craft_type': craftType,
      if (region != null) 'region': region,
      if (district != null) 'district': district,
      if (aadhaarNumber != null) 'aadhaar_number': aadhaarNumber,
    });
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> sendOtp(String phone) async {
    await _dio.post(ApiEndpoints.sendOtp, data: {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final response = await _dio.post(
      ApiEndpoints.verifyOtp,
      data: {'phone': phone, 'otp': otp},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> registerFcmToken(String token) async {
    await _dio.post(ApiEndpoints.fcmToken, data: {'fcm_token': token});
  }

  // ── AI Studio ─────────────────────────────────────────────────

  Future<Uint8List> enhanceImage({
    File? imageFile,
    Uint8List? imageBytes,
    String filename = 'product.jpg',
  }) async {
    MultipartFile filePart;
    if (imageBytes != null) {
      filePart = MultipartFile.fromBytes(imageBytes, filename: filename);
    } else if (imageFile != null) {
      filePart = MultipartFile.fromBytes(
        await imageFile.readAsBytes(),
        filename: imageFile.path.split(Platform.pathSeparator).last,
      );
    } else {
      throw ArgumentError('imageBytes or imageFile required');
    }
    final response = await _dio.post(
      ApiEndpoints.enhance,
      data: FormData.fromMap({'file': filePart}),
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data as List<int>);
  }

  Future<ProductCatalogGenerated> generateCatalog({
    File? audioFile,
    String? textDesc,
    String lang = 'Hindi',
  }) async {
    final map = <String, dynamic>{'lang': lang};
    if (audioFile != null) {
      map['audio'] = await MultipartFile.fromFile(audioFile.path);
    }
    if (textDesc != null) map['text_desc'] = textDesc;
    final response = await _dio.post(
      ApiEndpoints.catalog,
      data: FormData.fromMap(map),
    );
    return ProductCatalogGenerated.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProductCatalogGenerated> generateCatalogFromImage(Uint8List bytes) async {
    final response = await _dio.post(
      ApiEndpoints.catalogVision,
      data: FormData.fromMap({
        'image': MultipartFile.fromBytes(bytes, filename: 'product.jpg'),
      }),
    );
    return ProductCatalogGenerated.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PriceBreakdownModel> suggestPrice({
    required String category,
    required double materialCost,
    double manufacturingHours = 4.0,
    String productDescription = '',
    Uint8List? imageBytes,
    String? regionState,
    int? artisanExperienceYrs,
    int? productComplexity,
    bool? giTagCertified,
    int? bulkOrderQty,
    String? materialType,
  }) async {
    final map = <String, dynamic>{
      'category': category,
      'material_cost': materialCost,
      'manufacturing_hours': manufacturingHours,
      'product_description': productDescription,
      if (regionState != null) 'region_state': regionState,
      if (artisanExperienceYrs != null) 'artisan_experience_yrs': artisanExperienceYrs,
      if (productComplexity != null) 'product_complexity': productComplexity,
      if (giTagCertified != null) 'gi_tag_certified': giTagCertified,
      if (bulkOrderQty != null) 'bulk_order_qty': bulkOrderQty,
      if (materialType != null) 'material_type': materialType,
      if (imageBytes != null)
        'image': MultipartFile.fromBytes(imageBytes, filename: 'product.jpg'),
    };
    final response = await _dio.post(
      ApiEndpoints.suggestPrice,
      data: FormData.fromMap(map),
    );
    return PriceBreakdownModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Products ──────────────────────────────────────────────────

  Future<List<ProductModel>> getProducts({
    String? search,
    String? category,
    String? region,
    double? minPrice,
    double? maxPrice,
    int limit = 40,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{'limit': limit, 'offset': offset};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category.isNotEmpty && category != 'All') {
      params['category'] = category;
    }
    if (region != null && region.isNotEmpty) params['region'] = region;
    if (minPrice != null) params['min_price'] = minPrice;
    if (maxPrice != null) params['max_price'] = maxPrice;

    final response = await _dio.get(ApiEndpoints.products, queryParameters: params);
    final list = response.data as List<dynamic>;
    return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProductModel> getProductDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.productDetail(id));
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProductModel> createProduct({
    required String titleEn,
    required String titleHi,
    String? descriptionEn,
    String? descriptionHi,
    required String category,
    List<String>? materials,
    List<String>? tags,
    required double retailPrice,
    required double b2bPrice,
    int stock = 10,
    String? imageUrl,
  }) async {
    final response = await _dio.post(ApiEndpoints.products, data: {
      'title_en': titleEn,
      'title_hi': titleHi,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (descriptionHi != null) 'description_hi': descriptionHi,
      'category': category,
      'materials': materials ?? [],
      'tags': tags ?? [],
      'retail_price': retailPrice,
      'b2b_price': b2bPrice,
      'stock': stock,
      if (imageUrl != null) 'image_url': imageUrl,
    });
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateProductStatus(String id, String status) async {
    await _dio.put(
      ApiEndpoints.productStatus(id),
      data: FormData.fromMap({'status': status}),
    );
  }

  Future<void> updateProductStock(String id, int stock) async {
    await _dio.put(
      ApiEndpoints.productStock(id),
      data: FormData.fromMap({'stock_count': stock}),
    );
  }

  Future<void> updateProductPrice(String id, double basePrice, {double? suggestedPrice}) async {
    await _dio.put(
      ApiEndpoints.productPrice(id),
      data: FormData.fromMap({
        'base_price': basePrice,
        if (suggestedPrice != null) 'suggested_price': suggestedPrice,
      }),
    );
  }

  Future<Uint8List> getProductQr(String id) async {
    final response = await _dio.get(
      ApiEndpoints.productQr(id),
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data as List<int>);
  }

  Future<void> deleteProduct(String id) async {
    await _dio.delete(ApiEndpoints.productDetail(id));
  }

  Future<List<ReviewModel>> getProductReviews(String productId) async {
    final response = await _dio.get(ApiEndpoints.productReviews(productId));
    final list = response.data as List<dynamic>;
    return list.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ReviewModel> createProductReview({
    required String productId,
    required int rating,
    String? comment,
    String? reviewerName,
    bool isRecommended = true,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.productReviews(productId),
      data: {
        'rating': rating,
        'comment': comment ?? '',
        if (reviewerName != null) 'reviewer_name': reviewerName,
        'is_recommended': isRecommended,
      },
    );
    return ReviewModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Inquiries ─────────────────────────────────────────────────

  Future<List<InquiryModel>> getInquiries() async {
    final response = await _dio.get(ApiEndpoints.inquiries);
    final list = response.data as List<dynamic>;
    return list.map((e) => InquiryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<InquiryModel> createInquiry({
    required String productId,
    required String buyerName,
    required String buyerEmail,
    required int quantity,
    String? notes,
  }) async {
    final response = await _dio.post(ApiEndpoints.inquiries, data: {
      'product_id': productId,
      'buyer_name': buyerName,
      'buyer_email': buyerEmail,
      'quantity': quantity,
      if (notes != null) 'notes': notes,
    });
    return InquiryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> respondToInquiry(String id, String message) async {
    await _dio.post(
      ApiEndpoints.respondInquiry(id),
      data: FormData.fromMap({'response_message': message}),
    );
  }

  // ── Artisan ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> getArtisanDashboard() async {
    final response = await _dio.get(ApiEndpoints.artisanDashboard);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getArtisanProfile() async {
    final response = await _dio.get(ApiEndpoints.artisanProfile);
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateArtisanProfile(Map<String, dynamic> data) async {
    await _dio.put(ApiEndpoints.artisanProfile, data: data);
  }

  Future<Map<String, dynamic>> getArtisanPortfolio(String artisanId) async {
    final response = await _dio.get(ApiEndpoints.artisanPortfolio(artisanId));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getArtisanAnalytics() async {
    final response = await _dio.get(ApiEndpoints.artisanAnalytics);
    return response.data as Map<String, dynamic>;
  }

  Future<String> getArtisanReport() async {
    final response = await _dio.get(ApiEndpoints.artisanReport);
    return response.data.toString();
  }

  // ── Aggregator ────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAggregatorDashboard() async {
    final response = await _dio.get(ApiEndpoints.aggregatorDashboard);
    return response.data as Map<String, dynamic>;
  }

  Future<List<UserModel>> getAggregatorArtisans({String? search}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final response = await _dio.get(
      ApiEndpoints.aggregatorArtisans,
      queryParameters: params.isNotEmpty ? params : null,
    );
    final raw = response.data;
    final list = (raw is List ? raw : (raw as Map)['artisans'] as List?) ?? [];
    return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> onboardArtisan({
    required String fullName,
    required String phone,
    required String craftType,
    String? clusterName,
    String preferredLanguage = 'hi',
  }) async {
    await _dio.post(ApiEndpoints.aggregatorOnboard, data: {
      'full_name': fullName,
      'phone': phone,
      'craft_type': craftType,
      if (clusterName != null) 'cluster_name': clusterName,
      'preferred_language': preferredLanguage,
    });
  }

  Future<void> relayScheme({
    required String schemeId,
    required String targetState,
    required String targetCraft,
  }) async {
    await _dio.post(ApiEndpoints.aggregatorRelayScheme, data: {
      'scheme_id': schemeId,
      'target_state': targetState,
      'target_craft': targetCraft,
    });
  }

  Future<void> submitClusterReport({
    required String clusterId,
    required String reportMonth,
    required String summary,
  }) async {
    await _dio.post(ApiEndpoints.aggregatorSubmitReport, data: {
      'cluster_id': clusterId,
      'report_month': reportMonth,
      'summary': summary,
    });
  }

  Future<List<ClusterModel>> getClusters() async {
    final response = await _dio.get(ApiEndpoints.clusters);
    final list = response.data as List<dynamic>;
    return list.map((e) => ClusterModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ClusterModel>> getMyClusters() async {
    final response = await _dio.get(ApiEndpoints.myClusters);
    final list = response.data as List<dynamic>;
    return list.map((e) => ClusterModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ClusterModel> createCluster({
    required String clusterName,
    required String state,
    required String district,
    String craftSpecialization = 'General Crafts',
  }) async {
    final response = await _dio.post(ApiEndpoints.clusters, data: {
      'cluster_name': clusterName,
      'state': state,
      'district': district,
      'craft_specialization': craftSpecialization,
    });
    return ClusterModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Buyer ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getBuyerDashboard() async {
    final response = await _dio.get(ApiEndpoints.buyerDashboard);
    return response.data as Map<String, dynamic>;
  }

  // ── Exhibitions & Schemes ─────────────────────────────────────

  Future<List<ExhibitionModel>> getExhibitions() async {
    final response = await _dio.get(ApiEndpoints.exhibitions);
    final list = response.data as List<dynamic>;
    return list.map((e) => ExhibitionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> registerForExhibition(String id) async {
    await _dio.post(ApiEndpoints.registerExhibition(id));
  }

  Future<List<GovtSchemeModel>> getSchemes() async {
    final response = await _dio.get(ApiEndpoints.schemes);
    final list = response.data as List<dynamic>;
    return list.map((e) => GovtSchemeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Notifications ─────────────────────────────────────────────

  Future<List<AppNotificationModel>> getNotifications() async {
    final response = await _dio.get(ApiEndpoints.notifications);
    final list = response.data as List<dynamic>;
    return list.map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markNotificationRead(String id) async {
    await _dio.put(ApiEndpoints.markNotificationRead(id));
  }

  Future<void> markAllNotificationsRead() async {
    await _dio.put(ApiEndpoints.markAllNotificationsRead);
  }
}
