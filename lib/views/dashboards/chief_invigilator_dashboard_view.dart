import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../profile/profile_view.dart';

class ChiefInvigilatorDashboardView extends StatefulWidget {
  const ChiefInvigilatorDashboardView({super.key});

  @override
  State<ChiefInvigilatorDashboardView> createState() =>
      _ChiefInvigilatorDashboardViewState();
}

class _ChiefInvigilatorDashboardViewState
    extends State<ChiefInvigilatorDashboardView> {
  int _selectedIndex = 0;

  // Mock data: all examination requests.
  final List<Map<String, String>> _requests = [
    {
      'hall': 'Hall A',
      'seat': 'C03',
      'category': 'Student Assistance',
      'description': 'Student requires assistance.',
      'assigned': 'Unassigned',
      'status': 'Pending',
    },
    {
      'hall': 'Hall B',
      'seat': 'B08',
      'category': 'Student Assistance',
      'description': 'Student requested assistance.',
      'assigned': 'Jordan Patel',
      'status': 'In Progress',
    },
    {
      'hall': 'Hall C',
      'seat': 'A12',
      'category': 'Additional Answer Booklet',
      'description': 'Extra calculator requested.',
      'assigned': 'Dr. Ahmad',
      'status': 'Pending',
    },
    {
      'hall': 'Hall A',
      'seat': 'A05',
      'category': 'Question Clarification',
      'description': 'Student needs clarification about Question 4.',
      'assigned': 'Dr. Siti',
      'status': 'Resolved',
    },
    {
      'hall': 'Hall B',
      'seat': 'D02',
      'category': 'Missing Examination Paper',
      'description': 'Missing page reported.',
      'assigned': 'Mr. Lim',
      'status': 'Resolved',
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Escalated':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  int get _totalRequests => _requests.length;

  int get _pendingCount =>
      _requests.where((request) => request['status'] == 'Pending').length;

  int get _inProgressCount =>
      _requests.where((request) => request['status'] == 'In Progress').length;

  int get _resolvedCount =>
      _requests.where((request) => request['status'] == 'Resolved').length;

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

    if (mounted) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
  }

  Widget _welcomeSection() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Text(
        'Hello!',
        style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final name = data?['name'] as String?;
        final displayName = (name != null && name.trim().isNotEmpty)
            ? name.trim()
            : 'Chief Invigilator';

        return Text(
          'Hello, $displayName',
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        );
      },
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
                  'Chief Invigilator',
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

  Widget _summaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.blueGrey.shade700),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _requestCard(int index) {
    final request = _requests[index];
    final status = request['status']!;
    final color = _statusColor(status);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 9),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${request['hall']} · Seat ${request['seat']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(request['category']!, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              request['description']!,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 15, color: Colors.grey),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Assigned to: ${request['assigned']}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
            if (status == 'Pending') ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showAssignDialog(index),
                  child: const Text('Assign Invigilator'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(int index) {
    String selectedInvigilator = 'Dr. Ahmad';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Assign Request'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_requests[index]['hall']} · Seat ${_requests[index]['seat']}',
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Invigilator'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedInvigilator,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Dr. Ahmad',
                        child: Text('Dr. Ahmad'),
                      ),
                      DropdownMenuItem(
                        value: 'Dr. Siti',
                        child: Text('Dr. Siti'),
                      ),
                      DropdownMenuItem(
                        value: 'Mr. Lim',
                        child: Text('Mr. Lim'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedInvigilator = value;
                        });
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
                    setState(() {
                      _requests[index]['assigned'] = selectedInvigilator;
                      _requests[index]['status'] = 'In Progress';
                    });

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invigilator assigned successfully!'),
                      ),
                    );
                  },
                  child: const Text('Assign'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _dashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _welcomeSection(),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Chief Invigilator',
              style: TextStyle(fontSize: 11),
            ),
          ),

          const SizedBox(height: 16),

          _examinationCard(),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Session Summary',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  _showAnalyticsDialog();
                },
                child: const Text('Quick view', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),

          const SizedBox(height: 8),

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
                _totalRequests.toString(),
                Icons.assignment_outlined,
              ),
              _summaryCard(
                'Pending',
                _pendingCount.toString(),
                Icons.hourglass_empty,
              ),
              _summaryCard(
                'In Progress',
                _inProgressCount.toString(),
                Icons.pending_actions,
              ),
              _summaryCard(
                'Resolved',
                _resolvedCount.toString(),
                Icons.check_circle_outline,
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _showAnalyticsDialog,
              child: const Text('Analytics · Quick Preview'),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Requests',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                child: const Text('All halls', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ...List.generate(_requests.length, (index) => _requestCard(index)),
        ],
      ),
    );
  }

  void _showAnalyticsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Session Analytics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Requests: $_totalRequests'),
              const SizedBox(height: 10),
              Text('Pending: $_pendingCount'),
              const SizedBox(height: 10),
              Text('In Progress: $_inProgressCount'),
              const SizedBox(height: 10),
              Text('Resolved: $_resolvedCount'),
              const SizedBox(height: 10),
              const Text('Average Response Time: Not available yet'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _allRequestsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Examination Requests',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Monitor requests across all examination halls.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ...List.generate(_requests.length, (index) => _requestCard(index)),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      _dashboardContent(),
      _allRequestsPage(),
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
