import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//機種の個別識別番号を取得する
import 'package:device_info_plus/device_info_plus.dart';
//ページ
import 'pages/dash_board.dart';
//メソッド
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
  String userId = "";
  String employeeNo = "";
  String userName = "";
  String deviceId = "";
  bool registerFlag = false;

  void pushDashBoardPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DashBoard(deviceId, employeeNo),
      ),
    );
  }

  registerDeviceId() async {
    registerFlag = true;
    if (!(userId.length == 10 || userId.length == 11)) {
      ToastService.showFailureToast("正しいIDではありません\nもう一度入力してください");
      return;
    }
    employeeNo = userId.substring(4, userId.length);
    var url =
        Uri.parse('http://stimeapp.snapshot.co.jp/ss/stk/record/card/update');
    var response = await http.post(url, body: {
      'cardId': deviceId,
      'employeeNo': employeeNo,
      'companyCode': '1000',
      'updateEmployeeId': '0',
    });
    searchCardId();
  }

  void getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo info = await deviceInfo.androidInfo;
    Map tmp = info.toMap();
    deviceId = tmp["id"];
    searchCardId();
  }

  void searchCardId() async {
    var url =
        Uri.parse('http://stimeapp.snapshot.co.jp/ss/stk/record/card/search');
    var response = await http.post(url, body: {
      'cardId': deviceId,
    });

    String ret = response.body;
    print(ret);

    int start = ret.indexOf("employeeNo");
    employeeNo = ret.substring(
        start + "employeeNo".length + 2, start + "employeeNo".length + 6);
    print(employeeNo);

    if (employeeNo == "null") {
      registerFlag == true
          ? ToastService.showFailureToast("正しいIDではありません\nもう一度入力してください")
          : ToastService.showFailureToast("IDを登録してください");
    } else {
      int start = ret.indexOf("employeeNo");
      employeeNo = ret.substring(
          start + "employeeNo".length + 3, start + "employeeNo".length + 9);
      pushDashBoardPage();
    }
  }

  //アプリ起動時に一度だけ実行される
  @override
  void initState() {
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
              OutlinedButton(
                child: const Text('機種識別番号登録'),
                onPressed: () {
                  registerDeviceId();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
