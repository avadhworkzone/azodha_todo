import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  static bool isOnline(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.ethernet);
  }
}
