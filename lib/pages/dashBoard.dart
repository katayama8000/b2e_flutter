import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
//toast
import 'package:fluttertoast/fluttertoast.dart';
//現在時刻を取得
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DashBoard extends StatefulWidget {
  String userName;
  DashBoard(this.userName, {Key? key}) : super(key: key);

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

  //出退勤
  registerInOut(String inOutType) async {
    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request('POST',
        Uri.parse('http://stimeapp.snapshot.co.jp/ss/stk/record/recordTime'));
    request.bodyFields = {
      'inoutType': inOutType,
      'cardId': '1010212',
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    String workState = inOutType == "1" ? "出勤" : "退勤";
    if (response.statusCode == 200) {
      var ret = await response.stream.bytesToString();
      print(ret);
      bool res = ret.contains(widget.userName);
      if (res) {
        String finishWorKingTime = getLocalTime();
        showToast('$finishWorKingTime/$workStateしました');
      } else {
        print(response.reasonPhrase);
        showToastFail('$workStateに失敗しました');
      }
    } else {
      print(response.reasonPhrase);
      showToastFail('$workStateに失敗しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 120, 86, 255),
        centerTitle: true,
        title: const Text('B2Epro - Dashborad',
            style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.userName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                RegisterButton(
                    label: "出勤", onPressed: () => registerInOut("1")),
                RegisterButton(
                    label: "退勤", onPressed: () => registerInOut("2")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  RegisterButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: 200,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: const Color.fromARGB(255, 120, 86, 255),
              onPrimary: Colors.white),
          onPressed: onPressed,
          child: Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
