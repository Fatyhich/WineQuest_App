import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wine_data.dart';
import 'intro_screen.dart';

class ResultScreen extends StatelessWidget {
  final String responseText;

  const ResultScreen({super.key, required this.responseText});

  @override
  Widget build(BuildContext context) {
    WineResponse wineResponse;
    try {
      wineResponse = WineResponse.parseResponse(responseText);
    } catch (e) {
      wineResponse = WineResponse(wineItems: []);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваши рекомендации вин'),
        backgroundColor: Colors.deepPurple[100],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple[50]!, Colors.white],
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'На основе ваших предпочтений мы рекомендуем:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    wineResponse.wineItems.isEmpty
                        ? _buildErrorView()
                        : _buildWineList(wineResponse.wineItems),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const IntroScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Начать заново',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Ошибка обработки рекомендаций',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Необработанный ответ: ${responseText.substring(0, responseText.length > 100 ? 100 : responseText.length)}...',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWineList(List<WineItem> wines) {
    return ListView.builder(
      itemCount: wines.length,
      itemBuilder: (context, index) {
        final wine = wines[index];
        return Card(
          key: ValueKey('wine_${index}'),
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wine.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const Divider(),
                _buildInfoRow(Icons.business, 'Бренд:', wine.brand),
                if (wine.country.isNotEmpty)
                  _buildInfoRow(Icons.flag, 'Страна:', wine.country),
                _buildInfoRow(Icons.location_on, 'Регион:', wine.region),
                if (wine.color.isNotEmpty)
                  _buildInfoRow(Icons.palette, 'Цвет:', wine.color),
                if (wine.sugarContent.isNotEmpty)
                  _buildInfoRow(
                    Icons.cake,
                    'Содержание сахара:',
                    wine.sugarContent,
                  ),
                _buildInfoRow(Icons.wine_bar, 'Вкус:', wine.taste),
                if (wine.price.isNotEmpty)
                  _buildInfoRow(Icons.monetization_on, 'Цена:', wine.price),
                _buildInfoRow(
                  Icons.restaurant,
                  'Гастрономия:',
                  wine.gastronomy,
                ),
              ],
            ),
          ),
        );
      },
      physics: const AlwaysScrollableScrollPhysics(),
      cacheExtent: 500.0,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple[300]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(color: Colors.grey[800], fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
