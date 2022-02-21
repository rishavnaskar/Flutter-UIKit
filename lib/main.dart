import 'package:agora_uikit/agora_uikit.dart';
import 'package:custom_background_flutter/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late AgoraClient _client;
  late RtcEngine _engine;
  final ImagePicker _picker = ImagePicker();
  late bool _virtualBackgroundToggle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(title),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            AgoraVideoViewer(client: _client),
            AgoraVideoButtons(client: _client, extraButtons: [galleryButton]),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  @override
  void dispose() {
    super.dispose();
    _client.sessionController.endCall();
  }

  void initAgora() async {
    _client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: appID,
        channelName: channel,
      ),
      enabledPermission: [
        Permission.camera,
        Permission.microphone,
      ],
    );
    await _client.initialize();
    _engine = _client.sessionController.value.engine!;
    _virtualBackgroundToggle = false;
  }

  Widget get galleryButton => CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          onPressed: () async {
            if (_virtualBackgroundToggle) {
              _disableVirtualBackground();
            } else {
              /* For VIRTUAL BACKGROUND IMG
              _virtualBackgroundIMG(); */

              /* For VIRTUAL BACKGROUND COLOR
              _virtualBackgroundCOLOR(Colors.pink); */

              /* For VIRTUAL BACKGROUND BLUR */
              _virtualBackgroundBLUR(VirtualBackgroundBlurDegree.Medium);
            }
          },
          icon: const Icon(CupertinoIcons.photo),
          color: Colors.blueAccent,
          enableFeedback: true,
        ),
      );

  _showSnackBar(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(text), duration: const Duration(milliseconds: 500)));

  Future<XFile?> _getImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  void _enableVirtualBackground(VirtualBackgroundSource backgroundSource) {
    _engine.enableVirtualBackground(true, backgroundSource);
    _engine.setEventHandler(RtcEngineEventHandler(
      virtualBackgroundSourceEnabled: ((enabled, reason) {
        debugPrint(
            "Virtual Background - ${backgroundSource.backgroundSourceType}");
        debugPrint(enabled.toString());
        debugPrint(reason.toString());
        _virtualBackgroundToggle = !_virtualBackgroundToggle;
      }),
    ));
    _showSnackBar("Enabled Virtual Background");
  }

  void _disableVirtualBackground() {
    _engine.enableVirtualBackground(false, VirtualBackgroundSource());
    _showSnackBar("Disabled Virtual Background");
  }

  void _virtualBackgroundCOLOR(Color? color) {
    final backgroundSource = VirtualBackgroundSource();
    backgroundSource.backgroundSourceType = VirtualBackgroundSourceType.Color;
    backgroundSource.color = color;
    _enableVirtualBackground(backgroundSource);
  }

  Future<void> _virtualBackgroundIMG() async {
    await _getImage().then((XFile? value) {
      if (value == null) {
        debugPrint("FILE NOT FOUND");
      } else {
        final backgroundSource = VirtualBackgroundSource();
        backgroundSource.backgroundSourceType = VirtualBackgroundSourceType.Img;
        backgroundSource.source = value.path;
        _enableVirtualBackground(backgroundSource);
      }
    });
  }

  void _virtualBackgroundBLUR(VirtualBackgroundBlurDegree blurDegree) {
    final backgroundSource = VirtualBackgroundSource();
    backgroundSource.backgroundSourceType = VirtualBackgroundSourceType.Blur;
    backgroundSource.blurDegree = blurDegree;
    _enableVirtualBackground(backgroundSource);
  }
}
