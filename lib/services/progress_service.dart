import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _prefix = 'topic_progress_';

  /// Get the saved question index for a topic (0-indexed). Defaults to 0.
  static Future<int> getProgress(String topicId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('$_prefix$topicId') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Save the current question index for a topic.
  static Future<void> saveProgress(String topicId, int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_prefix$topicId', index);
    } catch (_) {
      // Ignore storage errors safely
    }
  }

  /// Clear the saved progress when a topic is completed or reset.
  static Future<void> clearProgress(String topicId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefix$topicId');
    } catch (_) {
      // Ignore storage errors safely
    }
  }

  /// Load all active progress entries for a list of topic IDs.
  static Future<Map<String, int>> getAllProgress(List<String> topicIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, int> progressMap = {};
      for (final id in topicIds) {
        final val = prefs.getInt('$_prefix$id');
        if (val != null && val > 0) {
          progressMap[id] = val;
        }
      }
      return progressMap;
    } catch (_) {
      return {};
    }
  }
}
