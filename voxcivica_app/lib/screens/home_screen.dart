import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../api_service.dart';
import '../app_theme.dart';
import 'petition_screen.dart';
import 'map_screen.dart';
import 'my_petitions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _complaintCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  Key _mapKey = UniqueKey();

  String _selectedLanguage = 'English';
  String _selectedTone = 'polite';
  bool _isListening = false;
  bool _isGenerating = false;
  bool _isAnalyzingPhoto = false;
  bool _speechAvailable = false;
  Uint8List? _selectedImageBytes;

  double? _userLat;
  double? _userLng;

  late AnimationController _micPulse;
  late Animation<double> _micScale;

  final List<String> _languages = ['English', 'Tamil', 'Hindi', 'Telugu'];

  final Map<String, Map<String, dynamic>> _toneMap = {
    'polite': {
      'label': 'Polite',
      'icon': Icons.sentiment_satisfied_alt_rounded,
      'color': AppColors.mint,
      'desc': 'Respectful & Courteous'
    },
    'firm': {
      'label': 'Firm',
      'icon': Icons.gavel_rounded,
      'color': AppColors.teal,
      'desc': 'Assertive & Direct'
    },
    'formal': {
      'label': 'Formal',
      'icon': Icons.account_balance_rounded,
      'color': AppColors.navy,
      'desc': 'Official Legal Tone'
    },
  };

  @override
  void initState() {
    super.initState();
    _micPulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _micScale = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _micPulse, curve: Curves.easeInOutSine));
    _initSpeech();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        _userLat = position.latitude;
        _userLng = position.longitude;
      });
    }
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(onStatus: (status) {
      if (status == 'done' || status == 'notListening') {
        if (mounted) {
          setState(() {
            _isListening = false;
            _micPulse.stop();
            _micPulse.reset();
          });
        }
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _micPulse.stop();
          _micPulse.reset();
        });
      }
    });
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _complaintCtrl.dispose();
    _locationCtrl.dispose();
    _micPulse.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Speech recognition not available. Please check permissions.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      _micPulse.stop();
      _micPulse.reset();
    } else {
      HapticFeedback.mediumImpact();
      setState(() => _isListening = true);
      _micPulse.repeat(reverse: true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _complaintCtrl.text = result.recognizedWords;
            _complaintCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: _complaintCtrl.text.length));
          });
        },
        localeId: _getLocale(),
      );
    }
  }

  String _getLocale() {
    switch (_selectedLanguage) {
      case 'Tamil':
        return 'ta_IN';
      case 'Hindi':
        return 'hi_IN';
      case 'Telugu':
        return 'te_IN';
      default:
        return 'en_US';
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 70, maxWidth: 1024);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _selectedImageBytes = bytes;
      _isAnalyzingPhoto = true;
    });

    try {
      final b64 = base64Encode(bytes);
      final description = await analyzePhoto(b64);
      setState(() {
        final existing = _complaintCtrl.text.trim();
        _complaintCtrl.text =
            existing.isEmpty ? description : '$existing\n\n$description';
        _complaintCtrl.selection = TextSelection.fromPosition(
            TextPosition(offset: _complaintCtrl.text.length));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to analyze photo: $e'),
            backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isAnalyzingPhoto = false);
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedImageBytes = null;
    });
  }

  Future<void> _generatePetition() async {
    final complaint = _complaintCtrl.text.trim();
    final location =
        "Local Municipality"; // Default location since UI is removed

    if (complaint.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Please describe your issue first',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() => _isGenerating = true);
    try {
      // 1. Generate the petition via Gemini
      final petition = await generatePetition(
          complaint, location, _selectedLanguage, _selectedTone);

      // 1.5 Generate severity score
      final urgencyLevel = await validateComplaint(complaint);

      // 2. Save complaint to community map
      final rand = Random();
      final lat = _userLat ?? (13.0827 + (rand.nextDouble() - 0.5) * 0.08);
      final lng = _userLng ?? (80.2707 + (rand.nextDouble() - 0.5) * 0.08);
      final error = await saveComplaint(complaint, petition, lat, lng,
          'general', location, _selectedTone, _selectedLanguage, urgencyLevel);

      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return; // STOP them from going to the petition screen
      }

      setState(() {
        _mapKey = UniqueKey(); // Force map reload
      });

      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PetitionScreen(
            petitionText: petition,
            complaint: complaint,
            location: location,
            language: _selectedLanguage,
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error generating petition: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: LayoutBuilder(builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 850;
        return CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildForm(),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 4,
                            child: _buildMapSection(),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildForm(),
                          const SizedBox(height: 48),
                          _buildMapSection(),
                        ],
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.navy.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.assured_workload_rounded,
                  color: AppColors.navy, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'VoxCivica AI',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language Selector
        Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              gradient: AppColors.navyToTeal,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Select Language',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      dropdownColor: AppColors.teal,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800),
                      items: _languages
                          .map(
                              (l) => DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedLanguage = v!),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 36),

        // Description step
        _sectionLabel('Step 1: Describe Issue'),
        const SizedBox(height: 10),
        _buildInputCard(),

        const SizedBox(height: 32),

        // Tone step
        _sectionLabel('Step 2: Petition Tone'),
        const SizedBox(height: 10),
        _buildToneSelector(),

        const SizedBox(height: 40),
        _buildGenerateButton(),
      ],
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 700,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.public_rounded,
                      color: AppColors.teal, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community Map',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'See issues reported near you & join collective petitions.',
                        style:
                            TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  MapScreen(key: _mapKey, isEmbedded: true),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton.small(
                      heroTag: 'history_btn',
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyPetitionsScreen())),
                      backgroundColor: AppColors.white,
                      child: const Icon(Icons.history_edu_rounded,
                          color: AppColors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _complaintCtrl,
            maxLines: 6,
            minLines: 4,
            style: const TextStyle(
                fontSize: 16, height: 1.5, color: Color(0xFF1E293B)),
            decoration: const InputDecoration(
              hintText:
                  'e.g., There is a huge pothole and someone might get hurt...',
              hintStyle: TextStyle(
                  color: Color(0xFF94A3B8), fontSize: 15, height: 1.5),
              contentPadding: EdgeInsets.all(20),
              border: InputBorder.none,
              filled: false,
            ),
          ),
          if (_selectedImageBytes != null)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _selectedImageBytes!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _removePhoto,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  if (_isAnalyzingPhoto)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AnimatedBuilder(
                    animation: _micScale,
                    builder: (_, child) => Transform.scale(
                      scale: _micScale.value,
                      child: child,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _toggleListening,
                      icon: Icon(
                        _isListening
                            ? Icons.stop_circle_rounded
                            : Icons.mic_rounded,
                        color: _isListening ? AppColors.white : AppColors.teal,
                      ),
                      label: Text(
                        _isListening ? 'Stop Listening' : 'Tap to Speak',
                        style: TextStyle(
                          color:
                              _isListening ? AppColors.white : AppColors.teal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isListening
                            ? AppColors.urgent
                            : AppColors.teal.withOpacity(0.1),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzingPhoto ? null : _pickPhoto,
                    icon: const Icon(Icons.add_a_photo_rounded,
                        color: Color(0xFF475569)),
                    label: const Text(
                      'Photo',
                      style: TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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

  Widget _buildToneSelector() {
    return Column(
      children: _toneMap.entries.map((e) {
        final selected = _selectedTone == e.key;
        final details = e.value;
        final Color themeColor = details['color'];

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedTone = e.key);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? themeColor.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? themeColor : const Color(0xFFE2E8F0),
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: themeColor.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: const Color(0xFF94A3B8).withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected ? themeColor : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    details['icon'],
                    color: selected ? Colors.white : const Color(0xFF64748B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details['label'],
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        details['desc'],
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: themeColor, size: 28),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generatePetition,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isGenerating
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text('Drafting Petition...',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 24),
                  SizedBox(width: 8),
                  Text('Generate Formal Petition',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ],
              ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: AppColors.navy,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
