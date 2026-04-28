import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_service.dart';
import '../app_theme.dart';

class PetitionScreen extends StatefulWidget {
  final String petitionText;
  final String complaint;
  final String location;
  final String language;

  const PetitionScreen({
    super.key,
    required this.petitionText,
    required this.complaint,
    required this.location,
    required this.language,
  });

  @override
  State<PetitionScreen> createState() => _PetitionScreenState();
}

class _PetitionScreenState extends State<PetitionScreen> {
  late TextEditingController _petitionCtrl;
  String _selectedTone = 'polite';
  bool _isLoading = false;
  String _department = '';

  final Map<String, String> _toneLabels = {
    'polite': 'Polite',
    'firm': 'Firm',
    'formal': 'Formal',
  };

  final Map<String, Color> _deptColors = {
    'Roads': const Color(0xFFE67E22),
    'Electricity': const Color(0xFF8E44AD),
    'Water': const Color(0xFF2980B9),
    'Municipal': const Color(0xFF27AE60),
    'Public Works': const Color(0xFFC0392B),
  };

  @override
  void initState() {
    super.initState();
    _petitionCtrl = TextEditingController(text: widget.petitionText);
    _extractDepartment(widget.petitionText);
    _fetchRating();
  }

  Map<String, dynamic>? _petitionRating;
  bool _isRating = false;

  Future<void> _fetchRating() async {
    setState(() => _isRating = true);
    final rating = await ratePetition(_petitionCtrl.text);
    if (mounted) {
      setState(() {
        _petitionRating = rating;
        _isRating = false;
      });
    }
  }

  @override
  void dispose() {
    _petitionCtrl.dispose();
    super.dispose();
  }

  void _extractDepartment(String text) {
    final lines = text.split('\n');
    for (final line in lines.reversed) {
      if (line.trim().toUpperCase().startsWith('DEPARTMENT:')) {
        setState(() {
          _department = line.replaceFirst(RegExp(r'DEPARTMENT:\s*', caseSensitive: false), '').trim();
        });
        return;
      }
    }
    setState(() => _department = 'Government Department');
  }

  Color _getDeptColor() {
    for (final key in _deptColors.keys) {
      if (_department.toLowerCase().contains(key.toLowerCase())) {
        return _deptColors[key]!;
      }
    }
    return const Color(0xFF1A73E8);
  }

  Future<void> _regenerate(String tone) async {
    setState(() {
      _selectedTone = tone;
      _isLoading = true;
    });
    final result = await generatePetition(widget.complaint, widget.location, widget.language, tone);
    setState(() {
      _petitionCtrl.text = result;
      _isLoading = false;
    });
    _extractDepartment(result);
    _fetchRating();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _petitionCtrl.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 8),
          Text('Petition copied to clipboard!'),
        ]),
        backgroundColor: AppColors.resolved,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _submitPetition() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.check_circle, color: AppColors.resolved, size: 28),
          SizedBox(width: 8),
          Text('Petition Submitted!'),
        ]),
        content: const Text(
          'Your petition has been saved!\n\nA follow-up reminder will be drafted in 14 days if no action is taken.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Your Petition',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy petition',
            onPressed: _copyToClipboard,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1A73E8)),
                  SizedBox(height: 16),
                  Text('Regenerating petition...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                // Department Badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_getDeptColor().withOpacity(0.1), Colors.white],
                    ),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Addressed to:',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Chip(
                        label: Text(
                          _department,
                          style: TextStyle(
                            color: _getDeptColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        backgroundColor: _getDeptColor().withOpacity(0.1),
                        side: BorderSide(color: _getDeptColor().withOpacity(0.3)),
                        avatar: Icon(Icons.account_balance, size: 16, color: _getDeptColor()),
                      ),
                    ],
                  ),
                ),

                // Tone Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const Text('Tone:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      ..._toneLabels.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(e.value, style: const TextStyle(fontSize: 13)),
                              selected: _selectedTone == e.key,
                              onSelected: (_) => _regenerate(e.key),
                              selectedColor: AppColors.teal,
                              labelStyle: TextStyle(
                                color: _selectedTone == e.key ? AppColors.white : AppColors.textDark,
                                fontWeight: _selectedTone == e.key
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),

                // Petition Text
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _petitionCtrl,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13.5,
                        height: 1.6,
                        color: AppColors.textDark,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: 'Your petition will appear here...',
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),

                // Rating Box
                if (_isRating)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_petitionRating != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 8),
                            Text(
                              'AI Quality Score: ${_petitionRating!['score'] ?? 0}/10',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.thumb_up, size: 16, color: Color(0xFFB45309)),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Strongest Part: ${_petitionRating!['strongest_part'] ?? ''}', style: const TextStyle(fontSize: 12))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.tips_and_updates, size: 16, color: Color(0xFFB45309)),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Suggestion: ${_petitionRating!['one_improvement'] ?? ''}', style: const TextStyle(fontSize: 12))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _regenerate(_selectedTone),
                            icon: const Icon(Icons.auto_awesome, size: 16, color: Color(0xFFB45309)),
                            label: const Text('Improve this petition', style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.bold)),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFDE68A).withOpacity(0.5),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _submitPetition,
                          icon: const Icon(Icons.send_rounded),
                          label: const Text('Submit Petition',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
