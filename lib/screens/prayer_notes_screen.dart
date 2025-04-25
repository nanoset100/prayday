import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerNotesScreen extends StatefulWidget {
  const PrayerNotesScreen({super.key});

  @override
  State<PrayerNotesScreen> createState() => _PrayerNotesScreenState();
}

class _PrayerNotesScreenState extends State<PrayerNotesScreen> {
  late SharedPreferences _prefs;
  List<Map<String, dynamic>> _prayers = [];

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPrayers();
  }

  void _loadPrayers() {
    final List<String>? savedPrayers = _prefs.getStringList('saved_prayers');
    if (savedPrayers != null) {
      setState(() {
        _prayers =
            savedPrayers
                .map((json) => jsonDecode(json) as Map<String, dynamic>)
                .toList();
        // Sort by date in descending order (newest first)
        _prayers.sort((a, b) => b['date'].compareTo(a['date']));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('저장된 기도문'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _prayers.isEmpty
              ? const Center(
                child: Text('작성된 기도문이 없습니다', style: TextStyle(fontSize: 16)),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _prayers.length,
                itemBuilder: (context, index) {
                  final prayer = _prayers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prayer['date'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  prayer['emotion'],
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            prayer['text'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
