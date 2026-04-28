import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api_service.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';

class MyPetitionsScreen extends StatefulWidget {
  const MyPetitionsScreen({super.key});

  @override
  State<MyPetitionsScreen> createState() => _MyPetitionsScreenState();
}

class _MyPetitionsScreenState extends State<MyPetitionsScreen> {
  bool _isLoading = true;
  List<dynamic> _petitions = [];

  @override
  void initState() {
    super.initState();
    _loadPetitions();
  }

  Future<void> _loadPetitions() async {
    if (mounted) setState(() => _isLoading = true);
    final data = await getMyPetitions();
    if (mounted) {
      setState(() {
        _petitions = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleResolve(String id) async {
    final success = await resolveComplaint(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Great! Glad the issue was resolved.')),
      );
      _loadPetitions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('My Petitions', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _petitions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _petitions.length,
                  itemBuilder: (context, index) => _buildPetitionCard(_petitions[index]),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_edu, size: 80, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text('No petitions yet', style: TextStyle(color: AppColors.textMuted, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Submit your first complaint to see it here.', style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildPetitionCard(Map<String, dynamic> p) {
    final status = p['status'] ?? 'active';
    final upvotes = p['upvote_count'] ?? 0;
    final date = DateTime.parse(p['created_at']);
    final isResolved = status == 'resolved';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isResolved ? AppColors.resolved.withOpacity(0.1) : AppColors.teal.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    isResolved ? Icons.check_circle : Icons.pending_actions,
                    size: 16,
                    color: isResolved ? AppColors.resolved : AppColors.teal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isResolved ? 'RESOLVED' : 'IN PROGRESS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isResolved ? AppColors.resolved : AppColors.teal,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM dd, yyyy').format(date),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p['complaint_text'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  _buildTimeline(status, upvotes),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.thumb_up_alt_outlined, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text('$upvotes supporters', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      if (!isResolved)
                        TextButton.icon(
                          onPressed: () => _handleResolve(p['id'].toString()),
                          icon: const Icon(Icons.done_all, size: 18),
                          label: const Text('Mark as Resolved'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.resolved),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(String status, int upvotes) {
    bool step1 = true; // Submitted
    bool step2 = upvotes >= 5; // Community supported
    bool step3 = upvotes >= 15; // Collective petition sent (logic)
    bool step4 = status == 'resolved';

    return Column(
      children: [
        _buildTimelineStep('Submitted', 'Petition drafted and filed', step1, true),
        _buildTimelineStep('Community supported', '5+ upvotes received', step2, true),
        _buildTimelineStep('Collective action', 'Aggregated with nearby issues', step3, true),
        _buildTimelineStep('Resolved', 'Issue fixed and closed', step4, false),
      ],
    );
  }

  Widget _buildTimelineStep(String title, String desc, bool completed, bool hasNext) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed ? AppColors.resolved : AppColors.border,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
              ),
              if (hasNext)
                Expanded(
                  child: Container(
                    width: 2,
                    color: completed ? AppColors.resolved : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: completed ? AppColors.textDark : AppColors.textMuted,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 11, color: completed ? AppColors.textMuted : AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
