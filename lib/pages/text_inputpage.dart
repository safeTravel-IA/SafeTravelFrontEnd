import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safetravelfrontend/pages/ownmessage_card.dart';
import 'package:safetravelfrontend/pages/replymessage_card.dart';
import 'dart:convert';


import 'package:safetravelfrontend/model/message_model.dart';

class TextInputPage extends StatefulWidget {
  const TextInputPage({super.key});

  @override
  State<TextInputPage> createState() => _TextInputPageState();
}

class _TextInputPageState extends State<TextInputPage> {
  final TextEditingController _textController = TextEditingController();
  bool sendButton = false;
  final ScrollController _scrollController = ScrollController();
  List<Messagemodel> messages = [];
  static const Color hintColor = Color(0xFFffffff); // Define a constant color
  static const Color orangeColor =
      Color(0xFFd48026); // Define the app's orange color

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage(String message) {
    setmessage("source", message);
  }

  void setmessage(String type, String message) {
    Messagemodel messageModel = Messagemodel(
      type: type,
      message: message,
      time: DateTime.now().toString(),
    );
    setState(() {
      messages.add(messageModel);
    });
  }

  Future<void> generateText() async {
    String userMessage = _textController.text;

    if (userMessage.isEmpty) {
      print("Enter some text from the user");
      return;
    }

    final url = Uri.parse('https://chatgem.onrender.com/generatethetext');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'history': [], // Send an empty chat history for now
          'userInput': userMessage,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('generatedText')) {
          String generatedText = responseData['generatedText'];
          setmessage("target", generatedText);

          // Update chat history with received updated history from the server
          if (responseData.containsKey('updatedHistory')) {
            List<dynamic> updatedChatHistory = responseData['updatedHistory'];
            // Process updated chat history
          }
        } else {
          print('Invalid response format');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        print(response.body);
        // Handle error
      }
    } catch (error) {
      print('Error: $error');
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          // Update isLoading state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topRight,
            colors: [
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length + 1,
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                    return const SizedBox(height: 70); // Spacer
                  }
                  return messages[index].type == "source"
                      ? OwnMessageCard(
                          message: messages[index].message ??
                              '', // Use null-aware operator
                          time: messages[index].time?.substring(10, 16) ??
                              '', // Use null-aware operator and provide a default value
                        )
                      : ReplyMessageCard(
                          message: messages[index].message ??
                              '', // Use null-aware operator
                          time: messages[index].time?.substring(10, 16) ??
                              '', // Use null-aware operator and provide a default value
                        );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: orangeColor.withOpacity(
                            0.5), // Change the color and lower opacity
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 1,
                        onChanged: (value) {
                          setState(() {
                            sendButton = value.isNotEmpty;
                          });
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type a message',
                          hintStyle: TextStyle(
                            color: hintColor.withOpacity(
                                0.5), // Change the hint color and lower opacity
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: sendButton
                        ? () {
                            sendMessage(_textController.text);
                            generateText();
                            _textController.clear();
                          }
                        : null,
                    icon: const Icon(Icons.send),
                    color: orangeColor, // Change the icon color
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}