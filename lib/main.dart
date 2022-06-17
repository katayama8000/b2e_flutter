import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

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

  @override
  void initState() {
    //アプリ起動時に一度だけ実行される
    getCsrf();
  }

  //CSRFトークンを取得する(htmlからスクレイピングする)
  void getCsrf() async {
    try {
      final response = await http.get(Uri.parse(url));
      final document = parse(response.body);
      final result = document.querySelector('[name="_csrf"]');
      print(result?.attributes['value']);
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 103, 21),
        centerTitle: true,
        // title: Image.network(
        //   'http://stimeapp.snapshot.co.jp/ss/share/base/logo',
        // ),
        title: Text('B2Epro - flutter', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("ユーザーID"),
            TextField(),
            Text("パスワード"),
            TextField(),
          ],
        ),
      ),
    );
  }
}
