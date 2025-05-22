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
      region: json['Регион'] ?? '',
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
    // final result = json['result'];
    // if (result == null) {
    //   return WineResponse(wineItems: []);
    // }

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
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return WineResponse.fromJson(json);
    } catch (e) {
      return WineResponse(wineItems: []);
    }
  }
}
