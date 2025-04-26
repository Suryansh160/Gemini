import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  final ChatUser _currentUser = ChatUser(
    id: '1',
    firstName: 'Suryansh',
    lastName: 'Gupta',
  );

  final ChatUser _AIUser = ChatUser(
    id: '2',
    firstName: 'Gemini',
    profileImage:
        'https://images.seeklogo.com/logo-png/61/1/gemini-icon-logo-png_seeklogo-611605.png',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gemini'), backgroundColor: Color(0xFF303134)),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(
        trailing: [
          IconButton(
            onPressed: _sendMediaMessage,
            icon: const Icon(Icons.image),
          ),
        ],
      ),
      currentUser: _currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  void _sendMessage(ChatMessage chatMessages) {
    setState(() {
      messages = [chatMessages, ...messages];
    });

    try {
      String question = chatMessages.text;
      List<Uint8List>? images;
      if (chatMessages.medias?.isNotEmpty ?? false) {
        images = [File(chatMessages.medias!.first.url).readAsBytesSync()];
      }

      gemini.streamGenerateContent(question, images: images).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == _AIUser) {
          lastMessage = messages.removeAt(0);
          String response =
              event.content?.parts
                  ?.whereType<TextPart>()
                  .map((part) => part.text)
                  .join(" ")
                  .replaceAll('*', '')
                  .trim() ??
              "";
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response =
              event.content?.parts
                  ?.whereType<TextPart>()
                  .map((part) => part.text)
                  .join(" ")
                  .replaceAll('*', '')
                  .trim() ??
              "";

          ChatMessage message = ChatMessage(
            user: _AIUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: _currentUser,
        createdAt: DateTime.now(),
        text: "Describe this picture.",
        medias: [
          ChatMedia(url: file.path, fileName: "", type: MediaType.image),
        ],
      );
      _sendMessage(chatMessage);
    }
  }
}
