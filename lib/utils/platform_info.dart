// Platform detector untuk conditional import
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformInfo {
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !kIsWeb;
}
