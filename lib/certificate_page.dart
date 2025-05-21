import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:html' as html;

enum CertificateType { achievement, completion, participation }

class CertificatePage extends StatefulWidget {
  const CertificatePage({super.key});

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final TextEditingController _nameController = TextEditingController();

  CertificateType _selectedType = CertificateType.achievement;

  final Map<CertificateType, Map<String, String>> _eventDetails = {
    CertificateType.achievement: {
      'event': 'National Coding Olympiad',
      'date': 'May 25, 2025',
    },
    CertificateType.completion: {
      'event': 'Flutter Bootcamp',
      'date': 'June 1, 2025',
    },
    CertificateType.participation: {
      'event': 'AI Seminar',
      'date': 'April 15, 2025',
    },
  };

  String get _templateAsset {
    switch (_selectedType) {
      case CertificateType.achievement:
        return 'assets/a.png';
      case CertificateType.completion:
        return 'assets/c.png';
      case CertificateType.participation:
        return 'assets/p.png';
    }
  }

  String get _eventName => _eventDetails[_selectedType]!['event']!;
  String get _eventDate => _eventDetails[_selectedType]!['date']!;

  TextStyle _getFontStyle(double size, {FontWeight? weight}) {
    switch (_selectedType) {
      case CertificateType.participation:
        return GoogleFonts.poppins(
          fontSize: size,
          color: Colors.red.shade900,
          fontWeight: weight,
        );
      case CertificateType.completion:
        return GoogleFonts.inriaSerif(
          fontSize: size,
          color: Colors.red.shade900,
          fontWeight: weight,
        );
      case CertificateType.achievement:
        return GoogleFonts.quicksand(
          fontSize: size,
          color: Colors.red.shade900,
          fontWeight: weight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Download Certificate")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              Screenshot(
                controller: _screenshotController,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(_templateAsset, width: 600),
                    // Name
                    Positioned(
                      top: 179,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          _nameController.text.isEmpty
                              ? "Your Name"
                              : _nameController.text,
                          style: _getFontStyle(30, weight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Event Name
                    Positioned(
                      top: 245,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          _eventName,
                          style: _getFontStyle(20).copyWith(
                            color: const Color.fromARGB(255, 118, 11, 11),
                          ),
                        ),
                      ),
                    ),
                    // Date
                    Positioned(
                      top: 290,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          _eventDate,
                          style: _getFontStyle(15).copyWith(
                            color: const Color.fromARGB(255, 121, 13, 13),
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
