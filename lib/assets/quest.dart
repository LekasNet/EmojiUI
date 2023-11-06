import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;


Future<Map<String, dynamic>> loadConfig() async {
  String jsonString = await rootBundle.loadString('config.json');
  return json.decode(jsonString);
}


class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<Quest> futureQuest;
  late Map<String, dynamic> _config;

  @override
  void initState() {
    super.initState();
    loadConfig().then((config) {
      setState(() {
        _config = config;
        futureQuest = fetchQuest();
      });
    });
  }

  Future<Quest> fetchQuest() async {
    final response = await http.get(Uri.parse('${_config["apiUrl"]}/quest'));

    if (response.statusCode == 200) {
      print('Server response: ${response.body}');
      // Добавьте обработку ошибки здесь, на случай если JSON не содержит нужные ключи
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['answer'] == null) {
        throw Exception('Missing correct answer');
      }
      if (jsonResponse['image_url'] == null) {
        throw Exception('Missing image');
      }
      if (jsonResponse['options'] == null) {
        throw Exception('Missing options');
      }
      return Quest.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load quest');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<Quest>(
          future: futureQuest,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              print(snapshot);
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData && snapshot.data != null) {
              // Проверяем, не содержит ли snapshot.data значение null перед использованием
              return buildQuest(snapshot.data!);
            } else {
              return Text("No quest found");
            }
          },
        ),
      ),
    );
  }

  Widget buildQuest(Quest quest) {
    // Количество элементов в строке
    int crossAxisCount = 2;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Image.network(quest.imageUrl, width: 300, height: 300),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              // Количество элементов в строке
              crossAxisSpacing: 10.0,
              // Расстояние между элементами по горизонтали
              mainAxisSpacing: 10.0,
              // Расстояние между элементами по вертикали
              childAspectRatio: 3 /
                  1, // Соотношение сторон каждого дочернего элемента
            ),
            itemCount: quest.options.length,
            itemBuilder: (context, index) {
              return ElevatedButton(
                onPressed: () {
                  if (quest.options[index] == quest.correctAnswer) {
                    // Handle correct answer
                  } else {
                    // Handle wrong answer
                  }
                },
                child: Text(quest.options[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Quest {
  final String imageUrl;
  final List<String> options;
  final String correctAnswer;

  Quest({
    required this.imageUrl,
    required this.options,
    required this.correctAnswer,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      imageUrl: json['image_url'],
      options: List<String>.from(json['options']),
      correctAnswer: json['answer'],
    );
  }
}
