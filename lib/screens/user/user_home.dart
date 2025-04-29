import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/model/menu_model.dart';
import 'package:staff_ease/model/weather_model.dart';
import 'package:staff_ease/screens/user/food_list_screen.dart';
import 'package:staff_ease/screens/user/user_notification_screen.dart';
import 'package:staff_ease/services/auth.dart';
import 'package:staff_ease/widgets/reminder.dart';
import 'package:staff_ease/widgets/user_widgets/menubar_user.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  String name = "";
  int dayOffCount = 0;

  final List<String> _city = [
    "Aydın",
    "Ankara",
    "Adana",
    "Denizli",
    "İstanbul",
    "Kocaeli",
  ];
  String _selectedCity = "Aydın";
  Future<WeatherModel>? weatherFuture;
  WeatherModel? initialWeatherData;

  @override
  void initState() {
    super.initState();
    print("initstate çalıştı");
    _loadUsername();
    getWeather(_selectedCity).then((value) {
      setState(() {
        initialWeatherData = value;
        weatherFuture = Future.value(value);
      });
    });
    _loadDayOffCount();
  }

  void _loadUsername() async {
    String? user = await Auth().getUserName();

    setState(() {
      name = user ?? "User";
    });
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5',
      queryParameters: {
        "appid": '5bfb51930e1c84dc522cdb3da330d185',
        "lang": 'tr',
        "units": "metric",
      },
    ),
  );

  Future<WeatherModel> getWeather(String selectedCity) async {
    final response = await dio.get(
      '/weather',
      queryParameters: {"q": selectedCity},
    );
    var model = WeatherModel.fromJson(response.data);
    debugPrint(model.main?.temp.toString());
    return model;
  }

  Future<MenuItem> getTodayMenu() async {
    final String response = await rootBundle.loadString('assets/menu.json');
    final data = json.decode(response);
    final List list = data['gunluk_menu'];

    int todayIndex = DateTime.now().day - 1; // Bugünün indexini al

    if (todayIndex >= 0 && todayIndex < list.length) {
      return MenuItem.fromJson(list[todayIndex]);
    } else {
      return MenuItem(
        gun: "-",
        corba: "-",
        anaYemek: "-",
        karbonhidrat: "-",
        yanci: "-",
      );
    }
  }

  String getTodayName() {
    final now = DateTime.now();
    const days = [
      "Pazartesi",
      "Salı",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar",
    ];
    return days[now.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarUserHome(context)),
      drawer: menuBarUser(context),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              weatherContainer(),
              dailyFoodMenuContainer(),
              permissionContainer(),
              Reminder.Reminder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget dailyFoodMenuContainer() {
    return FutureBuilder<MenuItem>(
      future: getTodayMenu(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Hata: ${snapshot.error}");
        } else if (!snapshot.hasData) {
          return Text("Bugün için menü bulunamadı.");
        }

        final menu = snapshot.data!;
        final dayName = getTodayName();

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FoodListScreen()),
              );
            },
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                border: Border.all(
                  color: const Color.fromARGB(255, 157, 155, 161),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    "Günün Menüsü - ${dayName}",
                    style: GoogleFonts.poppins(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text("Çorba: ${menu.corba}", style: TextStyle(fontSize: 18)),
                  Text(
                    "Ana Yemek: ${menu.anaYemek}",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    "Karbonhidrat: ${menu.karbonhidrat}",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    "Yan Ürün: ${menu.yanci}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget weatherContainer() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: const Color.fromARGB(255, 157, 155, 161),
            width: 2,
          ),
        ),
        width: 400,
        height: 320,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Hava Durumu ",
                        style: GoogleFonts.poppins(fontSize: 24),
                      ),
                      SizedBox(width: 10),
                      dropdownButtonCity(),
                    ],
                  ),
                  Container(
                    child: Column(
                      children: [
                        FutureBuilder<WeatherModel>(
                          future: weatherFuture,
                          initialData: initialWeatherData,
                          builder: (
                            BuildContext context,
                            AsyncSnapshot snapshot,
                          ) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            }
                            if (snapshot.hasData) {
                              return buildWeatherCard(snapshot.data!);
                            }
                            return SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWeatherCard(WeatherModel weatherModel) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(weatherModel.name!, style: GoogleFonts.poppins(fontSize: 24)),
            Text(
              weatherModel.main!.temp!.round().toString() + "°",
              style: GoogleFonts.poppins(fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              weatherModel.weather![0].description ?? 'Değer Bulunamadı',
              style: GoogleFonts.poppins(fontSize: 24),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Icon(Icons.water_drop, size: 30),
                    Text(
                      weatherModel.main!.humidity!.round().toString(),
                      style: GoogleFonts.poppins(fontSize: 20),
                    ),
                  ],
                ),
                SizedBox(width: 32),
                Column(
                  children: [
                    Icon(Icons.air, size: 30),
                    Text(
                      weatherModel.wind!.speed!.round().toString(),
                      style: GoogleFonts.poppins(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DropdownButton<String> dropdownButtonCity() {
    return DropdownButton<String>(
      value: _selectedCity,
      items:
          _city.map((String city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(
                city,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: const Color.fromARGB(255, 57, 15, 129),
                ),
              ),
            );
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCity = newValue!;
          weatherFuture = getWeather(_selectedCity);
        });
      },
      hint: Text("Bir şehir seçin"),
    );
  }

  Widget permissionContainer() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserHome()),
          );
        },
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(
              color: const Color.fromARGB(255, 157, 155, 161),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text("İzinleriniz:", style: GoogleFonts.poppins(fontSize: 20)),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Kalan izin",
                          style: GoogleFonts.josefinSans(fontSize: 20),
                        ),
                        Card(
                          child: Text(
                            "${dayOffCount}",
                            style: GoogleFonts.josefinSans(fontSize: 30),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "Alınan İzin",
                          style: GoogleFonts.josefinSans(fontSize: 20),
                        ),
                        Card(
                          child: Text(
                            "${15 - dayOffCount}",
                            style: GoogleFonts.josefinSans(fontSize: 30),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  myAppBarUserHome(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 60),
        Text(
          "Hoşgeldin ${name.isNotEmpty ? name : "Kullanıcı"}",
          style: GoogleFonts.poppins(color: Colors.black),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserNotificationScreen(),
                ),
              );
            },
            icon: Icon(Icons.notifications, size: 40, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Future<void> _loadDayOffCount() async {
    int count = await Auth().getDayOffCount();
    setState(() {
      dayOffCount = count;
    });
  }
}
