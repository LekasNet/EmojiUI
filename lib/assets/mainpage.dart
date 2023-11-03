import 'package:flutter/material.dart';
import 'package:camera/camera.dart';


class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      // Используйте камеру по умолчанию
      CameraDescription(
        name: '0',
        lensDirection: CameraLensDirection.back, sensorOrientation: 1,
      ),
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(

      body: Stack(
        children: [
          FutureBuilder(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final size = MediaQuery.of(context).size;
                final deviceRatio = size.width / size.height;
                final previewRatio = _controller.value.previewSize!.aspectRatio;
                return AspectRatio(aspectRatio: deviceRatio,
                    child: CameraPreview(_controller),
              );
              } else {
                return Center(child: CircularProgressIndicator());
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
                margin: EdgeInsets.fromLTRB(0,statusBarHeight + 7*fem,0,0),
                color: Colors.transparent, // Замените на цвет вашего фона
                height: 60.0, // Замените на необходимую высоту
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
        ]
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            // Получить изображение с камеры
            XFile imageFile = await _controller.takePicture();

            // Отобразить изображение
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => DisplayImageScreen(imagePath: imageFile.path),
            //   ),
            // );
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}

// class DisplayImageScreen extends StatelessWidget {
//   final String imagePath;
//
//   DisplayImageScreen({required this.imagePath});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Image.file(File(imagePath)),
//       ),
//     );
//   }
// }
