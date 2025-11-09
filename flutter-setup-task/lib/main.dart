import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDark;
  late IconData _toggleThemeButtonIcon;

  @override
  void initState() {
    super.initState();
    _isDark = false;
    _toggleThemeButtonIcon = Icons.light_mode;
  }

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;

      if (_isDark) {
        _toggleThemeButtonIcon = Icons.dark_mode;
      } else {
        _toggleThemeButtonIcon = Icons.light_mode;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Погода',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          surface: const Color.fromARGB(255, 193, 227, 255),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          titleTextStyle: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          iconTheme: IconThemeData(color: Colors.amber),
          surfaceTintColor: Colors.transparent,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          bodyLarge: TextStyle(
              fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
          bodySmall: TextStyle(fontSize: 20, color: Colors.black),
        ),
        iconTheme: const IconThemeData(
          size: 40,
          color: Colors.blue,
        ),
        cardTheme: const CardThemeData(color: Colors.white),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.white, foregroundColor: Colors.black),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          surface: const Color.fromARGB(255, 32, 32, 32),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 25, 25, 25),
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 200, 200, 200),
          ),
          iconTheme: IconThemeData(color: Colors.grey),
          surfaceTintColor: Colors.transparent,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 200, 200, 200),
          ),
          bodyLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 200, 200, 200),
          ),
          bodySmall: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 200, 200, 200),
          ),
        ),
        iconTheme: const IconThemeData(
          size: 40,
          color: Color.fromARGB(255, 94, 169, 230),
        ),
        cardTheme: const CardThemeData(color: Color.fromARGB(255, 64, 64, 64)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 64, 64, 64),
          foregroundColor: Color.fromARGB(255, 200, 200, 200),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromARGB(255, 94, 169, 230),
        ),
        useMaterial3: true,
      ),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Погода',
          ),
          actions: [
            IconButton(
              onPressed: _toggleTheme,
              icon: Icon(_toggleThemeButtonIcon),
            )
          ],
        ),
        body: const WeatherScreen(),
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  static const List<String> _cities = [
    "Moscow",
    "Paris",
    "London",
    "Zapadnaya Dvina"
  ];
  late List<Future<Map<String, dynamic>>?> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _refreshWeather();
  }

  Future<Map<String, dynamic>> _fetchWeather(String city) async {
    try {
      final response =
          await http.get(Uri.parse("https://wttr.in/$city?format=j1"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw HttpException("Ststus code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Did not manage to get data. $e");
    }
  }

  void _refreshWeather() {
    _weatherFuture = _cities.map((city) => _fetchWeather(city)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                  itemCount: _cities.length,
                  itemBuilder: (context, index) {
                    return WeatherCard(
                        weatherFuture: _weatherFuture, index: index);
                  }),
              Positioned(
                bottom: 25,
                right: 25,
                child: FloatingActionButton(
                  onPressed: () => setState(() {
                    _refreshWeather();
                  }),
                  child: const Icon(Icons.refresh),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WeatherCard extends StatelessWidget {
  final List<Future<Map<String, dynamic>>?> _weatherFuture;
  final int _index;

  const WeatherCard(
      {super.key,
      required List<Future<Map<String, dynamic>>?> weatherFuture,
      required int index})
      : _weatherFuture = weatherFuture,
        _index = index;

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('sunny') || desc.contains('clear')) {
      return Icons.wb_sunny;
    } else if (desc.contains('cloudy') || desc.contains('overcast')) {
      return Icons.cloud;
    } else if (desc.contains('rain') || desc.contains('drizzle')) {
      return Icons.grain;
    } else if (desc.contains('snow')) {
      return Icons.ac_unit;
    } else if (desc.contains('fog') || desc.contains('mist')) {
      return Icons.filter_drama;
    } else if (desc.contains('thunder')) {
      return Icons.flash_on;
    } else {
      return Icons.wb_cloudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: FutureBuilder(
            future: _weatherFuture[_index],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) return const Text("Ошибка");
              if (snapshot.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.data!["nearest_area"][0]["areaName"][0]["value"],
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getWeatherIcon(snapshot.data!['current_condition'][0]
                              ['weatherDesc'][0]['value']),
                        ),
                        Text(
                          " ${snapshot.data!['current_condition'][0]['temp_C']} °C",
                          style: Theme.of(context).textTheme.bodyLarge,
                        )
                      ],
                    ),
                    Text(
                      snapshot.data!['current_condition'][0]['lang_ru'][0]
                          ['value'],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              }
              throw Exception("Snapshot condition error");
            },
          ),
        ),
      ),
    );
  }
}
