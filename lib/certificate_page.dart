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
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  CertificateType _selectedType = CertificateType.achievement;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
  }

  void _updateEventDetailsForSelectedType(CertificateType type) {
    setState(() {
      _eventNameController.clear();
      _dateController.clear();
      _selectedDateTime = null;
    });
  }

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = picked;
        _dateController.text =
            "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Download Certificate")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                      _updateEventDetailsForSelectedType(value);
                    });
                  }
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
              const SizedBox(height: 16),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _eventNameController,
                  decoration: const InputDecoration(
                    labelText: "Enter event name",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: "Enter event date",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _selectDate(context);
                  },
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
                    Positioned(
                      top: 179,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          _nameController.text.isEmpty
                              ? "Your Name"
                              : _nameController.text,
                          textAlign: TextAlign.center,
                          style: _getFontStyle(30, weight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 245,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          _eventNameController.text.isEmpty
                              ? "Event Name"
                              : _eventNameController.text,
                          textAlign: TextAlign.center,
                          style: _getFontStyle(20).copyWith(
                            color: const Color.fromARGB(255, 118, 11, 11),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 290,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          _dateController.text.isEmpty
                              ? "Event Date"
                              : _dateController.text,
                          textAlign: TextAlign.center,
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
    _eventNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
