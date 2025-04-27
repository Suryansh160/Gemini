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
    profileImage: 'assets/logo.png',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1C1D),
      appBar: AppBar(
        leading: Icon(Icons.menu),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.apps))],
        title: Text('Gemini'),
        backgroundColor: Color(0xFF303134),
        foregroundColor: Colors.white,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(
        sendButtonBuilder: (send) {
          return IconButton(
            onPressed: send,
            icon: Icon(Icons.send, color: Colors.white),
          );
        },
        inputTextStyle: TextStyle(color: Colors.white),
        inputDecoration: InputDecoration(
          hintText: "Ask Gemini",
          filled: true,
          fillColor: Color(0xFF1B1C1D),
          hintStyle: TextStyle(color: Colors.grey),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),

        trailing: [
          IconButton(
            onPressed: _sendMediaMessage,
            icon: Icon(Icons.image, color: Colors.grey),
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
