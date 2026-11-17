
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../profile/profile_view.dart';

// Represents a request displayed in the category details.
class DashboardRequest {
  final String seatNumber;
  final String status;
  final String description;

  const DashboardRequest({
    required this.seatNumber,
    required this.status,
    required this.description,
  });
}

// Represents a request category and its statistics.
class DashboardCategory {
  final String name;
  final int total;
  final int pending;
  final int resolved;
  final List<DashboardRequest> requests;

  const DashboardCategory({
    required this.name,
    required this.total,
    required this.pending,
    required this.resolved,
    required this.requests,
  });
}

class DashboardView extends StatelessWidget {
  final String role;

  const DashboardView({
    super.key,
    required this.role,
  });

  // Current examination information.
  Widget _examinationInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Examination',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _examInfoRow(
              Icons.location_on_outlined,
              'Examination Hall',
              'N28, Level 2, Hall A',
            ),
            _examInfoRow(
              Icons.calendar_today_outlined,
              'Date',
              '18 November 2026',
            ),
            _examInfoRow(
              Icons.access_time,
              'Time',
              '9:00 AM - 12:00 PM',
            ),
            _examInfoRow(
              Icons.book_outlined,
              'Subject',
              'Data Structures and Algorithms',
            ),
          ],
        ),
      ),
    );
  }

  Widget _examInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sample recent requests based on user role.
  List<Map<String, String>> getRecentRequests() {
    switch (role) {
      case 'Chief Invigilator':
        return [
          {
            'seat': 'A01',
            'category': 'Question Clarification',
            'description':
                'Student needs clarification about Question 2.',
            'assigned': 'Dr. Ahmad (Invigilator)',
            'status': 'Pending',
          },
          {
            'seat': 'B03',
            'category': 'Incorrect Examination Question',
            'description': 'Possible error found in Question 5.',
            'assigned': 'Dr. Siti (Invigilator)',
            'status': 'Escalated',
          },
          {
            'seat': 'C02',
            'category': 'Missing Examination Paper',
            'description':
                'Page 3 is missing from the examination paper.',
            'assigned': 'Mr. Lim (Invigilator)',
            'status': 'In Progress',
          },
          {
            'seat': 'A08',
            'category': 'Additional Answer Booklet',
            'description':
                'Student requested an additional answer booklet.',
            'assigned': 'Assistant Invigilator',
            'status': 'Resolved',
          },
        ];

      case 'Invigilator':
        return [
          {
            'seat': 'A01',
            'category': 'Question Clarification',
            'description':
                'Student needs clarification about Question 2.',
            'assigned': 'Me',
            'status': 'Pending',
          },
          {
            'seat': 'B03',
            'category': 'Incorrect Examination Question',
            'description': 'Possible error found in Question 5.',
            'assigned': 'Me',
            'status': 'In Progress',
          },
          {
            'seat': 'C02',
            'category': 'Missing Examination Paper',
            'description':
                'Page 3 is missing from the examination paper.',
            'assigned': 'Me',
            'status': 'Resolved',
          },
        ];

      case 'Assistant Invigilator':
        return [
          {
            'seat': 'A01',
            'category': 'Question Clarification',
            'description':
                'Student needs clarification about Question 2.',
            'assigned': 'Dr. Ahmad (Invigilator)',
            'status': 'Pending',
          },
          {
            'seat': 'B03',
            'category': 'Missing Examination Paper',
            'description':
                'Student reported a missing examination page.',
            'assigned': 'Dr. Siti (Invigilator)',
            'status': 'In Progress',
          },
          {
            'seat': 'C02',
            'category': 'Additional Answer Booklet',
            'description': 'Additional answer booklet provided.',
            'assigned': 'Me',
            'status': 'Resolved',
          },
          {
            'seat': 'D04',
            'category': 'Washroom Assistance',
            'description': 'Student requested washroom assistance.',
            'assigned': 'Me',
            'status': 'Resolved',
          },
        ];

      default:
        return [];
    }
  }

  // Sample category data for demonstration.
  // Replace with Firestore data in Sprint 2.
  List<DashboardCategory> getCategories() {
    switch (role) {
      case 'Chief Invigilator':
        return const [
          DashboardCategory(
            name: 'Question Clarification',
            total: 8,
            pending: 3,
            resolved: 5,
            requests: [
              DashboardRequest(
                seatNumber: 'A01',
                status: 'Pending',
                description:
                    'Student requires clarification about Question 2.',
              ),
              DashboardRequest(
                seatNumber: 'A05',
                status: 'Resolved',
                description:
                    'Student requested clarification about Question 4.',
              ),
            ],
          ),
          DashboardCategory(
            name: 'Incorrect Examination Question',
            total: 4,
            pending: 2,
            resolved: 2,
            requests: [
              DashboardRequest(
                seatNumber: 'B03',
                status: 'Pending',
                description:
                    'Student reported a possible error in Question 5.',
              ),
            ],
          ),
          DashboardCategory(
            name: 'Missing Examination Paper',
            total: 6,
            pending: 1,
            resolved: 5,
            requests: [
              DashboardRequest(
                seatNumber: 'C02',
                status: 'Pending',
                description:
                    'Student reported a missing examination page.',
              ),
            ],
          ),
          DashboardCategory(
            name: 'Additional Answer Booklet',
            total: 10,
            pending: 2,
            resolved: 8,
            requests: [
              DashboardRequest(
                seatNumber: 'A08',
                status: 'Resolved',
                description:
                    'Student requested an additional answer booklet.',
              ),
            ],
          ),
          DashboardCategory(
            name: 'Other Assistance',
            total: 7,
            pending: 2,
            resolved: 5,
            requests: [
              DashboardRequest(
                seatNumber: 'D04',
                status: 'Pending',
                description:
                    'Student requested other examination assistance.',
              ),
            ],
          ),
        ];

      case 'Invigilator':
        return const [
          DashboardCategory(
            name: 'Question Clarification',
            total: 5,
            pending: 2,
            resolved: 3,
            requests: [
              DashboardRequest(
                seatNumber: 'A01',
                status: 'Pending',
                description:
                    'Student requires clarification about Question 2.',
              ),
              DashboardRequest(
                seatNumber: 'A05',
                status: 'Resolved',
                description:
                    'Student requested clarification about Question 4.',
              ),
            ],
          ),
          DashboardCategory(
            name: 'Incorrect Examination Question',
            total: 3,
            pending: 1,
            resolved: 2,
            requests: [
              DashboardRequest(
                seatNumber: 'B03',
                status: 'Pending',
                description:
                    'Student reported a possible error in Question 5.',
              ),
            ],
          ),
          DashboardCategory(
            name: 'Missing Examination Paper',
            total: 2,
            pending: 1,
            resolved: 1,
            requests: [
              DashboardRequest(
                seatNumber: 'C02',
                status: 'Pending',
                description:
                    'Student reported a missing examination page.',
              ),
            ],
          ),
        ];

      case 'Assistant Invigilator':
        return const [
          DashboardCategory(
            name: 'Question Clarification',
            total: 4,
            pending: 2,
            resolved: 2,
            requests: [
              DashboardRequest(
                seatNumber: 'A01',
                status: 'Pending',
                description:
                    'Student requires clarification about Question 2.',
              ),
            ],
          ),
          DashboardCategory(
            name: 'Missing Examination Paper',
            total: 3,
            pending: 1,
            resolved: 2,
            requests: [
              DashboardRequest(
                seatNumber: 'C02',
                status: 'Pending',
                description:
                    'Student reported a missing examination page.',
              ),
            ],
          ),
          DashboardCategory(
            name: 'Additional Answer Booklet',
            total: 5,
            pending: 0,
            resolved: 5,
            requests: [
              DashboardRequest(
                seatNumber: 'A08',
                status: 'Resolved',
                description:
                    'Additional answer booklet provided to student.',
              ),
            ],
          ),
          DashboardCategory(
            name: 'Other Assistance',
            total: 3,
            pending: 1,
            resolved: 2,
            requests: [
              DashboardRequest(
                seatNumber: 'D04',
                status: 'Pending',
                description:
                    'Student requested other examination assistance.',
              ),
            ],
          ),
        ];

      default:
        return [];
    }
  }

  // Calculate request statistics.
  int getTotal(List<DashboardCategory> categories) {
    return categories.fold(0, (sum, item) => sum + item.total);
  }

  int getPending(List<DashboardCategory> categories) {
    return categories.fold(0, (sum, item) => sum + item.pending);
  }

  int getResolved(List<DashboardCategory> categories) {
    return categories.fold(0, (sum, item) => sum + item.resolved);
  }

  @override
  Widget build(BuildContext context) {
    final categories = getCategories();

    final isChief = role == 'Chief Invigilator';
    final isAssistant = role == 'Assistant Invigilator';

    final total = getTotal(categories);
    final pending = getPending(categories);
    final resolved = getResolved(categories);
    final recentRequests = getRecentRequests();

    // Sample escalated count for Chief Invigilator.
    final escalated = isChief ? 3 : 0;

    if (categories.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Account role not assigned.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ExamAssist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.school,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
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
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => ProfileViewModel(),
                      child: const ProfileView(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await context.read<AuthViewModel>().logout();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              role,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.blue,
                  ),
            ),
            const SizedBox(height: 20),

            // Current examination information.
            _examinationInfoCard(),

            const SizedBox(height: 24),

            // Dashboard heading.
            Text(
              isChief
                  ? 'Examination Overview'
                  : isAssistant
                      ? 'My Submitted Requests'
                      : 'My Assigned Requests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Summary cards.
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _summaryCard(
                  'Total Requests',
                  total,
                  Icons.assignment,
                  Colors.blue,
                ),
                _summaryCard(
                  'Pending',
                  pending,
                  Icons.pending_actions,
                  Colors.orange,
                ),
                _summaryCard(
                  'Resolved',
                  resolved,
                  Icons.check_circle,
                  Colors.green,
                ),
                if (isChief)
                  _summaryCard(
                    'Escalated',
                    escalated,
                    Icons.warning,
                    Colors.red,
                  )
                else
                  _summaryCard(
                    'Categories',
                    categories.length,
                    Icons.category,
                    Colors.purple,
                  ),
              ],
            ),

            // Create Request button - Assistant Invigilator only.
            if (isAssistant) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showCreateRequestDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Request'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Recent Requests.
            Text(
              'Recent Requests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'Latest student assistance requests and their current status.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),

            ...recentRequests.map((request) {
              final status = request['status']!;

              Color statusColor;

              switch (status) {
                case 'Resolved':
                  statusColor = Colors.green;
                  break;
                case 'Escalated':
                  statusColor = Colors.red;
                  break;
                case 'In Progress':
                  statusColor = Colors.blue;
                  break;
                default:
                  statusColor = Colors.orange;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request['category']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Seat Number: ${request['seat']}'),
                      const SizedBox(height: 5),
                      Text(request['description']!),
                      const SizedBox(height: 12),

                      // Assigned staff
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 17,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Assigned to: ${request['assigned']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Respond button
                      if (!isChief &&
                          !isAssistant &&
                          request['status'] != 'Resolved') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showRespondDialog(context, request);
                            },
                            icon: const Icon(Icons.reply),
                            label: const Text('Respond to Request'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Request Categories.
            Text(
              'Request Categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'Select a category to view its request details.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Category list.
            ...categories.map(
              (category) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(
                      Icons.assignment_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total: ${category.total}'),
                        const SizedBox(height: 4),
                        Text(
                          'Pending: ${category.pending}  |  '
                          'Resolved: ${category.resolved}',
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () {
                    _showCategoryDetails(context, category);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Summary card widget.
  Widget _summaryCard(
    String title,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  
  // Create request dialog.
  void _showCreateRequestDialog(BuildContext context) {
    final seatController = TextEditingController();
    final descriptionController = TextEditingController();

    String selectedCategory = 'Question Clarification';

    final requestCategories = [
      'Question Clarification',
      'Incorrect Examination Question',
      'Missing Examination Paper',
      'Additional Answer Booklet',
      'Washroom Assistance',
      'Other Assistance',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Create Student Request'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Student Seat Number'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: seatController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. A01',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Request Category'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: requestCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Description'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Describe the student request...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (seatController.text.trim().isEmpty ||
                        descriptionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            seatController.text.trim().isEmpty
                                ? 'Please enter the seat number.'
                                : 'Please enter the request description.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Request form completed. Firestore saving will be implemented in Sprint 2.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      seatController.dispose();
      descriptionController.dispose();
    });
  }


  // Respond to request dialog.
  void _showRespondDialog(
    BuildContext context,
    Map<String, String> request,
  ) {
    final responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Respond to Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['category']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Seat Number: ${request['seat']}'),
                const SizedBox(height: 8),
                Text(request['description']!),
                const SizedBox(height: 16),
                const Text('Response / Instructions'),
                const SizedBox(height: 8),
                TextField(
                  controller: responseController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Enter your response...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (responseController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a response.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Response submitted. Firestore updating will be implemented in Sprint 2.',
                    ),
                  ),
                );
              },
              child: const Text('Submit Response'),
            ),
          ],
        );
      },
    ).then((_) {
      responseController.dispose();
    });
  }

  // Display request details when a category is selected.
  void _showCategoryDetails(
    BuildContext context,
    DashboardCategory category,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(category.name),
          content: SizedBox(
            width: double.maxFinite,
            child: category.requests.isEmpty
                ? const Text('No requests available.')
                : ListView(
                    shrinkWrap: true,
                    children: category.requests.map((request) {
                      final isResolved = request.status == 'Resolved';

                      return Card(
                        child: ListTile(
                          title: Text(
                            'Seat ${request.seatNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text(request.description),
                              const SizedBox(height: 5),
                              Text(
                                request.status,
                                style: TextStyle(
                                  color: isResolved
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
