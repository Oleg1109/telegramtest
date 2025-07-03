import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://flutter.dev'));
  Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  final UniqueKey _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
              child: ElevatedButton(
                  onPressed: () {
                    sheetController.animateTo(
                      0.5,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text('Open'))),
          DraggableScrollableSheet(
            controller: sheetController,
            initialChildSize: 0.0,
            minChildSize: 0.0,
            maxChildSize: 1.0,
            snap: true,
            snapSizes: [0.08, 0.5, 1],
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: RawGestureDetector(
                  gestures: {
                      VerticalDragGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                              VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer(),
                        (VerticalDragGestureRecognizer instance) {
                          instance.onUpdate = (details) {
                            print(
                                "Flutter ловить свайп: ${details.primaryDelta}");
                            setState(() {
                              gestureRecognizers = {
                                Factory(() => VerticalDragGestureRecognizer())
                              };
                            });
                          };
                        },
                      ),
                    },
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        color: Colors.green,
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              color: Colors.green,
                            ),
                            Expanded(
                              child: WebViewWidget(
                                  key: _key,
                                  gestureRecognizers: gestureRecognizers,
                                  controller: webViewController),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
