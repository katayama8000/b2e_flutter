import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//機種の個別識別番号を取得する
import 'package:device_info_plus/device_info_plus.dart';

class RegisterDevice extends StatefulWidget {
  String employeeNo;
  RegisterDevice(this.employeeNo, {Key? key}) : super(key: key);

  // String userName;
  // DashBoard(this.userName, {Key? key}) : super(key: key);

  @override
  State<RegisterDevice> createState() => _RegisterDeviceState();
}

class _RegisterDeviceState extends State<RegisterDevice> {
  String deviceId = "";

  @override
  void initState() {
    //アプリ起動時に一度だけ実行される
    print("initState");
    getDeviceInfo();
  }

  //機種の個別識別番号を取得する
  void getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo info = await deviceInfo.androidInfo;
    var tmp = info.toMap();
    deviceId = tmp["id"];
    print(deviceId);
  }

  registerDeviceId() async {
    print(deviceId);
    print(widget.employeeNo);
    var url =
        Uri.parse('http://stimeapp.snapshot.co.jp/ss/stk/record/card/update');
    var response = await http.post(url, body: {
      'cardId': deviceId,
      'employeeNo': widget.employeeNo,
      'companyCode': '1000',
      'updateEmployeeId': '0',
    });

    print(response.body);
    print("デバイスを登録しました！");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 120, 86, 255),
        centerTitle: true,
        title: Text('B2Epro - flutter', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 120, 86, 255),
                      onPrimary: Colors.white),
                  onPressed: () => {print(widget.employeeNo)},
                  child: Text("Press to Confirm",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 300,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 120, 86, 255),
                          onPrimary: Colors.white),
                      onPressed: () => {registerDeviceId()},
                      child: Text(widget.employeeNo,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
