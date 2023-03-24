#### Flutter GetX 实现 ChatGPT 简单聊天界面

**Flutter 是一款跨平台的移动应用开发框架，而 GetX 是 Flutter 中一种简单易用的状态管理和路由管理工具。本篇我们将使用 Flutter 和 GetX 实现一个简单的聊天界面，以与 ChatGPT 进行交互。**

我们需要在 Flutter 项目中引入 GetX 库。在`pubspec.yaml`文件中添加以下依赖：

```
dependencies:
  flutter:
    sdk: flutter
  get:

```


在`main`函数中添加以下代码：

```
void main() {
  //在main函数第一行添加这句话
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GetMaterialApp(
    home: ChatPage(),
  ));
}
```

确保`Flutter Widgets`已经初始化，并且启动应用程序的`ChatPage`页面。

接下来，我们需要创建一个`ApiProvider`类，用于与 OpenAI API 进行交互。这个类继承自`GetConnect`，`GetConnect`是一个轻量级的 HTTP 客户端，它能够简化与 API 的通信过程。以下是`ApiProvider`类的代码：

```
class ApiProvider extends GetConnect {

  /// 这里填写自己OpenAI API Key
  final String apiKey = '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';
  final String baseUrl = 'https://api.openai.com';
  final Duration timeout = Duration(seconds: 30);

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  ApiProvider() {
    httpClient.baseUrl = baseUrl;
    httpClient.timeout = timeout;
    httpClient.addAuthenticator((request)  {
      request.headers.addAll(_headers());
      return request;
    });
  }

  Future<Response> completions(String body) {
    return post('/v1/chat/completions', body);
  }
}
```

在这个类中，我们设置了 API 的基础 URL 和超时时间，并实现了 HTTP 请求的授权和身份验证。我们还实现了`completions`方法，用于向 OpenAI API 发送请求并获取聊天机器人的回复。注意这里需要设置自己账号的API KEY， 地址： https://platform.openai.com/account/api-keys

接下来，我们需要创建一个`ChatLogic`类，用于处理聊天机器人的逻辑。以下是`ChatLogic类`的代码：

```
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
```

在这个类中，我们创建了一个`sendMessage`方法，该方法接收用户的消息并发送给 OpenAI API，然后等待 API 返回响应。在收到响应后，我们将从 API 返回的 JSON 数据中提取出回复消息的内容，并将其更新到`ChatState`状态类的`messages`列表中，然后在 UI 中显示。


接下来，我们需要创建一个`ChatState`类来管理我们的应用程序状态。以下是`ChatState`类的代码：

```
class ChatState {

  String message = '';
  String sender = 'user';
  bool isRequesting = false;
  List<Map<String, dynamic>> messages = [];

  void requestStatus(String content) {
    messages.add({'text': content, 'sender': 'user'});
    sender = 'bot';
    messages.add({'text': '正在回复中...', 'sender': sender});
    isRequesting = true;
    message = '';
  }

  void responseStatus(String content) {
    messages.removeLast(); // Remove "正在回复中..." 状态
    messages.add({'text': content, 'sender': sender});
    sender = 'user';
    isRequesting = false;
  }
}
```

在这个类中，存储了聊天应用程序的状态信息，包括消息、发送者、请求状态和历史消息列表。requestStatus()方法用于更新状态以反映正在发送消息的状态，responseStatus()方法用于更新状态以反映接收到的消息。


最后，我们定义了`ChatPage`类，它继承自`StatelessWidget`，它将用于展示聊天对话框。以下是`ChatPage`类的代码：

```
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
```

该类包含一个ChatLogic实例和一个ChatState实例。在build()方法中，我们使用GetBuilder包装整个聊天界面。这个界面包括一个消息列表和一个输入框，用户可以在其中输入消息并发送给聊天机器人。ListView.builder用于显示历史消息，TextField和IconButton用于接收用户输入并发送消息。在发送消息之前，会检查当前状态是否为请求状态，以避免重复发送请求。


到这里一个简单的聊天功能就完成了，运行下看看效果吧：

![openaichat_demo](./image/openai_chat_demo.gif)

**综上所述，本篇介绍了一个使用 Flutter 和 OpenAI API 实现的基于 GPT-3 的聊天机器人。通过实现`ApiProvider、ChatLogic`和`ChatState`类，我们能够将 OpenAI API 的功能集成到 Flutter 应用程序中，并实现一个基本的聊天界面。感兴趣的小伙们可以自己试试哈，Demo地址：https://github.com/smallmarker/OpenAIChat**
