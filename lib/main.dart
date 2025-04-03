import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  TextEditingController _cityController = TextEditingController();

  String _city = '';
  String _currentWeather = 'Ob-havo ma’lumotlari ko‘rsatiladi';
  List<Map<String, String>> _forecast = [];

  final String apiKey = '4fbcaea02da3f8d21a4ac27cfc5dca4c';

  Future<void> fetchWeather(String cityName) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _city = data['name'];
          _currentWeather =
              '${data['weather'][0]['description']}, ${data['main']['temp']}°C';
        });
      } else {
        setState(() {
          _currentWeather = 'Xato: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _currentWeather = 'Ma’lumot olishda xatolik yuz berdi';
      });
    }
  }

  Future<void> fetchForecast(String cityName) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<Map<String, String>> tempForecast = [];

        for (int i = 0; i < data['list'].length; i += 8) {
          final day = data['list'][i];
          tempForecast.add({
            "date": day['dt_txt'].split(" ")[0],
            "weather": day['weather'][0]['description'],
            "temp": "${day['main']['temp']}°C",
          });
        }

        setState(() {
          _forecast = tempForecast;
        });
      } else {
        setState(() {
          _forecast = [
            {
              "date": "",
              "weather": "Xato: ${response.reasonPhrase}",
              "temp": "",
            },
          ];
        });
      }
    } catch (e) {
      setState(() {
        _forecast = [
          {
            "date": "",
            "weather": "Ma’lumot olishda xatolik yuz berdi",
            "temp": "",
          },
        ];
      });
    }
  }

  void _getWeatherData() {
    String city = _cityController.text;
    if (city.isNotEmpty) {
      fetchWeather(city);
      fetchForecast(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(246, 26, 59, 247),
        title: Text(
          'Ob-havo Ilovasiga xush kelibsiz!',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Shahar nomini kiriting >>>',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _getWeatherData,
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_city shahridagi ob-havo:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _currentWeather,
                      style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '5 kunlik ob-havo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Expanded(
              child:
                  _forecast.isEmpty
                      ? Center(child: Text("Ma’lumot mavjud emas"))
                      : ListView.builder(
                        itemCount: _forecast.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.wb_sunny,
                                color: Colors.orange,
                              ),
                              title: Text(
                                _forecast[index]["date"] ?? "",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(_forecast[index]["weather"] ?? ""),
                              trailing: Text(
                                _forecast[index]["temp"] ?? "",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
