import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:html' as html;

enum CertificateType { achievement, completion, attendance }

class CertificatePage extends StatefulWidget {
  const CertificatePage({super.key});

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final TextEditingController _nameController = TextEditingController();

  CertificateType _selectedType = CertificateType.achievement;

  // Example event details for each template
  final Map<CertificateType, Map<String, String>> _eventDetails = {
    CertificateType.achievement: {
      'event': 'National Coding Olympiad',
      'date': 'May 25, 2025',
    },
    CertificateType.completion: {
      'event': 'Flutter Bootcamp',
      'date': 'June 1, 2025',
    },
    CertificateType.attendance: {
      'event': 'AI Seminar',
      'date': 'April 15, 2025',
    },
  };

  String get _templateAsset {
    switch (_selectedType) {
      case CertificateType.achievement:
        return 'assets/achievement.png';
      case CertificateType.completion:
        return 'assets/complete.png';
      case CertificateType.attendance:
        return 'assets/part.png';
    }
  }

  String get _eventName => _eventDetails[_selectedType]!['event']!;
  String get _eventDate => _eventDetails[_selectedType]!['date']!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Download Certificate")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dropdown to select template
              DropdownButton<CertificateType>(
                value: _selectedType,
                items:
                    CertificateType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.name[0].toUpperCase() + type.name.substring(1),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Name input
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Enter your name",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 20),
              // Certificate preview with overlay
              Screenshot(
                controller: _screenshotController,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(_templateAsset, width: 600),
                    // Name
                    Positioned(
                      top: 250, // Adjust for your template
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          _nameController.text.isEmpty
                              ? "Your Name"
                              : _nameController.text,
                          style: TextStyle(
                            fontSize: 36,
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Event Name
                    Positioned(
                      top: 320, // Adjust for your template
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          _eventName,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ),
                    // Date
                    Positioned(
                      top: 370, // Adjust for your template
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          _eventDate,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final Uint8List? imageBytes =
                      await _screenshotController.capture();
                  if (imageBytes != null) {
                    final blob = html.Blob([imageBytes]);
                    final url = html.Url.createObjectUrlFromBlob(blob);
                    final anchor =
                        html.AnchorElement(href: url)
                          ..setAttribute("download", "certificate.png")
                          ..click();
                    html.Url.revokeObjectUrl(url);
                  }
                },
                child: const Text("Download as PNG"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
