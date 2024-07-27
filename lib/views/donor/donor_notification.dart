import 'package:blinkz/views/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blinkz/session_manager/session.dart';

class DonorNotificationsScreen extends StatefulWidget {
  @override
  _DonorNotificationsScreenState createState() => _DonorNotificationsScreenState();
}

class _DonorNotificationsScreenState extends State<DonorNotificationsScreen> {
  List<NotificationItem> notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final response = await Supabase.instance.client
        .from('notification')
        .select()
        .or('user_id.eq.${SessionManager.userId},user_id.is.null');



    setState(() {
        notifications = (response as List)
            .map((data) => NotificationItem(
          title: data['title'],
          subtitle: data['subtitle'],
        ))
            .toList();
        _isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade400,
        title: Text(
          'Donor Notifications',
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: CustomDrawer(),
      body: _isLoading
          ? Center(child: Lottie.asset('assets/splash.json'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildNotificationsList(),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(
              notifications[index].title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              notifications[index].subtitle,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}

class NotificationItem {
  final String title;
  final String subtitle;

  NotificationItem({
    required this.title,
    required this.subtitle,
  });
}
