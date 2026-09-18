import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityNotifier extends StateNotifier<bool> {
  late final StreamSubscription<List<ConnectivityResult>> _sub;

  ConnectivityNotifier() : super(true) {
    // Check immediately on start
    _checkNow();
    // Then listen for changes
    _sub = Connectivity().onConnectivityChanged.listen(_onChanged);
  }

  Future<void> _checkNow() async {
    final results = await Connectivity().checkConnectivity();
    state = _isOnline(results);
  }

  void _onChanged(List<ConnectivityResult> results) {
    state = _isOnline(results);
  }

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// true  = online
/// false = offline
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});
