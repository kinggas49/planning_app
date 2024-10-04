import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'tambah_tour.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? _user;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<int> _years = List.generate(100, (index) => 2000 + index);

  String _selectedMonth = 'January';
  int _selectedYear = DateTime.now().year;
  int? _selectedDay;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _checkUser();
    _loadSelectedDate();
    _initializeNotifications();
  }

  Future<void> _checkUser() async {
    User? user = _auth.currentUser;
    setState(() {
      _user = user;
    });
  }

  Future<void> _loadSelectedDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedMonth = prefs.getString('selectedMonth') ?? 'January';
      _selectedYear = prefs.getInt('selectedYear') ?? DateTime.now().year;
      int? savedDay = prefs.getInt('selectedDay');
      _selectedDay = savedDay == -1 ? null : savedDay;
    });
  }

  Future<void> _saveSelectedDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedMonth', _selectedMonth);
    prefs.setInt('selectedYear', _selectedYear);
    prefs.setInt('selectedDay', _selectedDay ?? -1);
  }

  void _initializeNotifications() {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _scheduleNotification(DateTime startDate, String tourTitle) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Tour Reminder',
      'Your tour "$tourTitle" starts today!',
      tz.TZDateTime.from(startDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  int _daysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  Stream<QuerySnapshot> _getTours() {
    return _firestore.collection('tours').where('user', isEqualTo: _user?.uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCAD2C5), // Light background color
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text('TOURWINDER', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color : const Color(0xFF2F3E46)),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Good Morning',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        Text(
                          _user != null ? _user!.displayName ?? 'Hello' : 'Hello',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddTourScreen()),
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.black),
                      label: const Text('Add tour', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // Background color
                        side: const BorderSide(color: Colors.black, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color:const Color(0xFF2F3E46)),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: DropdownButton<String>(
                      value: _selectedMonth,
                      items: _months.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMonth = newValue!;
                          _saveSelectedDate();
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF2F3E46)),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Align(
                      alignment: Alignment.centerRight, // Aligns the DropdownButton to the right
                      child: DropdownButton<int>(
                        value: _selectedYear,
                        items: _years.map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Container(
                              decoration: BoxDecoration(
                               
                                borderRadius: BorderRadius.circular(12)
                              ),
                              
                              
                              
                              
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(value.toString()),
                              )),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedYear = newValue!;
                            _saveSelectedDate();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CalendarWidget(
                month: _months.indexOf(_selectedMonth) + 1,
                year: _selectedYear,
                daysInMonth: _daysInMonth(_months.indexOf(_selectedMonth) + 1, _selectedYear),
                selectedDay: _selectedDay,
                onDaySelected: (day) {
                  setState(() {
                    _selectedDay = day;
                    _saveSelectedDate();
                  });
                },
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: _getTours(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final tours = snapshot.data!.docs;
                  List<Widget> tourWidgets = [];
                  DateTime? selectedDate;
                  if (_selectedDay != null) {
                    selectedDate = DateTime(_selectedYear, _months.indexOf(_selectedMonth) + 1, _selectedDay!);

                    for (var tour in tours) {
                      final startDate = (tour['start_date'] as Timestamp).toDate();

                      if (_isSameDay(startDate, selectedDate)) {
                        final title = tour['location'];
                        final details = tour['remarks'];
                        final endDate = (tour['end_date'] as Timestamp).toDate();
                        final duration = endDate.difference(DateTime.now());
                        final remainingTime = '${duration.inDays}D : ${duration.inHours % 24}H : ${duration.inMinutes % 60}M';
                        
                        _scheduleNotification(startDate, title); // Schedule notification

                        tourWidgets.add(
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F3E46),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.transparent,
                                ),
                                child: Image.asset(
                                  'assets/plane.png', // Path to your event image
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    details,
                                    style: const TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                  Text(
                                    remainingTime,
                                    style: const TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  }
                  if (tourWidgets.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(children: tourWidgets);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}

class CalendarWidget extends StatelessWidget {
  final int month;
  final int year;
  final int daysInMonth;
  final int? selectedDay;
  final ValueChanged<int> onDaySelected;

  CalendarWidget({
    required this.month,
    required this.year,
    required this.daysInMonth,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the first day of the month
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    int startingWeekday = firstDayOfMonth.weekday % 7; // % 7 to make Sunday as 0

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2F3E46)),
        borderRadius: BorderRadius.circular(15), // Circular border radius on all sides
        color: const Color(0xFFD9D9D9),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_months[month - 1]}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.5),
                child: Text('S', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.5),
                child: Text('M', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.5),
                child: Text('T', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.5),
                child: Text('W', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.5),
                child: Text('T', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.5),
                child: Text('F', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.5),
                child: Text('S', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics:  const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: daysInMonth + startingWeekday,
            itemBuilder: (context, index) {
              if (index < startingWeekday) {
                return const SizedBox.shrink(); // Empty boxes for the days before the 1st
              } else {
                int day = index - startingWeekday + 1;
                bool isSelected = selectedDay == day;
                return GestureDetector(
                  onTap: () => onDaySelected(day),
                  child: Container(
                    decoration: isSelected
                        ? const BoxDecoration(
                            color: Color(0xFF2F3E46),
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(color: isSelected ? Color(0xFFD9D9D9) : Colors.black),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
}
