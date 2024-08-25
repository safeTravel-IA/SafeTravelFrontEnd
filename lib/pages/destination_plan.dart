import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safetravelfrontend/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class DestinationPlanning extends StatefulWidget {
  final String destinationId;

  DestinationPlanning({required this.destinationId});

  @override
  _DestinationPlanningState createState() => _DestinationPlanningState();
}

class _DestinationPlanningState extends State<DestinationPlanning> {
  late UserProvider _userProvider;
  late String _destinationId;
  late DateTime _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _destinationId = widget.destinationId; // Set _destinationId from widget property
    _startDate = DateTime.now(); // Initialize _startDate with a default value
    _loadDates(); // Load stored dates if any
  }

  Future<void> _loadDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _startDate = DateTime.parse(prefs.getString('startDate') ?? DateTime.now().toIso8601String());
      _endDate = prefs.getString('endDate') != null ? DateTime.parse(prefs.getString('endDate')!) : null;
    });
  }


  Future<void> _saveDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('startDate', _startDate.toIso8601String());
    await prefs.setString('endDate', _endDate?.toIso8601String() ?? '');
  }

 Future<void> _createPlanning() async {
  try {
    final userId = _userProvider.userId;

    // Print values for debugging
    print('User ID: $userId');
    print('Destination ID: $_destinationId');
    print('Start Date: $_startDate');
    print('End Date: $_endDate');

    if (userId == null) {
      throw Exception('User ID not found');
    }

    if (_destinationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Destination ID must be set')),
      );
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End date must be selected')),
      );
      return;
    }

    await _userProvider.createPlanning(
      userId: userId,
      destinationId: _destinationId,
      startDate: _startDate,
      endDate: _endDate!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Planning created successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error creating planning: $e')),
    );
  }
}


  @override
Widget build(BuildContext context) {
      _userProvider = Provider.of<UserProvider>(context); // Initialize _userProvider here

  return Scaffold(
    backgroundColor: Color.fromARGB(255, 248, 248, 248),
    appBar: AppBar(
      title: Text('Plan Destination'),
      actions: [
        IconButton(
          icon: Icon(Icons.save),
          onPressed: () async {
            await _createPlanning();
          },
        ),
      ],
    ),
    body: SingleChildScrollView( // Wrap content in SingleChildScrollView
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -50,
            left: -50,
            child: Image.asset(
              'assets/images/top_circle.png',
              width: 200,
              height: 200,
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Image.asset(
              'assets/images/bottom_circle.png',
              width: 200,
              height: 200,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Start Date: ${_startDate.toLocal().toShortDateString()}'),
                TableCalendar(
                  focusedDay: _startDate,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  selectedDayPredicate: (day) => isSameDay(_startDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _startDate = selectedDay;
                    });
                    _saveDates();
                  },
                ),
                SizedBox(height: 16),
                Text('End Date: ${_endDate?.toLocal().toShortDateString() ?? 'Not selected'}'),
                TableCalendar(
                  focusedDay: _endDate ?? DateTime.now(),
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  selectedDayPredicate: (day) => isSameDay(_endDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _endDate = selectedDay;
                    });
                    _saveDates();
                  },
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}

extension DateUtils on DateTime {
  String toShortDateString() {
    return "${this.day.toString().padLeft(2, '0')}/${this.month.toString().padLeft(2, '0')}/${this.year}";
  }
}
