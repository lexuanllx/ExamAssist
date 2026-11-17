import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../profile/profile_view.dart';

class InvigilatorDashboardView extends StatefulWidget {
  const InvigilatorDashboardView({super.key});

  @override
  State<InvigilatorDashboardView> createState() =>
      _InvigilatorDashboardViewState();
}

class _InvigilatorDashboardViewState extends State<InvigilatorDashboardView> {
  int _selectedIndex = 0;

  // Mock data for Sprint 1. This will be replaced with Firestore data in Sprint 2.
  final List<Map<String, String>> _requests = [
    {
      'seat': 'A12',
      'category': 'Additional Answer Booklet',
      'description': 'Student requires an additional answer booklet.',
      'submittedBy': 'Alex Morgan',
      'status': 'Pending',
    },
    {
      'seat': 'C03',
      'category': 'Student Assistance',
      'description': 'Student requires assistance during examination.',
      'submittedBy': 'Sam Lee',
      'status': 'Pending',
    },
    {
      'seat': 'B08',
      'category': 'Student Assistance',
      'description': 'Student requested assistance with an issue.',
      'submittedBy': 'Assistant Invigilator',
      'status': 'In Progress',
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ProfileViewModel(),
          child: const ProfileView(),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
  }

  void _showRespondDialog(int index) {
    final request = _requests[index];
    String selectedStatus = request['status']!;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Respond to Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seat ${request['seat']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(request['description']!),
              const SizedBox(height: 20),
              const Text('Update Request Status'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(
                    value: 'In Progress',
                    child: Text('In Progress'),
                  ),
                  DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedStatus = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _requests[index]['status'] = selectedStatus);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Request status updated successfully!'),
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcomeSection() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Text(
        'Hello!',
        style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final name = (data?['name'] as String?)?.trim();
        final displayName = (name != null && name.isNotEmpty)
            ? name
            : (currentUser.displayName?.trim().isNotEmpty == true
                  ? currentUser.displayName!
                  : 'Invigilator');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $displayName',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Invigilator', style: TextStyle(fontSize: 11)),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summarySection() {
    final total = _requests.length;
    final pending = _requests.where((r) => r['status'] == 'Pending').length;
    final inProgress = _requests
        .where((r) => r['status'] == 'In Progress')
        .length;
    final resolved = _requests.where((r) => r['status'] == 'Resolved').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Request Summary',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.3, // Taller cards to prevent vertical overflow.
          children: [
            _summaryCard(
              'Total Requests',
              total,
              Icons.assignment_outlined,
              Colors.blueGrey,
            ),
            _summaryCard(
              'Pending',
              pending,
              Icons.pending_actions,
              Colors.orange,
            ),
            _summaryCard(
              'In Progress',
              inProgress,
              Icons.autorenew,
              Colors.blue,
            ),
            _summaryCard(
              'Resolved',
              resolved,
              Icons.check_circle_outline,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _examinationCard() {
    Widget detailRow(IconData icon, String label, String value) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: Colors.blueGrey.shade500),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: const Color(0xFFF1F2F9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Examination',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            detailRow(
              Icons.location_on_outlined,
              'Examination Hall',
              'N28, Level 2, Hall A',
            ),
            const SizedBox(height: 14),
            detailRow(
              Icons.calendar_today_outlined,
              'Date',
              '18 November 2026',
            ),
            const SizedBox(height: 14),
            detailRow(Icons.access_time, 'Time', '9:00 AM - 12:00 PM'),
            const SizedBox(height: 14),
            detailRow(
              Icons.bookmark_border,
              'Subject',
              'Data Structures and Algorithms',
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestCard(int index) {
    final request = _requests[index];
    final status = request['status']!;
    final color = _statusColor(status);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Seat ${request['seat']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(5),
                    color: color.withValues(alpha: 0.08),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${request['category']} · From ${request['submittedBy']}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 6),
            Text(request['description']!, style: const TextStyle(fontSize: 13)),
            if (status != 'Resolved') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showRespondDialog(index),
                  icon: const Icon(Icons.reply, size: 18),
                  label: const Text('Respond to Request'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dashboardContent() {
    final assignedCount = _requests.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _welcomeSection(),
          const SizedBox(height: 18),
          _examinationCard(),
          const SizedBox(height: 20),
          _summarySection(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _selectedIndex = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('View Assigned Requests'),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Assigned Requests in My Hall',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '$assignedCount assigned',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Review pending requests and continue handling assigned requests.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ...List.generate(_requests.length, (index) => _requestCard(index)),
        ],
      ),
    );
  }

  Widget _requestsPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'My Assigned Requests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Review and update the status of requests assigned to you.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ...List.generate(_requests.length, (index) => _requestCard(index)),
      ],
    );
  }

  Widget _placeholderPage(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 55, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'This page will be implemented separately.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.school, size: 40, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  'Invigilator',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const Text(
                  'ExamAssist',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              _openProfile();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context);
              await _logout();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _dashboardContent(),
      _requestsPage(),
      _placeholderPage('Chat', Icons.chat_bubble_outline),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ExamAssist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: pages[_selectedIndex],
    );
  }
}
