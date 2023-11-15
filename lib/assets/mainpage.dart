import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'notifications.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;


Future<Map<String, dynamic>> loadConfig() async {
  String jsonString = await rootBundle.loadString('config.json');
  return json.decode(jsonString);
}


class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}


class CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver{
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late Map<String, dynamic> _config;
  bool isStreaming = false;
  String isShowed = "";
  Timer? _timer;
  int selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = CameraController(
      widget.cameras[selectedCameraIndex],
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
      enableAudio: false,
    );
    loadConfig().then((config) {
      setState(() {
        _config = config;
      });
    });
    _controller.setFlashMode(FlashMode.off);
    _initializeControllerFuture = _controller.initialize();
  }

  void deliter(){
      isShowed = "";
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_controller.value.isInitialized) {
        _controller.initialize().then((_) {
          // Если нужно возобновить потоковую передачу, вызывайте здесь _startStreaming
          if (isStreaming) {
            _startStreaming();
          }
          // Обновите состояние, если камера или поток требуют переинициализации
          setState(() {});
        });
      }
    }
  }

  void _startStreaming() async {
    await _initializeControllerFuture;
    const interval = Duration(seconds: 3); // Интервал между снимками
    _timer = Timer.periodic(interval, (timer) => _takePicture());
    setState(() => isStreaming = true);
    _controller.setFlashMode(FlashMode.off);
  }

  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized) {
      return;
    }
    // Если камера находится в процессе съемки, ничего не делаем.
    if (_controller.value.isTakingPicture) {
      return;
    }

    try {
      XFile file = await _controller.takePicture();
      Uint8List imageBytes = await file.readAsBytes();
      _sendImageToServer(imageBytes);
    } catch (e) {
      print(e);
    }
  }

  void _sendImageToServer(Uint8List imageData) async {
    var uri = Uri.parse('${_config["apiUrl"]}/upload');
    var request = http.MultipartRequest('POST', uri);

    // Создаём MultipartFile из Uint8List
    request.files.add(http.MultipartFile.fromBytes(
      'image', // Название поля для сервера, должно соответствовать тому, что ожидается на сервере
      imageData,
      filename: 'image.jpg', // Вы можете указать имя файла (необязательно)
    ));

    // Отправляем запрос
    var response = await request.send();

    Map<String, dynamic> emotions = _config["emotions"];

    switch (response.statusCode) {
      case 200:
        if (kDebugMode) {
          print('Upload successful! Face doesn\'t recognized');
        }
      case 201:
        Map<String, dynamic> emotion = emotions["disgust"];
        if (isShowed != "disgust") {
          isShowed == "disgust";
          showNotification(
            context,
            emotion["head"],
            emotion["body"],
            Color(int.parse(emotion["color"])),
              Color(int.parse(emotion["textColor"])),
            deliter
          );
        }
      case 202:
        Map<String, dynamic> emotion = emotions["fear"];
        if (isShowed != "fear") {
          isShowed == "fear";
          showNotification(
            context,
            emotion["head"],
            emotion["body"],
            Color(int.parse(emotion["color"])),
              Color(int.parse(emotion["textColor"])),
            deliter
          );
        }
      case 203:
        Map<String, dynamic> emotion = emotions["happy"];
        if (isShowed != "happy") {
          isShowed = "happy";
          showNotification(
            context,
            emotion["head"],
            emotion["body"],
            Color(int.parse(emotion["color"])),
              Color(int.parse(emotion["textColor"])),
            deliter
          );
        }
      case 204:
        Map<String, dynamic> emotion = emotions["sad"];
        if (isShowed != "sad") {
          isShowed = "sad";
          showNotification(
            context,
            emotion["head"],
            emotion["body"],
            Color(int.parse(emotion["color"])),
              Color(int.parse(emotion["textColor"])),
            deliter
          );
        }
      case 205:
        Map<String, dynamic> emotion = emotions["surprise"];
        if (isShowed != "surprise") {
          isShowed = "surprise";
          showNotification(
            context,
            emotion["head"],
            emotion["body"],
            Color(int.parse(emotion["color"])),
              Color(int.parse(emotion["textColor"])),
            deliter
          );
        }
      case 206:
        Map<String, dynamic> emotion = emotions["neutral"];
        if (isShowed != "neutral") {
          isShowed = "neutral";
          showNotification(
            context,
            emotion["head"],
            emotion["body"],
            Color(int.parse(emotion["color"])),
              Color(int.parse(emotion["textColor"])),
            deliter
          );
        }
      case 207:
        Map<String, dynamic> emotion = emotions["angry"];
        if (isShowed != "angry") {
          isShowed = "angry";
          showNotification(
              context,
              emotion["head"],
              emotion["body"],
              Color(int.parse(emotion["color"])),
              Color(int.parse(emotion["textColor"])),
              deliter
          );
        }
      default:
        if (kDebugMode) {
          print('Upload failed!');
        }
    }
  }

  void _stopStreaming() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() => isStreaming = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    setState(() => isStreaming = false);
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void _onSwitchCamera() {
    int newCameraIndex = selectedCameraIndex == 0 ? 1 : 0;

    if (widget.cameras.length > newCameraIndex) {
      _controller.dispose().then((_) {
        _controller = CameraController(
          widget.cameras[newCameraIndex],
          ResolutionPreset.medium,
        );
        setState(() {
          selectedCameraIndex = newCameraIndex;
        });

        _initializeControllerFuture = _controller.initialize().then((_) {
          if (mounted) {
            setState(() {});
          }
        }).catchError((error) {
          print('Error initializing camera: $error');
        });
      }).catchError((error) {
        print('Error disposing old controller: $error');
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    double baseWidth = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;
    double fem = MediaQuery
        .of(context)
        .size
        .width / baseWidth;
    double ffem = fem * 0.97;
    double statusBarHeight = MediaQuery
        .of(context)
        .padding
        .top;
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              final size = MediaQuery
                  .of(context)
                  .size;
              final deviceRatio = size.width / (size.height - 58);
              if (snapshot.connectionState == ConnectionState.done) {
                return Transform.scale(
                    scale: 1.6,
                    child: Center(
                    child: AspectRatio(
                    aspectRatio: 4/6,
                    child: OverflowBox(
                    alignment: Alignment.center,
                    child: CameraPreview(_controller),
              ),
              ),
              ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(1),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.1),
                  ],
                  stops: [0.09, 0.21, 0.25]
              ),
            ),
            child: Container(
              margin: EdgeInsets.fromLTRB(0, statusBarHeight + 7 * fem, 0, 0),
              color: Colors.transparent,
              // Замените на цвет вашего фона
              height: 60.0,
              // Замените на необходимую высоту
              alignment: Alignment.topCenter,
              child: const Text(
                'EmojiUI',
                style: TextStyle(
                  fontSize: 45.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'YandexFont', // Замените 'YandexFont' на ваш шрифт
                  // decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
      isStreaming
          ? FloatingActionButton(
        onPressed: _stopStreaming,
        backgroundColor: Colors.black,
        child: const Icon(Icons.stop, color: Colors.white),
      )
          : FloatingActionButton(
        onPressed: _startStreaming,
        backgroundColor: Colors.black,
        child: const Icon(Icons.camera, color: Colors.white),
      ),
        SizedBox(height: 20), // Provide some spacing between the buttons
        FloatingActionButton(
          heroTag: 'switchCameraBtn',
          backgroundColor: Colors.black,
          onPressed: _onSwitchCamera,
          child: Icon(Icons.switch_camera, color: Colors.white),
        ),
      ]
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
