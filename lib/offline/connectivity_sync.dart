import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'outbox_service.dart';

class ConnectivitySync {
  final OutboxService _outbox;
  StreamSubscription? _sub;

  ConnectivitySync(this._outbox);

  void start() {
    _sub = Connectivity().onConnectivityChanged.listen((result) async {
      final online =
          result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi);
      if (online) {
        await _outbox.processPending(batch: 20);
      }
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
