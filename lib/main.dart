import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

//機種の個別識別番号を取得する
import 'package:device_info_plus/device_info_plus.dart';
//ページ
import 'pages/signup.dart';
import 'pages/dashBoard.dart';
//メソッド
import 'service/api.dart';
import 'service/toast.dart';

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
  String employeeNo = "";
  String userName = "";
  String deviceId = "";

  //成功したら、dashboardのHTMLを取得する
  // Future<void> getTopPage(url, jsessionid) async {
  //   var headers = {'cookie': 'JSESSIONID=$jsessionid'};
  //   var request =
  //       http.Request('GET', Uri.parse('http://stimeapp.snapshot.co.jp/ss/top'));
  //   request.headers.addAll(headers);
  //   http.StreamedResponse response = await request.send();
  //   String html = await response.stream.bytesToString();
  //   final document = parse(html);
  //   userName = document.querySelector('#emp-name')!.text;
  //   print(userName);
  //   if (userName != null) {
  //     pushDashBoardPage();
  //   } else {
  //     ToastService.showFailureToast("初めからやり直してください");
  //   }
  // }

  //CSRFトークンを取得する(htmlからスクレイピングする)
  void getCsrf() async {
    try {
      final response = await http.get(Uri.parse(url));
      final document = parse(response.body);
      final result = document.querySelector('[name="_csrf"]');
      csrf = result?.attributes['value'] ?? "";
    } catch (e) {
      throw Exception();
    }
    //機種識別番号がすでにあるのか調べる
    //searchCardId();
  }

  void pushDashBoardPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DashBoard(deviceId, employeeNo),
      ),
    );
  }

  //ログインに必要な情報をpostする
  void handleSignIn(csrf, userId, password) async {
    var url = Uri.parse('http://stimeapp.snapshot.co.jp/ss/login');
    var response = await http.post(url,
        body: {'userName': userId, 'password': password, '_csrf': csrf});

    //リダイレクト成功
    if (response.statusCode == 302) {
      ToastService.showSuccessToast("ログインに成功");
      location = response.headers["location"]!;
      jsessionid = response.headers["set-cookie"]!.substring(11, 43);
      //getTopPage(location, jsessionid);
    } else {
      ToastService.showFailureToast("ログインに失敗");
    }
    //成功した場合、それぞれの機種の個体識別番号を登録す
    registerDeviceId();
  }

  registerDeviceId() async {
    employeeNo = userId.substring(4, userId.length);
    print("--------------------------");
    print(employeeNo);
    print("--------------------------");
    print(deviceId);
    var url =
        Uri.parse('http://stimeapp.snapshot.co.jp/ss/stk/record/card/update');
    var response = await http.post(url, body: {
      'cardId': deviceId,
      'employeeNo': employeeNo,
      'companyCode': '1000',
      'updateEmployeeId': '0',
    });

    String ret = response.body;
    bool res = ret.contains("更新しました");
    if (res) {
      ToastService.showSuccessToast("登録しました");
      searchCardId();
    } else {
      ToastService.showFailureToast("再度やり直してください");
    }
  }

  void getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo info = await deviceInfo.androidInfo;
    var tmp = info.toMap();
    deviceId = tmp["id"];
    print(deviceId);
  }

  void searchCardId() async {
    employeeNo = userId.substring(4, userId.length);
    print(deviceId);
    print(employeeNo);
    var url =
        Uri.parse('http://stimeapp.snapshot.co.jp/ss/stk/record/card/search');
    var response = await http.post(url, body: {
      'cardId': deviceId,
      'employeeNo': employeeNo,
    });

    print(response.body);
    if (response.body.contains(deviceId)) {
      print("登録済みなので移動");
      pushDashBoardPage();
    } else {
      print("ログインしてください");
    }
  }

  //アプリ起動時に一度だけ実行される
  @override
  void initState() {
    //csrf取得
    getCsrf();
    //機種識別番号取得
    getDeviceInfo();
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
                  handleSignIn(csrf, userId, password);
                },
              ),
              OutlinedButton(
                onPressed: () => {pushDashBoardPage()},
                child: const Text('ダッシュボード'),
              ),
              OutlinedButton(
                onPressed: () => {print(employeeNo), setState(() {})},
                child: Text(employeeNo),
              ),
              OutlinedButton(
                onPressed: () => {registerDeviceId()},
                child: const Text('登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
