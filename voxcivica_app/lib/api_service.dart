import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

// ⚠️ Update this every time you restart ngrok
const String baseUrl = 'https://voxcivica-production.up.railway.app';

Future<String> generatePetition(
    String complaint, String location, String language, String urgency) async {
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/generate-petition'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'complaint': complaint,
        'location': location,
        'language': language,
        'urgency': urgency,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['petition'];
    }
    return 'Error: Server returned ${res.statusCode}. Try again.';
  } catch (e) {
    return 'Error connecting to server: $e';
  }
}

Future<String> analyzePhoto(String base64Image) async {
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/analyze-photo'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({'image_base64': base64Image}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['description'];
    }
    return 'Could not analyze photo.';
  } catch (e) {
    return 'Error analyzing photo: $e';
  }
}

Future<List<Map<String, dynamic>>> getComplaints() async {
  try {
    final res = await http.get(
      Uri.parse('$baseUrl/get-complaints'),
      headers: {'ngrok-skip-browser-warning': 'true'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['complaints'] as List;
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  } catch (e) {
    return [];
  }
}

Future<String> clusterPetition(List<String> ids, String location) async {
  try {
    final request = http.Request('POST', Uri.parse('$baseUrl/cluster-petition'));
    request.headers['Content-Type'] = 'application/json';
    request.headers['ngrok-skip-browser-warning'] = 'true';
    request.body = jsonEncode({'complaint_ids': ids, 'location': location});

    final response = await request.send();
    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final json = jsonDecode(resBody);
      return json['collective_petition'];
    }
    return 'Error generating collective petition.';
  } catch (e) {
    debugPrint('Error clustering petitions: $e');
    return 'Error connecting to server: $e';
  }
}

Future<bool> flagComplaint(String complaintId) async {
  final url = Uri.parse('$baseUrl/flag-complaint');
  final userEmail = Supabase.instance.client.auth.currentUser?.email ?? 'anonymous@test.com';

  final request = http.Request('POST', url);
  request.headers['Content-Type'] = 'application/json';
  request.body = jsonEncode({
    'complaint_id': complaintId,
    'user_email': userEmail,
    'reason': 'Flagged by community',
  });

  try {
    final response = await request.send();
    return response.statusCode == 200;
  } catch (e) {
    debugPrint('Error flagging complaint: $e');
    return false;
  }
}

Future<bool> upvoteComplaint(String complaintId) async {
  final url = Uri.parse('$baseUrl/upvote-complaint');
  final userEmail = Supabase.instance.client.auth.currentUser?.email ?? 'anonymous@test.com';

  final request = http.Request('POST', url);
  request.headers['Content-Type'] = 'application/json';
  request.body = jsonEncode({
    'complaint_id': complaintId,
    'user_email': userEmail,
  });

  try {
    final response = await request.send();
    return response.statusCode == 200;
  } catch (e) {
    debugPrint('Error upvoting complaint: $e');
    return false;
  }
}

Future<int> validateComplaint(String complaintText) async {
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/validate-complaint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'complaint': complaintText}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['urgency_level'] ?? 1;
    }
  } catch (e) {
    debugPrint('Error validating complaint: $e');
  }
  return 1;
}

Future<Map<String, dynamic>?> ratePetition(String petitionText) async {
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/rate-petition'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'petition_text': petitionText}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
  } catch (e) {
    debugPrint('Error rating petition: $e');
  }
  return null;
}

Future<List<dynamic>> getMyPetitions() async {
  final userEmail = Supabase.instance.client.auth.currentUser?.email;
  if (userEmail == null) return [];
  try {
    final encodedEmail = Uri.encodeComponent(userEmail);
    final res = await http.get(Uri.parse('$baseUrl/my-petitions?user_email=$encodedEmail'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['petitions'] ?? [];
    }
  } catch (e) {
    debugPrint('Error getting my petitions: $e');
  }
  return [];
}

Future<bool> resolveComplaint(String complaintId) async {
  final userEmail = Supabase.instance.client.auth.currentUser?.email;
  if (userEmail == null) return false;
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/resolve-complaint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'complaint_id': complaintId, 'user_email': userEmail}),
    );
    return res.statusCode == 200;
  } catch (e) {
    debugPrint('Error resolving complaint: $e');
  }
  return false;
}

Future<String?> saveComplaint(
    String text, String petition, double lat, double lng, String category,
    String locationName, String tone, String language, int urgencyLevel) async {
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/save-complaint'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'user_email': Supabase.instance.client.auth.currentUser?.email ?? 'anonymous@example.com',
        'location_name': locationName,
        'text': text,
        'petition': petition,
        'lat': lat,
        'lng': lng,
        'category': category,
        'tone': tone,
        'language': language,
        'urgency_level': urgencyLevel,
      }),
    );
    if (res.statusCode == 200) return null;
    final body = jsonDecode(res.body);
    return body['detail'] ?? 'Failed to save complaint';
  } catch (e) {
    return 'Error: $e';
  }
}
