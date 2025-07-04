import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:telegramtest/utils/constants.dart';
import 'package:telegramtest/utils/helpers.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ModalPage extends StatefulWidget {
  const ModalPage({super.key});

  @override
  State<ModalPage> createState() => _ModalPageState();
}

class _ModalPageState extends State<ModalPage> {
  final sheetController = DraggableScrollableController();
  final WebViewController webViewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse('https://flutter.dev'));
  Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };
  final urlController = TextEditingController(text: 'flutter.dev');
  String lastURL = 'https://flutter.dev';
  bool showClearButton = false;

  @override
  void dispose() {
    sheetController.dispose();
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topBarHeight = 50;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Center(
                child: ElevatedButton(
                    onPressed: () => sheetAnimateTo(
                        sheetController, Constants.modalSizeHalf),
                    child: Text(
                      'Відкрити вікно',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Constants.buttonTextColor),
                    ))),
            DraggableScrollableSheet(
              controller: sheetController,
              minChildSize: Constants.modalSizeMin,
              maxChildSize: Constants.modalSizeFull,
              initialChildSize: Constants.modalSizeInitial,
              snap: true,
              snapSizes: [
                Constants.modalSizeClosed,
                Constants.modalSizeHalf,
                Constants.modalSizeFull
              ],
              builder: (context, scrollController) {
                return PopScope(
                  canPop: Platform.isAndroid ? false : true,
                  onPopInvokedWithResult: (_, __) {
                    webViewController.goBack();
                  },
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 0),
                            blurRadius: 8,
                            spreadRadius: 2,
                            color: Colors.black.withValues(alpha: 0.1))
                      ],
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                      color: Constants.barsBackgroundColor,
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: ClampingScrollPhysics(),
                      child: SizedBox(
                        height:
                            MediaQuery.of(context).size.height - topBarHeight,
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              TopBar(
                                height: topBarHeight,
                                sheetController: sheetController,
                                urlController: urlController,
                                outlineInputBorder:
                                    Constants.outlineInputBorder,
                                showClearButton: showClearButton,
                                buttonTextColor: Constants.buttonTextColor,
                                onTapTextField: () => setState(() {
                                  showClearButton = true;
                                }),
                                onSubmitted: loadUrl,
                                onTapClear: () => urlController.clear(),
                                onTapRefresh: () => webViewController.reload(),
                              ),
                              Expanded(
                                child: WebViewWidget(
                                    gestureRecognizers: gestureRecognizers,
                                    controller: webViewController),
                              ),
                              NavigationBar(
                                  bottomPadding: bottomPadding,
                                  webViewController: webViewController),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void loadUrl(url) async {
    if (url.isNotEmpty) {
      await webViewController.loadRequest(Uri.parse(normalizeUrl(url)));
      urlController.text = removeHttp(url);
      lastURL = urlController.text;
    } else {
      urlController.text = removeHttp(lastURL);
    }
    setState(() {
      showClearButton = false;
    });
  }
}

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.height,
    required this.sheetController,
    required this.urlController,
    required this.outlineInputBorder,
    required this.showClearButton,
    required this.buttonTextColor,
    required this.onTapTextField,
    required this.onSubmitted,
    required this.onTapClear,
    required this.onTapRefresh,
  });

  final double height;
  final DraggableScrollableController sheetController;
  final TextEditingController urlController;
  final OutlineInputBorder outlineInputBorder;
  final bool showClearButton;
  final Color? buttonTextColor;
  final Function() onTapTextField;
  final ValueChanged<String> onSubmitted;
  final Function() onTapClear;
  final Function() onTapRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.fromLTRB(16, 7, 16, 7),
      color: Constants.barsBackgroundColor,
      child: Row(
        spacing: 15,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ModalButton(
            sheetController: sheetController,
          ),
          Expanded(
              child: TextFormField(
            controller: urlController,
            autocorrect: false,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onTap: onTapTextField,
            onFieldSubmitted: onSubmitted,
            textAlign: TextAlign.center,
            cursorHeight: 16,
            decoration: InputDecoration(
              filled: true,
              fillColor: Constants.textFormColor,
              contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
              hintText: 'Введіть URL',
              enabledBorder: outlineInputBorder,
              focusedBorder: outlineInputBorder,
              suffixIconConstraints:
                  BoxConstraints(minWidth: showClearButton ? 40 : 0),
              suffixIcon: Visibility(
                visible: showClearButton,
                child: InkWell(
                  onTap: onTapClear,
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          )),
          InkWell(
            onTap: onTapRefresh,
            child: Icon(
              Icons.refresh,
              color: buttonTextColor,
            ),
          )
        ],
      ),
    );
  }
}

class NavigationBar extends StatelessWidget {
  const NavigationBar({
    super.key,
    required this.bottomPadding,
    required this.webViewController,
  });

  final double bottomPadding;
  final WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: EdgeInsets.fromLTRB(16, 7, 16, 0),
      margin: EdgeInsets.only(bottom: bottomPadding),
      color: Constants.barsBackgroundColor,
      alignment: Alignment.topCenter,
      child: Row(
        spacing: 40,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              webViewController.goBack();
            },
            child: Icon(
              Icons.navigate_before,
              size: 40,
              color: Constants.buttonTextColor,
            ),
          ),
          InkWell(
            onTap: () {
              webViewController.goForward();
            },
            child: Icon(
              Icons.navigate_next,
              size: 40,
              color: Constants.buttonTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ModalButton extends StatefulWidget {
  const ModalButton({
    super.key,
    required this.sheetController,
  });

  final DraggableScrollableController sheetController;

  @override
  State<ModalButton> createState() => _ModalButtonState();
}

class _ModalButtonState extends State<ModalButton> {
  String buttonLabel = 'Згорнути';
  bool toClose = false;

  @override
  void initState() {
    super.initState();
    widget.sheetController.addListener(sheetSizeListener);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        sheetAnimateTo(widget.sheetController,
            toClose ? Constants.modalSizeMin : Constants.modalSizeClosed);
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Text(
        buttonLabel,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Constants.buttonTextColor),
      ),
    );
  }

  void sheetSizeListener() {
    String newLabel;
    double size = widget.sheetController.size;

    if ((size - Constants.modalSizeClosed).abs() < 0.05) {
      newLabel = 'Закрити';
      toClose = true;
    } else {
      newLabel = 'Згорнути';
      toClose = false;
    }
    if (newLabel != buttonLabel) {
      setState(() {
        buttonLabel = newLabel;
      });
    }
  }
}

void sheetAnimateTo(
    DraggableScrollableController sheetController, double size) {
  sheetController.animateTo(
    size,
    duration: Duration(milliseconds: 200),
    curve: Curves.easeInOut,
  );
}
