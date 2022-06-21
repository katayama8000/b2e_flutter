import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
//toast
import 'package:fluttertoast/fluttertoast.dart';

import 'pages/signup.dart';
import 'pages/dashBoard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: B2EPage());
  }
}

class B2EPage extends StatefulWidget {
  const B2EPage({Key? key}) : super(key: key);

  @override
  State<B2EPage> createState() => _B2EPageState();
}

class _B2EPageState extends State<B2EPage> {
  final url = 'http://stimeapp.snapshot.co.jp/ss/login';
  String csrf = "";
  String userId = "";
  String password = "";
  String location = "";
  String jsessionid = "";

  //toast成功
  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  //toast失敗
  void showToastFail(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  //成功したら、dashboardのHTMLを取得する
  Future<void> getTopPage(url, jsessionid) async {
    var headers = {
      'cookie':
          'JSESSIONID=$jsessionid; JSESSIONID=8E1CA7A0C2A67B81B946BD30894626AE'
    };
    var request =
        http.Request('GET', Uri.parse('http://stimeapp.snapshot.co.jp/ss/top'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(response.statusCode);
    print(response.headers);
    String html = await response.stream.bytesToString();

    final document = parse(html);
    print(document.querySelector('#emp-name')?.text);
    pushDashBoardPage();
  }

  //CSRFトークンを取得する(htmlからスクレイピングする)
  void getCsrf() async {
    try {
      final response = await http.get(Uri.parse(url));
      final document = parse(response.body);
      final result = document.querySelector('[name="_csrf"]');
      //print(result?.attributes['value']);
      csrf = result?.attributes['value'] ?? "";
    } catch (e) {
      throw Exception();
    }
  }

  //機種個体識別番号を登録するページに移動
  void pushRegisterDevicePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterDevice(),
      ),
    );
  }

  void pushDashBoardPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DashBoard(),
      ),
    );
  }

  //ログインに必要な情報をpostする
  void handleSignUp(csrf, userId, password) async {
    var url = Uri.parse('http://stimeapp.snapshot.co.jp/ss/login');
    var response = await http.post(url, body: {
      'userName': '1000100072',
      'password': '3edcvbnm',
      '_csrf': csrf
    });

    //リダイレクト成功
    if (response.statusCode == 302) {
      showToast("ログインに成功");
      location = response.headers["location"]!;
      jsessionid = response.headers["set-cookie"]!.substring(11, 43);

      //getTopPage(location, jsessionid);
    } else {
      showToastFail("ログインに失敗");
    }

    //成功した場合、それぞれの機種の個体識別番号を登録す
    pushRegisterDevicePage();
  }

  @override
  void initState() {
    //アプリ起動時に一度だけ実行される
    getCsrf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 120, 86, 255),
        centerTitle: true,
        title: Text('B2Epro - flutter', style: TextStyle(color: Colors.white)),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'userId',
                  ),
                  onChanged: (value) {
                    userId = value;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: TextField(
                  //controller: myController,
                  decoration: const InputDecoration(
                    hintText: 'password',
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                ),
              ),
              OutlinedButton(
                child: const Text('Login'),
                onPressed: () {
                  handleSignUp(csrf, userId, password);
                },
              ),
              OutlinedButton(
                onPressed: () => {pushRegisterDevicePage()},
                child: const Text('機種識別番号登録'),
              ),
              OutlinedButton(
                onPressed: () => {pushDashBoardPage()},
                child: const Text('ダッシュボード'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
