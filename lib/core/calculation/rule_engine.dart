import 'dart:convert';

class RuleEngine {
  Map<String, dynamic> _rules = {};

  /// Parse the dynamic configuration rules payload from string
  Future<void> loadRules(String jsonString) async {
    try {
      _rules = json.decode(jsonString);
    } catch (e) {
      _rules = {};
    }
  }

  /// Get the minimum app binary version required to run
  String get minimumCompatibleVersion => _rules['minimum_compatible_version'] ?? '1.0.0';

  /// Android target Play Store update URL
  String? get androidUpdateUrl => _rules['store_update_url']?['android'];

  /// iOS target App Store update URL
  String? get iosUpdateUrl => _rules['store_update_url']?['ios'];

  /// Verifies whether an entry triggers the Antigravity inverted accounting model
  bool isAntigravity(String accountId, String category, List<String> tags) {
    if (_rules.isEmpty || _rules['rules'] == null) return false;

    final rules = _rules['rules'];

    final accounts = List<String>.from(rules['antigravity_accounts'] ?? []);
    final categories = List<String>.from(rules['antigravity_categories'] ?? []);
    final configTags = List<String>.from(rules['antigravity_tags'] ?? []);

    // Exact account match
    if (accounts.contains(accountId)) return true;

    // Normalised lowercase matching for categories & tags
    final normalizedCategory = category.toLowerCase().trim();
    if (categories.contains(normalizedCategory)) return true;

    for (final tag in tags) {
      if (configTags.contains(tag.toLowerCase().trim())) {
        return true;
      }
    }

    return false;
  }
}
