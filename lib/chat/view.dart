import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class ChatPage extends StatelessWidget {
  ChatPage({Key? key}) : super(key: key);

  final logic = Get.put(ChatLogic());
  final state = Get.find<ChatLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('你问我答'),
      ),
      body: GetBuilder<ChatLogic>(
        builder: (context) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: state.messages.length,
                itemBuilder: (BuildContext context, int index) {
                  Map m = state.messages[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: m['sender'] == 'user'
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: m['sender'] == 'user'
                                  ? Colors.green[100]
                                  : Colors.white,
                            ),
                            child: Text(m['text']),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          decoration: InputDecoration(
                            hintText: '请输入消息',
                            border: InputBorder.none,
                          ),
                          controller:
                              TextEditingController(text: state.message),
                          onChanged: (value) {
                            state.message = value;
                          }),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: state.isRequesting
                        ? null
                        : () {
                            logic.sendMessage(state.message);
                          },
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
