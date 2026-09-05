import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'draft_storage_service.dart';

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final draftService = ref.read(draftStorageServiceProvider);
  return OfflineSyncService(draftService);
});

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((results) =>
      results.isNotEmpty ? results.first : ConnectivityResult.none);
});

/// Monitors connectivity and auto-syncs offline outbox queue when network returns
class OfflineSyncService {
  final DraftStorageService _draftService;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = false;

  OfflineSyncService(this._draftService);

  bool get isOnline => _isOnline;

  void startMonitoring(Function(ProductDraft) onSyncCallback) {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.any(
        (r) => r == ConnectivityResult.wifi ||
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.ethernet,
      );

      if (!_isOnline && isConnected) {
        // Just came online — trigger sync
        _isOnline = true;
        _syncPendingQueue(onSyncCallback);
      } else {
        _isOnline = isConnected;
      }
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<bool> checkIsOnline() async {
    final result = await Connectivity().checkConnectivity();
    _isOnline = result.any(
      (r) => r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet,
    );
    return _isOnline;
  }

  Future<void> _syncPendingQueue(Function(ProductDraft) onSyncCallback) async {
    final queue = await _draftService.loadOfflineQueue();
    for (final draft in queue) {
      onSyncCallback(draft);
    }
  }
}
