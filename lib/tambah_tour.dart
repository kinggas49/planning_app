import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'main_menu.dart'; // Import the MainMenu screen

class AddTourScreen extends StatefulWidget {
  @override
  _AddTourScreenState createState() => _AddTourScreenState();
}

class _AddTourScreenState extends State<AddTourScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? _user;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String _location = '';
  String _remarks = '';

  final List<String> _months = [
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
  final List<int> _years = List.generate(100, (index) => 2000 + index);

  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    User? user = _auth.currentUser;
    setState(() {
      _user = user;
    });
  }

  int _daysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      if (_selectedStartDate == null || (day.isBefore(_selectedStartDate!) && _selectedEndDate == null)) {
        _selectedStartDate = day;
        _selectedEndDate = null;
      } else if (_selectedEndDate == null && day.isAfter(_selectedStartDate!)) {
        _selectedEndDate = day;
      } else {
        _selectedStartDate = day;
        _selectedEndDate = null;
      }
    });
  }

  Future<void> _saveTour() async {
    if (_selectedStartDate != null && _location.isNotEmpty && _remarks.isNotEmpty) {
      await _firestore.collection('tours').add({
        'user': _user?.uid,
        'start_date': _selectedStartDate,
        'end_date': _selectedEndDate,
        'location': _location,
        'remarks': _remarks,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Clear the form
      setState(() {
        _selectedStartDate = null;
        _selectedEndDate = null;
        _location = '';
        _remarks = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tour added successfully')),
      );

      // Navigate back to MainMenu
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainMenu()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCAD2C5), // Light background color
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text('Add Tour', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color : Color(0xFF2F3E46)),
                      borderRadius: BorderRadius.circular(12)

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
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color : Color(0xFF2F3E46)),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: DropdownButton<int>(
                      value: _selectedYear,
                      items: _years.map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedYear = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CalendarWidget(
                month: _months.indexOf(_selectedMonth) + 1,
                year: _selectedYear,
                daysInMonth: _daysInMonth(_months.indexOf(_selectedMonth) + 1, _selectedYear),
                selectedStartDate: _selectedStartDate,
                selectedEndDate: _selectedEndDate,
                onDaySelected: _onDaySelected,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration:  InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color : Color(0xFF2F3E46)),
                    borderRadius: BorderRadius.circular(12),
                  

                  ),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedStartDate != null
                      ? '${DateFormat('MMM dd').format(_selectedStartDate!)} - ${_selectedEndDate != null ? DateFormat('MMM dd').format(_selectedEndDate!) : ''}'
                      : '',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration:  InputDecoration(
                  labelText: "What's the tour about",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color : Color(0xFF2F3E46)),
                    borderRadius: BorderRadius.circular(12)

                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration:  InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color : Color(0xFF2F3E46)),
                    borderRadius: BorderRadius.circular(12)

                  ),
                  prefixIcon: Icon(Icons.location_on),
                ),
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration:  InputDecoration(
                  labelText: 'Remarks',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2F3E46)),
                    borderRadius: BorderRadius.circular(12)
                  ),
                ),
                maxLines: 4,
                onChanged: (value) {
                  setState(() {
                    _remarks = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedStartDate = null;
                          _selectedEndDate = null;
                          _location = '';
                          _remarks = '';
                        });
                      },
                      child: const Text('Delete Tour',style: TextStyle(color : Color(0xFF2F3E46)),),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: Color(0xFF2F3E46)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTour,
                      child: const Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F3E46),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  final int month;
  final int year;
  final int daysInMonth;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final ValueChanged<DateTime> onDaySelected;

  CalendarWidget({
    required this.month,
    required this.year,
    required this.daysInMonth,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    int startingWeekday = firstDayOfMonth.weekday % 7;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2F3E46)),
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFFD9D9D9),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_months[month - 1]}, $year',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('S', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('M', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('T', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('W', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('T', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('F', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('S', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: daysInMonth + startingWeekday,
            itemBuilder: (context, index) {
              if (index < startingWeekday) {
                return const SizedBox.shrink();
              } else {
                int day = index - startingWeekday + 1;
                DateTime currentDate = DateTime(year, month, day);
                bool isSelected = selectedStartDate != null &&
                    (currentDate == selectedStartDate ||
                        (selectedEndDate != null && currentDate.isAfter(selectedStartDate!) && currentDate.isBefore(selectedEndDate!)) ||
                        currentDate == selectedEndDate);

                return GestureDetector(
                  onTap: () => onDaySelected(currentDate),
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
                        style: TextStyle(color: isSelected ? Color(0xFF84A98C) : Colors.black, fontSize: 18),
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
