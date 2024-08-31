import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safetravelfrontend/providers/user_provider.dart';

class WeatherScreen extends StatefulWidget {
  final String destination;

  WeatherScreen({required this.destination});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<void>? _fetchWeatherFuture;

  @override
  void initState() {
    super.initState();
    _fetchWeatherFuture = Provider.of<UserProvider>(context, listen: false)
        .fetchWeatherNews(widget.destination, null, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/target.png',
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        widget.destination,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder<void>(
              future: _fetchWeatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (userProvider.error != null) {
                      return Center(
                          child: Text('Error: ${userProvider.error}'));
                    }

                    final forecasts = userProvider.weatherNews?['forecast']
                        as List<dynamic>?;

                    if (forecasts == null || forecasts.isEmpty) {
                      return Center(child: Text('No weather data available.'));
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '5 Days Forecast:',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                    color: Colors.black26, offset: Offset(2, 2))
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          ...forecasts.map((forecast) {
                            final avgTempC =
                                double.tryParse(forecast['avgTempC']) ?? 0.0;
                            // Select the image based on avgTempC value
                            String imagePath;
                            if (avgTempC <= 0) {
                              imagePath = 'assets/images/clouds5.png'; // Snow
                            } else if (avgTempC > 0 && avgTempC <= 10) {
                              imagePath =
                                  'assets/images/clouds4.png'; // Rain with Sun
                            } else if (avgTempC > 10 && avgTempC <= 20) {
                              imagePath = 'assets/images/clouds1.png'; // Sun and normal clouds
                            } else if (avgTempC > 20 && avgTempC <= 30) {
                              imagePath = 'assets/images/clouds3.png'; // Sun only
                            } else {
                              imagePath = 'assets/images/clouds3.png'; // Sun with dark clouds
                            }

                            return WeatherRow(
                              imagePath: imagePath,
                              temperature: '${forecast['avgTempC']}°C',
                              day: forecast['time'],
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherRow extends StatelessWidget {
  final String imagePath;
  final String temperature;
  final String day;

  const WeatherRow({
    required this.imagePath,
    required this.temperature,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 40,
            height: 40,
          ),
          SizedBox(width: 16),
          Text(
            temperature,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1))],
            ),
          ),
          Spacer(),
          Text(
            day,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1))],
            ),
          ),
        ],
      ),
    );
  }
}
