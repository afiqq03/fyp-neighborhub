import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:rukuntetangga/widgets/constants.dart';
import 'package:intl/intl.dart';
import 'package:rukuntetangga/widgets/gradient_app_bar.dart';

class TimetablePage extends StatefulWidget {
  final String username;
  final VoidCallback? onSearchTap;

  const TimetablePage({
    super.key, 
    this.username = '',
    this.onSearchTap,
  });

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late String _selectedFilter;
  
  // Sample event data (to be replaced with actual data from Firestore later)
  final Map<String, List<Event>> _events = {};
  late List<Event> _selectedEvents;
  
  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedFilter = 'All';
    
    // Populate with sample events
    _initSampleEvents();
    _selectedEvents = _getEventsForDay(_selectedDay);
  }
  
  void _initSampleEvents() {
    // Add sample events to demonstrate the UI
    final now = DateTime.now();
    
    // Community meetings
    _addEvent(now, 'Monthly Community Meeting', 'Meeting', 
        'Community Hall', Colors.blue);
    _addEvent(now.add(const Duration(days: 14)), 'Emergency Response Briefing', 
        'Meeting', 'Community Hall', Colors.blue);
    
    // Maintenance
    _addEvent(now.add(const Duration(days: 2)), 'Garden Maintenance', 
        'Maintenance', 'Community Garden', Colors.green);
    _addEvent(now.add(const Duration(days: 7)), 'Playground Equipment Check', 
        'Maintenance', 'Children\'s Playground', Colors.green);
    
    // Events
    _addEvent(now.add(const Duration(days: 5)), 'Community Potluck', 
        'Event', 'Community Center', Colors.orange);
    _addEvent(now.add(const Duration(days: 10)), 'Children\'s Day Celebration', 
        'Event', 'Community Park', Colors.orange);
    _addEvent(now.add(const Duration(days: 20)), 'Annual Sports Day', 
        'Event', 'Sports Complex', Colors.orange);
    
    // Important
    _addEvent(now.add(const Duration(days: 1)), 'Fee Collection Deadline', 
        'Important', 'Admin Office', Colors.red);
  }
  
  void _addEvent(DateTime date, String title, String category, String location, Color color) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    if (_events[dateStr] == null) {
      _events[dateStr] = [];
    }
    _events[dateStr]!.add(Event(
      title: title,
      category: category,
      location: location,
      date: date,
      color: color,
    ));
  }
  
  List<Event> _getEventsForDay(DateTime day) {
    final dateStr = DateFormat('yyyy-MM-dd').format(day);
    return _events[dateStr] ?? [];
  }
  
  List<Event> _getFilteredEvents() {
    if (_selectedFilter == 'All') {
      return _selectedEvents;
    }
    return _selectedEvents.where((event) => event.category == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Calendar',
        showGreeting: true,
        username: widget.username,
        onSearchTap: widget.onSearchTap,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getEventsForDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedEvents = _getEventsForDay(selectedDay);
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  markerDecoration: const BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                ),
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: true,
                  formatButtonDecoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  formatButtonTextStyle: TextStyle(color: kPrimaryColor),
                  titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('All', Colors.grey),
                  _buildFilterChip('Meeting', Colors.blue),
                  _buildFilterChip('Event', Colors.orange),
                  _buildFilterChip('Maintenance', Colors.green),
                  _buildFilterChip('Important', Colors.red),
                ],
              ),
            ),
          ),
          
          // Date header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('MMMM d, yyyy').format(_selectedDay),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_getFilteredEvents().length} Events',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          
          // Events list
          Expanded(
            child: _getFilteredEvents().isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No events scheduled',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _getFilteredEvents().length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(_getFilteredEvents()[index]);
                    },
                  ),
          ),
        ],
      )  
    );
  }
  
  Widget _buildFilterChip(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == label,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? label : 'All';
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: color.withOpacity(0.2),
        labelStyle: TextStyle(
          color: _selectedFilter == label ? color : Colors.black87,
          fontWeight: _selectedFilter == label ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: color,
      ),
    );
  }
  
  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: event.color,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: event.color,
          child: Icon(
            _getCategoryIcon(event.category),
            color: event.color,
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('h:mm a').format(event.date),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  event.location,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: event.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            event.category,
            style: TextStyle(
              color: event.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () => _showEventDetails(event),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Meeting':
        return Icons.groups;
      case 'Maintenance':
        return Icons.build;
      case 'Event':
        return Icons.celebration;
      case 'Important':
        return Icons.priority_high;
      default:
        return Icons.event;
    }
  }

  void _showEventDetails(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: event.color,
                  child: Icon(
                    _getCategoryIcon(event.category),
                    color: event.color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        event.category,
                        style: TextStyle(
                          color: event.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _detailItem(Icons.calendar_today, 'Date', 
                DateFormat('EEEE, MMMM d, yyyy').format(event.date)),
            const SizedBox(height: 16),
            _detailItem(Icons.access_time, 'Time', 
                DateFormat('h:mm a').format(event.date)),
            const SizedBox(height: 16),
            _detailItem(Icons.location_on, 'Location', event.location),
            const SizedBox(height: 16),
            _detailItem(Icons.description, 'Description', 
                'Sample event description for ${event.title}. This information would come from the database in the real implementation.'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit feature coming soon')),
                    );
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share feature coming soon')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _detailItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
          size: 18,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Event {
  final String title;
  final String category;
  final String location;
  final DateTime date;
  final Color color;

  Event({
    required this.title,
    required this.category,
    required this.location,
    required this.date,
    required this.color,
  });
}