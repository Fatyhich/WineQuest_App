import 'dart:convert';

class WineItem {
  final String name;
  final String region;
  final String brand;
  final String taste;
  final String gastronomy;
  final String sugarContent;
  final String country;
  final String price;
  final String color;
  final Map<String, dynamic> rawData;

  WineItem({
    required this.name,
    required this.region,
    required this.brand,
    required this.taste,
    required this.gastronomy,
    required this.sugarContent,
    required this.country,
    required this.price,
    required this.color,
    required this.rawData,
  });

  factory WineItem.fromJson(Map<String, dynamic> json) {
    return WineItem(
      name: json['Название'] ?? '',
      region: json['Регион'] ?? 'Не указано',
      brand: json['Бренд'] ?? '',
      taste: json['Вкус'] ?? '',
      gastronomy: json['Гастрономия'] ?? '',
      sugarContent: json['Содержание сахара'] ?? '',
      country: json['Страна'] ?? '',
      price: json['Цена'] ?? '',
      color: json['Цвет'] ?? '',
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
      // Try to clean up malformed JSON first
      String cleanedJson = _cleanJsonString(jsonString);

      try {
        // Try standard JSON parsing with cleaned JSON
        final Map<String, dynamic> json = jsonDecode(cleanedJson);
        return WineResponse.fromJson(json);
      } catch (e) {
        print('JSON parsing with cleaned data failed: $e');
      }
    } catch (e) {
      print('JSON cleaning failed: $e');
    }

    // If we get here, both standard parsing attempts failed
    print('All JSON parsing attempts failed, using direct extraction');

    // First, try to extract from a rag_response array structure
    try {
      final ragMatch = RegExp(
        r'"rag_response"\s*:\s*\[(.*?)\](?=\s*[,}])',
      ).firstMatch(jsonString);
      if (ragMatch != null) {
        final ragContent = ragMatch.group(1) ?? '';
        items = _extractWineItemsFromArray(ragContent);
        if (items.isNotEmpty) {
          return WineResponse(wineItems: items);
        }
      }
    } catch (e) {
      print('rag_response array extraction failed: $e');
    }

    // Finally, try direct object extraction as a last resort
    try {
      items = _extractWineObjects(jsonString);
    } catch (e) {
      print('Direct object extraction failed: $e');
    }

    return WineResponse(wineItems: items);
  }

  // Clean up common JSON formatting issues
  static String _cleanJsonString(String jsonString) {
    String result = jsonString;

    // Handle single quotes
    result = result.replaceAll("'", '"');

    // Add quotes to unquoted keys
    result = result.replaceAllMapped(
      RegExp(r'([{,])\s*([a-zA-Z0-9_Ёёа-яА-Я]+)\s*:'),
      (match) => '${match.group(1)}"${match.group(2)}":',
    );

    // Fix values that need quotes
    result = result.replaceAllMapped(
      RegExp(r':\s*([a-zA-Z0-9_Ёёа-яА-Я][a-zA-Z0-9_Ёёа-яА-Я\s\-]+)([,}])'),
      (match) => ':"${match.group(1)}"${match.group(2)}',
    );

    return result;
  }

  // Extract wine objects directly, bypassing JSON parsing
  static List<WineItem> _extractWineObjects(String jsonString) {
    List<WineItem> items = [];

    // More flexible pattern to find potential wine objects
    RegExp winePattern = RegExp(r'\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}');
    Iterable<RegExpMatch> matches = winePattern.allMatches(jsonString);

    for (var match in matches) {
      String content = match.group(0) ?? '';

      // Skip objects that are clearly not wine entries
      if (content.contains('job_id') && content.contains('rag_response')) {
        continue;
      }

      try {
        // Extract all potential field values
        Map<String, dynamic> wineData = {};

        // Try multiple patterns for field extraction
        for (var fieldName in [
          'Название',
          'Регион',
          'Бренд',
          'Вкус',
          'Гастрономия',
          'Содержание сахара',
          'Страна',
          'Цена',
          'Цвет',
        ]) {
          String? value = _extractValueImproved(content, fieldName);

          // Handle 'nan' values
          if (value == 'nan' || value == 'null' || value == 'undefined') {
            value = fieldName == 'Регион' ? 'Не указано' : '';
          }

          wineData[fieldName] =
              value ?? (fieldName == 'Регион' ? 'Не указано' : '');
        }

        // Only add if we have at least a name or region
        if ((wineData['Название'] as String).isNotEmpty ||
            wineData['Регион'] != 'Не указано') {
          items.add(WineItem.fromJson(wineData));
        }
      } catch (e) {
        print('Error extracting wine item: $e');
      }
    }

    return items;
  }

  // Extract wine items from a potential array content
  static List<WineItem> _extractWineItemsFromArray(String arrayContent) {
    List<WineItem> items = [];

    // Try to split by commas, accounting for nested objects
    List<String> potentialObjects = _splitArrayItems(arrayContent);

    for (String objContent in potentialObjects) {
      if (objContent.trim().startsWith('{') &&
          objContent.trim().endsWith('}')) {
        try {
          Map<String, dynamic> wineData = {};

          for (var fieldName in [
            'Название',
            'Регион',
            'Бренд',
            'Вкус',
            'Гастрономия',
            'Содержание сахара',
            'Страна',
            'Цена',
            'Цвет',
          ]) {
            String? value = _extractValueImproved(objContent, fieldName);

            if (value == 'nan' || value == 'null' || value == 'undefined') {
              value = fieldName == 'Регион' ? 'Не указано' : '';
            }

            wineData[fieldName] =
                value ?? (fieldName == 'Регион' ? 'Не указано' : '');
          }

          if ((wineData['Название'] as String).isNotEmpty ||
              wineData['Регион'] != 'Не указано') {
            items.add(WineItem.fromJson(wineData));
          }
        } catch (e) {
          print('Error extracting array item: $e');
        }
      }
    }

    return items;
  }

  // Helper to split array items correctly
  static List<String> _splitArrayItems(String arrayContent) {
    List<String> result = [];
    int bracketCount = 0;
    int lastSplit = 0;

    for (int i = 0; i < arrayContent.length; i++) {
      if (arrayContent[i] == '{') {
        bracketCount++;
      } else if (arrayContent[i] == '}') {
        bracketCount--;
      } else if (arrayContent[i] == ',' && bracketCount == 0) {
        result.add(arrayContent.substring(lastSplit, i).trim());
        lastSplit = i + 1;
      }
    }

    // Add the last segment
    if (lastSplit < arrayContent.length) {
      result.add(arrayContent.substring(lastSplit).trim());
    }

    return result;
  }

  // Improved value extraction with multiple patterns
  static String? _extractValueImproved(String content, String fieldName) {
    // Try different delimiter patterns
    List<RegExp> patterns = [
      RegExp('$fieldName\\s*:\\s*"([^"]*)"'), // "fieldName": "value"
      RegExp('$fieldName\\s*:\\s*\'([^\']*)\''), // "fieldName": 'value'
      RegExp('$fieldName\\s*:\\s*([^,}\\[\\]]+)'), // "fieldName": value
      RegExp(
        '[\'"]*$fieldName[\'"]*\\s*:\\s*[\'"]([^\'"]*)[\'"]',
      ), // Quotes on field name
      RegExp(
        '[\'"]*$fieldName[\'"]*\\s*:\\s*([^,}\\[\\]]+)',
      ), // Quotes on field name, unquoted value
    ];

    for (var pattern in patterns) {
      var match = pattern.firstMatch(content);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)?.trim();
      }
    }

    return null;
  }
}
