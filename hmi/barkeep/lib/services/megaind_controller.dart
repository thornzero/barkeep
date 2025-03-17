import 'dart:async';
import 'dart:developer' as dev;
import 'dart:isolate';
import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter/services.dart';

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
  late ReceivePort _receivePort;
  bool _isRunning = false;

  final StreamController<ButtonMap> _inputStreamController =
      StreamController.broadcast();
  Stream<ButtonMap> get inputStream => _inputStreamController.stream;

  MegaIndController._internal();

  static const int i2cBus = 1;
  static const int deviceAddress = 0x50;
  static const int digitalInputRegister = 0x03;
  static const int analogInputRegister1 = 0x10;
  static const int analogInputRegister2 = 0x11;
  static const int pwmFanOutputRegister = 0x20;
  static const int pwmLedOutputRegister1 = 0x21;
  static const int pwmLedOutputRegister2 = 0x22;
  static const double ainLowerLimit = 114.75;
  static const double ainUpperLimit = 140.25;

  void startMonitoring() {
    if (_isRunning) return;
    _isRunning = true;
    _receivePort = ReceivePort();
    Isolate.spawn(_checkInputs, _receivePort.sendPort).then((isolate) {
      _isolate = isolate;
      _receivePort.listen((message) {
        if (message is ButtonMap) {
          _inputStreamController.add(message);
        }
      });
    });
  }

  void stopMonitoring() {
    if (_isRunning) {
      _isRunning = false;
      _isolate.kill(priority: Isolate.immediate);
      _receivePort.close();
    }
  }

  void _checkInputs(SendPort sendPort) {
    final i2c = I2C(i2cBus);
    int digitalState = 0x00;
    int prevDigital = 0x00;
    int analogState = 0x00;
    int previousState = 0x00;
    ButtonMap buttonMap = ButtonMap();
    while (true) {
      try {
        // opto digital inputs
        digitalState =
            ~i2c.readByteReg(deviceAddress, digitalInputRegister) & 0x0F;
        if (digitalState != (prevDigital & 0x0F)) {
          buttonMap
            ..buttonA = (digitalState >> 0) & 1 == 1
            ..buttonB = (digitalState >> 1) & 1 == 1
            ..buttonX = (digitalState >> 2) & 1 == 1
            ..buttonY = (digitalState >> 3) & 1 == 1;
        }
        prevDigital = digitalState;

        // analog 0-10v inputs
        double ain1Val =
            i2c.readWordReg(deviceAddress, analogInputRegister1) as double;
        double ain2Val =
            i2c.readWordReg(deviceAddress, analogInputRegister2) as double;

        analogState = (ain1Val > ainLowerLimit && ain1Val < ainUpperLimit)
            ? analogState & 0xF0
            : analogState & 0x00;

        analogState = (ain2Val > ainLowerLimit && ain2Val < ainUpperLimit)
            ? analogState & 0xF0
            : analogState & 0x00;

        if (analogState != (previousState & 0xF0)) {
          // Read analog inputs (detect button presses at ~5V(~128.0) threshold)
        }
        previousState = digitalState;
      } catch (e) {
        dev.log("I2C Read Error: $e");
      }
    }
  }

  void _sendKeyPress(VirtualKey key, bool isPressed) {
    Duration timeStamp = DateTime.now() as Duration;
    KeyEvent event = isPressed
        ? KeyDownEvent(
            physicalKey: key.physicalKey,
            logicalKey: key.logicalKey,
            timeStamp: timeStamp)
        : KeyUpEvent(
            physicalKey: key.physicalKey,
            logicalKey: key.logicalKey,
            timeStamp: timeStamp);

    ServicesBinding.instance.keyboard
        .addHandler((event) => true); // Ensure event gets handled
    dev.log(
        "Key ${key.physicalKey.debugName}:${key.logicalKey.debugName} ${isPressed ? 'Pressed' : 'Released'}");
  }

  void setPWMFanSpeed(int speed) {
    if (speed < 0 || speed > 255) return;
    i2c.writeByteReg(deviceAddress, pwmFanOutputRegister, speed);
    dev.log("Fan Speed Set to: $speed");
  }

  void setPWMLED(int ledIndex, int brightness) {
    if (brightness < 0 || brightness > 255) return;

    int register =
        (ledIndex == 1) ? pwmLedOutputRegister1 : pwmLedOutputRegister2;
    i2c.writeByteReg(deviceAddress, register, brightness);
    dev.log("LED $ledIndex Brightness Set to: $brightness");
  }
}
