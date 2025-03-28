import 'dart:async';
import 'dart:developer' as dev;
import 'dart:isolate';
import 'package:dart_periphery/dart_periphery.dart';

enum Button { a, b, x, y, up, down }

class ButtonMap {
  final Map<Button, bool> _states = {
    for (var b in Button.values) b: false,
  };

  void setAll(ButtonMap other) {
    for (var b in Button.values) {
      this[b] = other[b];
    }
  }

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
  List<bool> _ledStatus = [false, false, false, false];

  final ButtonMap buttonMap = ButtonMap();
  final StreamController<ButtonMap> _buttonInputStream =
      StreamController.broadcast();
  Stream<ButtonMap> get buttonEvents => _buttonInputStream.stream;

  MegaIndController._internal() {
    if (_isRunning) return;
    _isRunning = true;
    _receive = ReceivePort();
    Isolate.spawn(_megaIndIsolate, _receive.sendPort).then((isolate) {
      _isolate = isolate;
      _receive.listen((message) {
        if (message is SendPort) {
          _send = message;
        } else if (message is ButtonMap) {
          buttonMap.setAll(message);
          _buttonInputStream.add(message);
        } else if (message is Map<String, List<bool>> &&
            message['ledStatus'] != null) {
          _ledStatus = message['ledStatus'] as List<bool>;
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

    final I2C i2c = I2C(1);

    const int deviceAddress = 0x50;
    const int digitalInputRegister = 0x03;
    const int analogInputRegister1 = 0x1C;
    const int analogInputRegister2 = 0x1E;
    const int pwmFanOutputRegister = 0x14;
    const List<int> pwmLedOutputRegister = [0x16, 0x18];

    const double ainLowerLimit = 0.4;
    const double ainUpperLimit = 0.6;
    const double maxAnalogValue = 255.0;

    const Duration inputPollingInterval = Duration(milliseconds: 50);

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
            i2c.writeByteReg(deviceAddress, register, brightness);
            sendPort
                .send({"out": "LED $ledIndex Brightness Set to: $brightness"});
            return;

          case 'startFlashing':
            int ledIndex = msg['led'];
            int brightness = msg['lvl'];
            if (brightness < 0 || brightness > 100) break;

            Duration interval = Duration(seconds: msg['int']);
            bool isOn = false;

            ledFlashing[ledIndex] = true;

            while (ledFlashing[ledIndex]) {
              isOn = !isOn;
              int register = pwmLedOutputRegister[msg['led']];

              i2c.writeByteReg(deviceAddress, register, isOn ? brightness : 0);
              sendPort.send(
                  {"out": "LED $ledIndex Brightness Set to: $brightness"});
              await Future.delayed(interval);
            }

            return;

          case 'stopFlashing':
            ledFlashing[msg['led']] = false;
            return;

          case 'setFanSpeed':
            int speed = msg['lvl'];
            if (speed < 0 || speed > 100) break;

            i2c.writeByteReg(deviceAddress, pwmFanOutputRegister, speed);
            sendPort.send({"out": "Fan Speed Set to: $speed"});
            return;
        }
      }
    });

    while (shouldRun) {
      try {
        // opto digital inputs
        digitalState =
            ~i2c.readByteReg(deviceAddress, digitalInputRegister) & 0x0F;
        buttonMap
          ..[Button.a] = (digitalState >> 0) & 1 == 1
          ..[Button.b] = (digitalState >> 1) & 1 == 1
          ..[Button.x] = (digitalState >> 2) & 1 == 1
          ..[Button.y] = (digitalState >> 3) & 1 == 1;

        // Raw normalized analog value, 0.0-1.0 (0.5 ~ 5V)
        ain1 = i2c.readWordReg(deviceAddress, analogInputRegister1) /
            maxAnalogValue;
        ain2 = i2c.readWordReg(deviceAddress, analogInputRegister2) /
            maxAnalogValue;

        // Read analog inputs (detect button presses at ~5V(~128.0) threshold)
        buttonMap
          ..[Button.up] = (ain1 > ainLowerLimit && ain1 < ainUpperLimit)
          ..[Button.down] = (ain2 > ainLowerLimit && ain2 < ainUpperLimit);

        sendPort.send(buttonMap);
        sendPort.send({'ledStatus': ledFlashing});
      } catch (e) {
        sendPort.send({'error': e.toString()});
      }
      await Future.delayed(inputPollingInterval);
    }
    i2c.dispose();
  }

  void startFlashingButton(int led, {int brightness = 40, int interval = 1}) {
    _send.send({
      'cmd': 'startFlashing',
      'led': led,
      'lvl': brightness,
      'int': interval,
    });
  }

  void stopFlashingButton(int led) {
    _send.send({
      'cmd': 'stopFlashing',
      'led': led,
    });
  }

  void toggleFlashingButton(int led, {int brightness = 40, int interval = 1}) {
    if (_ledStatus[led]) {
      stopFlashingButton(led);
    } else {
      startFlashingButton(
        led,
        brightness: brightness,
        interval: interval,
      );
    }
  }

  void lightButton(int led, {int brightness = 40}) {
    _send.send({
      'cmd': 'lightButton',
      'led': led,
      'lvl': brightness,
    });
  }

  void setFanSpeed(int speed) {
    _send.send({
      'cmd': 'setFanSpeed',
      'lvl': speed,
    });
  }

  void dispose() {
    if (_isRunning) {
      _isRunning = false;
      _isolate.kill(priority: Isolate.immediate);
      _receive.close();
    }
  }
}
