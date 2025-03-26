import 'dart:async';
import 'dart:developer' as dev;
import 'dart:isolate';
import 'package:dart_periphery/dart_periphery.dart';

enum Button { a, b, x, y, up, down }

class ButtonMap {
  final Map<Button, bool> _states = {
    for (var b in Button.values) b: false,
  };

  bool operator [](Button b) => _states[b]!;
  void operator []=(Button b, bool val) => _states[b] = val;

  @override
  String toString() => _states.toString();
}

class MegaIndController {
  static final MegaIndController _instance = MegaIndController._internal();
  factory MegaIndController() => _instance;

  late Isolate _isolate;
  late ReceivePort _receive;
  late SendPort _send;

  bool _isRunning = false;

  final StreamController<ButtonMap> _input = StreamController.broadcast();
  Stream<ButtonMap> get inputStream => _input.stream;

  MegaIndController._internal();

  static late final I2C _i2c;

  static const int deviceAddress = 0x50;
  static const int digitalInputRegister = 0x03;
  static const int analogInputRegister1 = 0x1C;
  static const int analogInputRegister2 = 0x1E;
  static const int pwmFanOutputRegister = 0x14;
  static const List<int> pwmLedOutputRegister = [0x16, 0x18];

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
          _send = message;
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

    List<bool> ledFlashing = [false, false, false, false];
    int digitalState = 0;
    double ain1, ain2 = 0.0;
    ButtonMap buttonMap = ButtonMap();
    bool shouldRun = true;

    recvPort.listen((msg) async {
      if (msg == 'stop') {
        shouldRun = false;
      } else if (msg is Map<String, dynamic>) {
        switch (msg['cmd']) {
          case 'lightButton':
            int ledIndex = msg['led'];
            int brightness = msg['lvl'];
            if (brightness < 0 || brightness > 100) break;
            int register = pwmLedOutputRegister[msg['led']];
            _i2c.writeByteReg(deviceAddress, register, brightness);
            sendPort
                .send({"out", "LED $ledIndex Brightness Set to: $brightness"});

          case 'StartFlashing':
            int ledIndex = msg['led'];
            int brightness = msg['lvl'];
            if (brightness < 0 || brightness > 100) break;
            Duration interval = Duration(seconds: msg['int']);
            int prevBrightness = 0;
            while (ledFlashing[ledIndex]) {
              prevBrightness = prevBrightness > 0 ? brightness : 0;
              int register = pwmLedOutputRegister[msg['led']];
              _i2c.writeByteReg(deviceAddress, register, brightness);
              sendPort.send(
                  {"out", "LED $ledIndex Brightness Set to: $brightness"});
              await Future.delayed(interval);
            }

          case 'StopFlashing':
            ledFlashing[msg['led']] = false;

          case 'setFanSpeed':
            int speed = msg['lvl'];
            if (speed < 0 || speed > 100) break;
            _i2c.writeByteReg(deviceAddress, pwmFanOutputRegister, speed);
            sendPort.send({"out", "Fan Speed Set to: $speed"});
        }
      }
    });

    while (shouldRun) {
      try {
        // opto digital inputs
        digitalState =
            ~_i2c.readByteReg(deviceAddress, digitalInputRegister) & 0x0F;
        buttonMap
          ..[Button.a] = (digitalState >> 0) & 1 == 1
          ..[Button.b] = (digitalState >> 1) & 1 == 1
          ..[Button.x] = (digitalState >> 2) & 1 == 1
          ..[Button.y] = (digitalState >> 3) & 1 == 1;

        // analog 0-10v inputs
        ain1 = _i2c.readWordReg(deviceAddress, analogInputRegister1) / 1.0;
        ain2 = _i2c.readWordReg(deviceAddress, analogInputRegister2) / 1.0;

        // Read analog inputs (detect button presses at ~5V(~128.0) threshold)
        buttonMap
          ..[Button.up] = (ain1 > ainLowerLimit && ain1 < ainUpperLimit)
          ..[Button.down] = (ain2 > ainLowerLimit && ain2 < ainUpperLimit);

        sendPort.send(buttonMap);
      } catch (e) {
        sendPort.send({'error': e.toString()});
      }
      await Future.delayed(Duration(milliseconds: 50));
    }
  }

  void toggleFlashingButton(int led, {int brightness = 40, int interval = 1}) {
    _send.send({
      'cmd': 'flashButton',
      'led': led,
      'lvl': brightness,
      'int': interval,
    });
  }

  void lightButton(int led, {int brightness = 40}) {
    _send.send({'cmd': 'lightButton'});
  }

  void dispose() {
    if (_isRunning) {
      _isRunning = false;
      _isolate.kill(priority: Isolate.immediate);
      _receive.close();
    }
    _i2c.dispose();
  }
}
