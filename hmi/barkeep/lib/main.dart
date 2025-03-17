import 'dart:io';
import 'dart:ui';
//import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:window_manager/window_manager.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'dart:async';

import 'screens/screens.dart';
import 'common/common.dart';
import 'services/audio_manager.dart';

const double screenHeight = 768.0;
const double screenWidth = 1024.0;
const double navWidth = 200.0;
const double navIconSize = 32.0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
      size: Size(screenWidth, screenHeight),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: "Barkeep",
      titleBarStyle: TitleBarStyle.hidden);

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setFullScreen(true); // Makes the app fullscreen
    // await windowManager.setAlwaysOnTop(true); // Ensures the app stays on top
    await windowManager.focus();
  });

  JustAudioMediaKit.ensureInitialized(
    linux: true,
    windows: false,
    android: false,
    iOS: false,
    macOS: false,
  );
  final audioManager = AudioManager();
  audioManager.setVolume(normalVolumeLevel);
  audioManager.setSfxVolume(normalSfxLevel);
  runApp(BarkeepApp());
} // main

class BarkeepApp extends StatelessWidget {
  const BarkeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        title: 'Barkeep',
        theme: barkeepTheme,
        home: BarkeepUI(),
      ),
    );
  }
}

class ScreenDestination {
  const ScreenDestination(
      this.title, this.icon, this.selectedIcon, this.page, this.bgImage);

  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
  final String bgImage;
}

List<ScreenDestination> destinations = <ScreenDestination>[
  ScreenDestination(
    'Home',
    Icons.home,
    Icons.home,
    HomePage(),
    homeBackground,
  ),
  ScreenDestination(
    'Food & Drink',
    Icons.fastfood,
    Icons.fastfood,
    FoodAndDrinkPage(),
    foodanddrinkBackground,
  ),
  ScreenDestination(
    'Atmosphere',
    Icons.forest,
    Icons.forest,
    AtmospherePage(),
    atmosphereBackground,
  ),
  ScreenDestination(
    'Entertainment',
    Icons.speaker_group_rounded,
    Icons.speaker_group_rounded,
    EntertainmentPage(),
    entertainmentBackground,
  ),
  ScreenDestination(
    'Settings',
    Icons.settings,
    Icons.settings,
    SettingsPage(),
    settingsBackground,
  ),
];

class BarkeepUI extends ConsumerStatefulWidget {
  @override
  ConsumerState<BarkeepUI> createState() => _BarkeepUIState();
}

class _BarkeepUIState extends ConsumerState<BarkeepUI>
    with TickerProviderStateMixin {
  var selectedIndex = 0;
  var audioManager = AudioManager();
  Widget page = HomePage();
  String bgImage = homeBackground;
  bool _hideCursor = false;

  void _onTouchInput(PointerEvent event) {
    return;
  }

  void _onRawMouseInput(PointerEvent event) {
    return;
  }

  void updatePage(int index) {
    audioManager.sfx(sfxNavBarSelectChange);
    setState(() {
      selectedIndex = index;
      page = destinations[selectedIndex].page;
      bgImage = destinations[selectedIndex].bgImage;
    });
  }

  Widget navBar() {
    return NavigationRail(
      minWidth: navWidth,
      groupAlignment: 1.0,
      useIndicator: true,
      labelType: NavigationRailLabelType.all,
      leading: Container(
        decoration: BoxDecoration(
          border: InkCrimson.border,
        ),
        child: Image.asset(
          mewlingGoatTavernLogo,
          width: navWidth,
        ),
      ),
      destinations: destinations.map(
        (d) {
          return NavigationRailDestination(
            icon: Icon(d.icon, size: navIconSize),
            selectedIcon: Icon(d.selectedIcon, size: navIconSize),
            label: Text(d.title),
          );
        },
      ).toList(),
      selectedIndex: selectedIndex,
      onDestinationSelected: updatePage,
    );
  }

  /// keyboard variables
  late FocusNode focusNode;

  Future<void> onKeyEvent(KeyEvent event) async {
    if (event is KeyDownEvent) {
      switch (event.physicalKey) {
        case PhysicalKeyboardKey.escape:
          setState(() {
            exit(0);
          });
        case PhysicalKeyboardKey.pageDown:
          updatePage((selectedIndex + 1) % 5);
        case PhysicalKeyboardKey.pageUp:
          updatePage((selectedIndex - 1) % 5);
        case PhysicalKeyboardKey.home:
          await windowManager.minimize();
        case PhysicalKeyboardKey.f4:
          setState(() {
            _hideCursor = !_hideCursor;
          });
        default:
          DoNothingAction(consumesKey: false);
      }
    }
  }

  ///============================================================================
  /// Build
  ///============================================================================
  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScanlineShader(
      child: MouseRegion(
        onEnter: _onRawMouseInput,
        onHover: _onRawMouseInput,
        onExit: _onRawMouseInput,
        cursor:
            _hideCursor ? SystemMouseCursors.none : SystemMouseCursors.basic,
        child: Listener(
          onPointerDown: _onTouchInput,
          onPointerMove: _onRawMouseInput,
          child: KeyboardListener(
            focusNode: focusNode,
            onKeyEvent: onKeyEvent,
            child: Scaffold(
              body: Stack(
                children: <Widget>[
                  OverflowBox(
                    minWidth: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      bgImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Row(children: <Widget>[
                    SafeArea(
                      child: Container(
                          decoration: BoxDecoration(
                            border: InkCrimson.border,
                          ),
                          child: navBar()),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: InkCrimson.border,
                        ),
                        child: page,
                      ),
                    ),
                  ]),
                ],
              ),
              drawer: Drawer(),
            ),
          ),
        ),
      ),
    );
  }
}

class ScanlineShader extends StatelessWidget {
  ScanlineShader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder((context, shader, child) {
      shader.setFloatUniforms((uniforms) {
        uniforms.setSize(MediaQuery.of(context).size);
      });
      return AnimatedSampler((image, size, canvas) {
        shader.setImageSampler(0, image);
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..shader = shader,
        );
      }, child: child!);
    }, assetKey: crtShader, child: child);
  }
}
