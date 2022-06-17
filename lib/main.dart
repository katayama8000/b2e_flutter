import 'package:flutter/material.dart';
//import 'package:dio/dio.dart';
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
  String csrf = "";
  late String userId;
  late String password;

  //final myController = TextEditingController();

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
      setState(() {
        csrf = result?.attributes['value'] ?? "";
      });
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 1, 79, 15),
        centerTitle: true,
        title: Text('B2Epro - flutter', style: TextStyle(color: Colors.white)),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'userId',
              ),
              onChanged: (value) {
                userId = value;
              },
            ),
            TextField(
              //controller: myController,
              decoration: const InputDecoration(
                hintText: 'password',
              ),
              onChanged: (value) {
                password = value;
              },
            ),
            OutlinedButton(
              child: const Text('SEND'),
              onPressed: () {
                print(csrf);
                print(userId);
                print(password);
              },
            ),
          ],
        ),
      ),
    );
  }
}
