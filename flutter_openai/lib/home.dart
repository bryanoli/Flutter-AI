import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String>getOpenAIResponse(String prompt) async {
  await dotenv.load(fileName: '.env');
  final apiKey = dotenv.env['SECRET_KEY'];
  const endPoint = 'https://api.openai.com/v1/chat/completions';

  final response = await http.post(
    Uri.parse(endPoint),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({'prompt': prompt, 'max_tokens': 150}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['choices'][0]['text'];
  } else {
    throw Exception('Failed to load response');
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<String>? openAIResponse;

  @override
  void initState() {
    super.initState();
    openAIResponse = getOpenAIResponse('Complete the following text: Roses are red, violets are __');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: openAIResponse,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text('OpenAI Response: ${snapshot.data}');
            }
          },
        ),
      ),
    );
  }
}

