import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_prayer.dart';
import '../widgets/tag_selector.dart';

class PrayerDetailScreen extends StatelessWidget {
  final UserPrayer prayer;

  const PrayerDetailScreen({super.key, required this.prayer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePrayer(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateTimeSection(),
            const SizedBox(height: 8),
            _buildTagSection(),
            const Divider(height: 24),
            _buildPrayerSection('Your Prayer', prayer.userInput),
            if (prayer.aiPrayer != null && prayer.aiPrayer!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildPrayerSection('AI Generated Prayer', prayer.aiPrayer!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          '${prayer.date} at ${prayer.time}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTagSection() {
    return Row(
      children: [
        const Icon(Icons.label, color: Colors.blue),
        const SizedBox(width: 8),
        const Text(
          '주제: ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TagChip(tag: prayer.tag, isSelected: true),
      ],
    );
  }

  Widget _buildPrayerSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Text(content, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  void _sharePrayer() {
    String shareText =
        'Prayer on ${prayer.date} at ${prayer.time}\n\n'
        'Topic: ${prayer.tag}\n\n'
        'My Prayer:\n${prayer.userInput}';

    if (prayer.aiPrayer != null && prayer.aiPrayer!.isNotEmpty) {
      shareText += '\n\nAI Generated Prayer:\n${prayer.aiPrayer!}';
    }

    Share.share(shareText);
  }
}
