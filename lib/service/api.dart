import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> localAPITest() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/comments');
    final response = await http.get(url);
    print("うわあああああああああああああああああああああああああああ");
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
