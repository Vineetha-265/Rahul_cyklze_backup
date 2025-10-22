import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Utility class to check for network and internet connectivity.
class NetworkUtils {
  /// Returns true if the device is connected to a network
  /// **and** can actually reach the internet.
  static Future<bool> isNetworkAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    // No WiFi/Cellular connection
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    // Sometimes device is connected to WiFi but no internet.
    final hasInternet = await InternetConnectionChecker().hasConnection;
    return hasInternet;
  }

  /// Stream of connectivity changes.
  /// Emits true when online, false when offline.
  static Stream<bool> get onNetworkStatusChange async* {
    await for (final result in Connectivity().onConnectivityChanged) {
      if (result == ConnectivityResult.none) {
        yield false;
      } else {
        final hasInternet = await InternetConnectionChecker().hasConnection;
        yield hasInternet;
      }
    }
  }
}
