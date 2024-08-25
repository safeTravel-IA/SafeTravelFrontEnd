import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:safetravelfrontend/providers/user_provider.dart';

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  late UserProvider _userProvider;
  String _fromLanguage = 'en'; // Default to English
  String _toLanguage = 'es';   // Default to Spanish
  TextEditingController _textController = TextEditingController();
  String? _translatedText;

  final Map<String, String> languageMap = {
    'English': 'en',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Arabic': 'ar-sa',
    'Turkish': 'tr',
    'Romanian': 'ro',
    // Add more languages and their codes as needed
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _userProvider = Provider.of<UserProvider>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildLanguageDropdown('from')),
                SizedBox(width: 8), // Adds some spacing between the dropdowns
                IconButton(
                  icon: Image.asset('assets/images/switch.png'),
                  onPressed: _swapLanguages,
                ),
                SizedBox(width: 8), // Adds some spacing between the dropdown and icon
                Expanded(child: _buildLanguageDropdown('to')),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Enter text to translate',
                      border: InputBorder.none,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Image.asset('assets/images/copy.png'),
                            onPressed: _copyText,
                          ),
                          IconButton(
                            icon: Image.asset('assets/images/no.png'),
                            onPressed: _clearText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_translatedText != null) ...[
                    SizedBox(height: 20),
                    Text(
                      'Translated Text:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _translatedText!,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: Image.asset('assets/images/copy.png'),
                          onPressed: _copyTranslatedText,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: Image.asset('assets/images/translate.png', height: 32),
                label: Text(''),
                onPressed: _translateText,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(String type) {
    String currentLanguageCode = type == 'from' ? _fromLanguage : _toLanguage;
    String currentLanguageName = languageMap.keys.firstWhere(
      (key) => languageMap[key] == currentLanguageCode,
      orElse: () => 'English',
    );

    return DropdownButton<String>(
      isExpanded: true,
      value: currentLanguageName,
      items: languageMap.keys.map((String language) {
        return DropdownMenuItem<String>(
          value: language,
          child: Row(
            children: [
              Image.asset('assets/images/${languageMap[language]}.png', width: 24, height: 24),
              SizedBox(width: 8),
              Text(language),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          if (type == 'from') {
            _fromLanguage = languageMap[value!]!;
          } else {
            _toLanguage = languageMap[value!]!;
          }
        });
      },
    );
  }

  void _swapLanguages() {
    setState(() {
      String temp = _fromLanguage;
      _fromLanguage = _toLanguage;
      _toLanguage = temp;
    });
  }

  void _clearText() {
    setState(() {
      _textController.clear();
      _translatedText = null;
    });
  }

  void _copyText() {
    final data = ClipboardData(text: _textController.text);
    Clipboard.setData(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  void _copyTranslatedText() {
    final data = ClipboardData(text: _translatedText ?? "");
    Clipboard.setData(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Translated text copied to clipboard')),
    );
  }

  Future<void> _translateText() async {
    final userId = _userProvider.userId;

    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter text to translate')),
      );
      return;
    }

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID is missing')),
      );
      return;
    }

    try {
      await _userProvider.translateText(
        text: _textController.text,
        from: _fromLanguage,
        to: _toLanguage,
        userId: userId,
      );

      setState(() {
        _translatedText = _userProvider.translationResult;
      });

      if (_userProvider.translationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_userProvider.translationError!)),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Translation failed: $error')),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
