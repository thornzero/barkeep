import 'dart:io';
import 'dart:developer' as dev;
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';

import 'screens/screens.dart';
import 'common/common.dart';

const double screenHeight = 768.0;
const double screenWidth = 1024.0;
const double navWidth = 256.0;
const double navIconSize = 32.0;

void main() async {
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    dev.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace,
    );
    // TODO: if needed, forward to Sentry.io,Crashlytics, etc.
  });
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
    await windowManager.setAlwaysOnTop(true); // Ensures the app stays on top
    await windowManager.focus();
  });

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
  ///
  /// soundeffects audio variables
  final soloud = SoLoud.instance;
  AudioSource? clickSound;
  SoundHandle? soundHandle;

  Future<void> initializeAudioPlayer() async {
    await soloud.init();
    clickSound = await soloud.loadAsset(soundeffectClick);
  }

  Future<void> playSound(AudioSource source) async {
    soundHandle = await soloud.play(source);
  }

  Future<void> disposeSound(AudioSource source) async {
    await soloud.stop(soundHandle!);
    await soloud.disposeSource(source);
  }

  ///==========================================================================
  /// navigation
  ///==========================================================================
  var selectedIndex = 0;
  Widget page = HomePage();
  String bgImage = homeBackground;

  void updatePage(int index) {
    setState(() {
      selectedIndex = index;
      page = destinations[selectedIndex].page;
      bgImage = destinations[selectedIndex].bgImage;
    });
    playSound(clickSound!);
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

  void onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      PhysicalKeyboardKey key = event.physicalKey;
      if (key == PhysicalKeyboardKey.escape) {
        setState(() {
          exit(0);
        });
        //exit(0);
      } else if (key == PhysicalKeyboardKey.pageDown) {
        updatePage((selectedIndex + 1) % 5);
      } else if (key == PhysicalKeyboardKey.pageUp) {
        updatePage((selectedIndex - 1) % 5);
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
    initializeAudioPlayer();
  }

  @override
  void dispose() {
    focusNode.dispose();
    disposeSound(clickSound!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScanlineShader(
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
