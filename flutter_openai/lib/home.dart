import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'components/textfieldbldr.dart';
import 'components/promptbldr.dart';
import 'models/response_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final TextEditingController promptController;
  String responseText = '';
  late ResponseModel responseModel;

  @override
  void initState() {
    promptController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PromptBldr(responseText: responseText),
          TextFieldBuilder(
            promptController: promptController, btnFun: completionFun),
        ],
      ),
    );
  }
  completionFun() async {
    setState(() => responseText = 'Loading...');

    await Future.delayed(const Duration(seconds: 2)); // Introduce a delay


    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['SECRET_KEY']}',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': promptController.text},
        ],
        'max_tokens': 50,
        'temperature': 0,
        'top_p': 1,
      }),
    );

    if (response.statusCode == 200) {
      // Check if the response body is a JSON string
      if (response.headers['content-type']!.contains('application/json')) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          responseModel = ResponseModel.fromJson(responseData as String);
          responseText = responseModel.choices[0]['text'];
          debugPrint(responseText);
        });
      } else {
        // Handle the case where the response is not in the expected format
        setState(() {
          responseText = 'Error: Unexpected response format';
        });
      }
    } else {
      // Handle non-200 status code
      setState(() {
        responseText = 'Error: ${response.statusCode}';
      });
    }
}}

