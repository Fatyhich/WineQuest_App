import 'dart:convert';

class WineItem {
  final String name;
  final String region;
  final String brand;
  final String taste;
  final String gastronomy;
  final Map<String, dynamic> rawData;

  WineItem({
    required this.name,
    required this.region,
    required this.brand,
    required this.taste,
    required this.gastronomy,
    required this.rawData,
  });

  factory WineItem.fromJson(Map<String, dynamic> json) {
    return WineItem(
      name: json['Название'] ?? '',
      region: json['Регион'] ?? 'Не указано',
      brand: json['Бренд'] ?? '',
      taste: json['Вкус'] ?? '',
      gastronomy: json['Гастрономия'] ?? '',
      rawData: json,
    );
  }
}

class WineResponse {
  final List<WineItem> wineItems;

  WineResponse({required this.wineItems});

  factory WineResponse.fromJson(Map<String, dynamic> json) {
    final ragResponse = json['rag_response'];
    if (ragResponse == null || ragResponse is! List) {
      return WineResponse(wineItems: []);
    }

    return WineResponse(
      wineItems: List<WineItem>.from(
        ragResponse.map((item) => WineItem.fromJson(item)),
      ),
    );
  }

  static WineResponse parseResponse(String jsonString) {
    List<WineItem> items = [];

    try {
      // Try standard JSON parsing first
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return WineResponse.fromJson(json);
    } catch (e) {
      print('Standard JSON parsing failed, using direct extraction');

      // Extract all wine entries
      RegExp winePattern = RegExp(r'\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}');
      Iterable<RegExpMatch> matches = winePattern.allMatches(jsonString);

      for (var match in matches) {
        String content = match.group(0) ?? '';

        // Skip the outer JSON object
        if (content.contains('job_id') && content.contains('rag_response')) {
          continue;
        }

        try {
          // Extract the key wine information
          Map<String, dynamic> wineData = {};

          String name = _extractValue(content, 'Название') ?? '';
          String region = _extractValue(content, 'Регион') ?? 'Не указано';
          String brand = _extractValue(content, 'Бренд') ?? '';
          String taste = _extractValue(content, 'Вкус') ?? '';
          String gastronomy = _extractValue(content, 'Гастрономия') ?? '';

          // Remove 'nan' values
          if (name == 'nan') name = '';
          if (region == 'nan') region = 'Не указано';
          if (brand == 'nan') brand = '';
          if (taste == 'nan') taste = '';
          if (gastronomy == 'nan') gastronomy = '';

          // Store the data
          wineData['Название'] = name;
          wineData['Регион'] = region;
          wineData['Бренд'] = brand;
          wineData['Вкус'] = taste;
          wineData['Гастрономия'] = gastronomy;

          // Only add if we have at least a name or region
          if (name.isNotEmpty || region != 'Не указано') {
            items.add(WineItem.fromJson(wineData));
          }
        } catch (e) {
          print('Error extracting wine item: $e');
        }
      }
    }

    return WineResponse(wineItems: items);
  }

  // Helper to extract value for a specific field
  static String? _extractValue(String content, String fieldName) {
    RegExp regex = RegExp('$fieldName: ([^,}]+)');
    var match = regex.firstMatch(content);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!.trim();
    }

    return null;
  }
}
