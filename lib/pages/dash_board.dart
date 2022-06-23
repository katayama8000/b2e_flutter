import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
//toast
import 'package:b2e_flutter/service/toast.dart';
//現在時刻を取得
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DashBoard extends StatefulWidget {
  String cardId;
  String employeeNo;
  DashBoard(this.cardId, this.employeeNo, {Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  //時間を取得
  String getLocalTime() {
    tz.initializeTimeZones();
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
      'cardId': widget.cardId,
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    String workState = inOutType == "1" ? "出勤" : "退勤";
    if (response.statusCode == 200) {
      var ret = await response.stream.bytesToString();
      int start = ret.indexOf("empName");
      String userName =
          ret.substring(start + "empName".length + 3, ret.length - 2);

      bool res = ret.contains(widget.employeeNo);
      if (res) {
        String now = getLocalTime();
        ToastService.showSuccessToast('$userNameさんは\n$nowに$workStateしました');
      } else {
        ToastService.showFailureToast('$userNameさんは\n$workStateに失敗しました');
      }
    } else {
      print(response.reasonPhrase);
      ToastService.showFailureToast('再度やり直してください');
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
                    widget.cardId,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.employeeNo,
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

//ボタンコンポーネント
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
