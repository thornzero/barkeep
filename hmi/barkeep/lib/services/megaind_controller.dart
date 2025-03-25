import 'dart:async';
import 'dart:developer' as dev;
import 'dart:isolate';
import 'package:dart_periphery/dart_periphery.dart';

class ButtonMap {
  bool buttonA = false;
  bool buttonB = false;
  bool buttonX = false;
  bool buttonY = false;
  bool buttonUp = false;
  bool buttonDown = false;
}

class MegaIndController {
  static final MegaIndController _instance = MegaIndController._internal();
  factory MegaIndController() => _instance;

  late Isolate _isolate;
  late ReceivePort _receive;
  late SendPort _megaindSendPort;

  bool _isRunning = false;

  final StreamController<ButtonMap> _input = StreamController.broadcast();
  Stream<ButtonMap> get inputStream => _input.stream;

  MegaIndController._internal();

  static late final I2C _i2c;
  static List<bool> _ledFlashing = [false, false, false, false];

  static const int i2cBus = 1;
  static const int deviceAddress = 0x50;
  static const int digitalInputRegister = 0x03;
  static const int analogInputRegister1 = 0x1C;
  static const int analogInputRegister2 = 0x1E;
  static const int pwmFanOutputRegister = 0x14;
  static const int pwmLedOutputRegister1 = 0x16;
  static const int pwmLedOutputRegister2 = 0x18;

  static const double ainLowerLimit = 114.75;
  static const double ainUpperLimit = 140.25;

  static const Duration inputPollingInterval = Duration(milliseconds: 50);

  void init({int i2cBus = 1}) {
    _i2c = I2C(i2cBus);
    if (_isRunning) return;
    _isRunning = true;
    _receive = ReceivePort();
    Isolate.spawn(_megaIndIsolate, _receive.sendPort).then((isolate) {
      _isolate = isolate;
      _receive.listen((message) {
        if (message is SendPort) {
          _megaindSendPort = message;
        } else if (message is ButtonMap) {
          _input.add(message);
        } else if (message is Map<String, dynamic> &&
            message['error'] != null) {
          dev.log("I2C Error: ${message['error']}");
        }
      });
    });
  }

  Future<void> _megaIndIsolate(SendPort sendPort) async {
    final ReceivePort recvPort = ReceivePort();
    sendPort.send(recvPort.sendPort);

    int digitalState = 0;
    double ain1, ain2 = 0.0;
    ButtonMap buttonMap = ButtonMap();
    bool shouldRun = true;

    recvPort.listen((msg) {
      if (msg == 'stop') {
        shouldRun = false;
      } else if (msg is Map<String, dynamic>) {
        switch (msg['cmd']) {
          case 'lightButton':
            setPWMLED(msg['led'], msg['lvl']);

          case 'flashButton':
            _flashButton(
              msg['led'],
              brightness: msg['lvl'],
              interval: Duration(seconds: msg['int']),
            );

          case 'setFanSpeed':
            setPWMFanSpeed(msg['lvl']);
        }
      }
    });

    while (shouldRun) {
      try {
        // opto digital inputs
        digitalState =
            ~_i2c.readByteReg(deviceAddress, digitalInputRegister) & 0x0F;
        buttonMap
          ..buttonA = (digitalState >> 0) & 1 == 1
          ..buttonB = (digitalState >> 1) & 1 == 1
          ..buttonX = (digitalState >> 2) & 1 == 1
          ..buttonY = (digitalState >> 3) & 1 == 1;

        // analog 0-10v inputs
        ain1 = _i2c.readWordReg(deviceAddress, analogInputRegister1) as double;
        ain2 = _i2c.readWordReg(deviceAddress, analogInputRegister2) as double;

        // Read analog inputs (detect button presses at ~5V(~128.0) threshold)
        buttonMap
          ..buttonUp = (ain1 > ainLowerLimit && ain1 < ainUpperLimit)
          ..buttonDown = (ain2 > ainLowerLimit && ain2 < ainUpperLimit);

        sendPort.send(buttonMap);
      } catch (e) {
        sendPort.send({'error': e.toString()});
      }
      await Future.delayed(Duration(milliseconds: 50));
    }
  }

  void dispose() {
    if (_isRunning) {
      _isRunning = false;
      _isolate.kill(priority: Isolate.immediate);
      _receive.close();
    }
    _i2c.dispose();
  }

  static void setPWMFanSpeed(int speed) {
    if (speed < 0 || speed > 100) return;
    _i2c.writeByteReg(deviceAddress, pwmFanOutputRegister, speed);
    dev.log("Fan Speed Set to: $speed");
  }

  static void setPWMLED(int ledIndex, int brightness) {
    if (brightness < 0 || brightness > 100) return;
    int register =
        (ledIndex == 1) ? pwmLedOutputRegister1 : pwmLedOutputRegister2;
    _i2c.writeByteReg(deviceAddress, register, brightness);
    dev.log("LED $ledIndex Brightness Set to: $brightness");
  }

  static Future<void> _flashButton(int ledIndex,
      {int brightness = 40,
      Duration interval = const Duration(seconds: 1)}) async {
    int prevBrightness = 0;
    while (_ledFlashing[ledIndex]) {
      prevBrightness = prevBrightness > 0 ? brightness : 0;
      setPWMLED(ledIndex, prevBrightness);
      await Future.delayed(interval);
    }
  }
}
