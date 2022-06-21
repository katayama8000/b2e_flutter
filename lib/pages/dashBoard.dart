import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
//toast
import 'package:fluttertoast/fluttertoast.dart';
//現在時刻を取得
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
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

  //時間を取得
  String getLocalTime() {
    // タイムゾーンデータベースの初期化
    tz.initializeTimeZones();
// ローカルロケーションのタイムゾーンを東京に設定
    tz.setLocalLocation(tz.getLocation("Asia/Tokyo"));
    var now = tz.TZDateTime.now(tz.local);
    return ('${now.hour}時${now.minute}分');
  }

  //退勤
  work(String inOutType) async {
    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': 'JSESSIONID=D9A3AD5366ABEC5A8158FBA10F4723EF'
    };
    var request = http.Request('POST',
        Uri.parse('http://stimeapp.snapshot.co.jp/ss/stk/record/recordTime'));
    request.bodyFields = {
      'inOutType': inOutType,
      'cardId': '1010212',
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      String finishWorlingTime = getLocalTime();

      showToast('$finishWorlingTime/退勤しました');
    } else {
      print(response.reasonPhrase);
      showToastFail('退勤に失敗しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 1, 79, 15),
        centerTitle: true,
        title:
            Text('B2Epro - Dashborad', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            OutlinedButton(
              onPressed: () => {work("00")},
              child: const Text('出勤'),
            ),
            OutlinedButton(
              onPressed: () => {
                print(work("00")),
              },
              child: const Text('退勤'),
            ),
            OutlinedButton(
              onPressed: () => {
                print(getLocalTime()),
              },
              child: const Text('時間を取得'),
            ),
          ],
        ),
      ),
    );
  }
}
