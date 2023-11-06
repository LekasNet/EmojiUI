import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

OverlayEntry? overlayEntry;

void showNotification(BuildContext context, String title, String message, Color color, Color textColor, Function func) {
  double statusBarHeight = MediaQuery.of(context).padding.top;
  double baseWidth = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  double fem = MediaQuery.of(context).size.width / baseWidth;
  double ffem = fem * 0.97;

  if (overlayEntry != null) {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  overlayEntry = OverlayEntry(
    builder: (context) => Material(
        color: Colors.transparent,
        child: _Notification(
          title: title,
          message: message,
          color: color,
          textColor: textColor,
        ),
      ),
  );

  Overlay.of(context).insert(overlayEntry!);

  // Удаляем уведомление через 6 секунд
  if (overlayEntry != null) {
    Future.delayed(Duration(seconds: 10), () {
      func();
      removeNotification();
    });
  }
}

void removeNotification() {
  if (overlayEntry != null) {
    overlayEntry?.remove();
    overlayEntry = null;
  }
}

class _Notification extends StatefulWidget {
  final String title;
  final String message;
  final Color color;
  final Color textColor;

  const _Notification({
    Key? key,
    required this.title,
    required this.message,
    required this.color,
    required this.textColor,
  }) : super(key: key);

  @override
  __NotificationState createState() => __NotificationState();
}

class __NotificationState extends State<_Notification> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    double baseWidth = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    EdgeInsets containerMargin = _isExpanded ? EdgeInsets.only(left: 10, right: 10, bottom: 10) : EdgeInsets.only(left: 10, right: 10, bottom: 145);
    return Stack(
        alignment: Alignment.bottomCenter,
        children: [
      Align(
      // top: _isExpanded ? statusBarHeight + 7*fem + 60 + 10 : height - 100 - 60 - statusBarHeight,
      // left: 10,
      // right: 10,
        alignment: Alignment.bottomCenter,
      child: GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: _isExpanded ? null : 100,
        width: baseWidth - 20,
        margin: containerMargin,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - statusBarHeight - 7*fem - 60 - 20,
        ),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: AnimatedCrossFade(
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AutoSizeText(
                  widget.title,
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.bold, color: widget.textColor),
                ),
                SizedBox(height: 5),
                AutoSizeText(
                  widget.message,
                  maxLines: 2,
                  style: TextStyle(color: widget.textColor),
                ),
              ],
            ),
            secondChild: SingleChildScrollView(
              child: AutoSizeText(
                widget.message,
                style: TextStyle(color: widget.textColor),
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 250),
          ),
        ),
      ),
      ),
      )
      ]
    );
  }
}