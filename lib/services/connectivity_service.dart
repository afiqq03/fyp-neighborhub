import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:logging/logging.dart';

class ConnectivityService {
  final Logger _logger = Logger('ConnectivityService');
  final InternetConnectionChecker _connectionChecker = InternetConnectionChecker.createInstance(
    checkTimeout: const Duration(seconds: 5),
    checkInterval: const Duration(seconds: 5),
  );
  final StreamController<bool> _connectionChangeController = StreamController<bool>.broadcast();
  
  Stream<bool> get connectionChange => _connectionChangeController.stream;
  bool _hasConnection = true;

  ConnectivityService() {
    // Initialize with current status
    checkConnection().then((hasConnection) {
      _hasConnection = hasConnection;
      _connectionChangeController.add(hasConnection);
    });

    // Listen for changes
    _connectionChecker.onStatusChange.listen((status) {
      final hasConnection = status == InternetConnectionStatus.connected;
      if (hasConnection != _hasConnection) {
        _hasConnection = hasConnection;
        _logger.info('Internet connection status changed: ${hasConnection ? 'Connected' : 'Disconnected'}');
        _connectionChangeController.add(hasConnection);
      }
    });
  }

  Future<bool> checkConnection() async {
    final result = await _connectionChecker.hasConnection;
    _logger.info('Internet connection check: ${result ? 'Connected' : 'Disconnected'}');
    return result;
  }

  void dispose() {
    _connectionChangeController.close();
  }
}