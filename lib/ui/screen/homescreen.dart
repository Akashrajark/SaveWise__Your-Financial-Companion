import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String responseTxt = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 16),
        reverse: true,
        itemBuilder: (context, index) {
          if (responseTxt.isNotEmpty) {
            return CustomTextBox(
              responseTxt: responseTxt,
            );
          } else if (responseTxt.isEmpty) {
            return const Text("error");
          } else {
            return const Text("unknown");
          }
        },
        separatorBuilder: (context, index) => const SizedBox(height: 5),
        itemCount: 1,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                color: Colors.purple,
                child: InkWell(
                  onTap: () async {
                    try {
                      final response = await post(
                        Uri.parse("https://api.openai.com/v1/chat/completions"),
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization':
                              'Bearer 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'
                        },
                        body: jsonEncode(
                          {
                            "model": "gpt-3.5-turbo",
                            "messages": [
                              {"role": "user", "content": _controller.text}
                            ],
                            "temperature": 0.7,
                          },
                        ),
                      );

                      if (response.statusCode >= 200 &&
                          response.statusCode < 300) {
                        Map<String, dynamic> data = jsonDecode(response.body);
                        // Process the successful response
                        Logger().e("Success: $data");

                        Map<String, dynamic> message =
                            data['choices'][0]['message'];
                        responseTxt = message['content'];
                        setState(() {});
                        Logger().e("result: $responseTxt");
                      } else {
                        // Handle the error response
                        Map<String, dynamic> errorData =
                            jsonDecode(response.body);
                        Logger().e("Error Code: ${errorData['code']}");
                        Logger().e(
                            "Error Message: ${errorData['error']['message']}");
                      }
                    } catch (error) {
                      // Handle other errors that might occur during the request
                      Logger().e("Error: $error");
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class CustomTextBox extends StatelessWidget {
  final String responseTxt;
  const CustomTextBox({
    super.key,
    required this.responseTxt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Material(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
          color: Colors.purple,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              responseTxt,
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ],
    );
  }
}
