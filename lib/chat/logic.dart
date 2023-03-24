import 'dart:convert';

import 'package:get/get.dart';
import 'package:wenwen/api_provider.dart';

import 'state.dart';

class ChatLogic extends GetxController {
  final ChatState state = ChatState();
  final ApiProvider provider = ApiProvider();

  Future<void> sendMessage(String content) async {
    state.requestStatus(content);
    update();
    final response = await provider.completions(json.encode({
      "model": "gpt-3.5-turbo",
      "messages": [{"role": "user", "content": "$content"}]
    }));
    try {
      if(response.statusCode == 200) {
        final data = response.body;
        final text = data['choices'][0]['message']['content'];
        state.responseStatus(text);
      } else {
        state.responseStatus(response.statusText ?? '请求错误，请稍后重试');
      }
    } catch(error) {
      state.responseStatus(error.toString());
    }
    update();
  }
}
