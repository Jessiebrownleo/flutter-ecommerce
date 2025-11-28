import 'package:flutter/foundation.dart' show kIsWeb;

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    // On web, we assume connection is available
    // The HTTP requests will fail if there's no connection
    if (kIsWeb) {
      return true;
    }
    
    // For mobile/desktop, you could implement actual connection checking
    // For now, we'll assume connected
    return true;
  }
}
