import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:dart_periphery/dart_periphery.dart';

/// Default I2C address of the [WS1850S] sensor
const int ws1850sDefaultI2Caddress = 0x28;

/// Chip vendor for the WS1850S
const String chipVendor = 'Wisesun';

/// Chip name for the WS1850S
const String chipName = 'WS1850S';

/// Chip ID for the WS1850S
const int chipIdWS1850S = 0x61;
const int pcdIdle = 0x00;
const int pcdAuthEnt = 0x0E;
const int pcdReceive = 0x08;
const int pcdTransmit = 0x04;
const int pcdTransceive = 0x0C;
const int pcdSoftReset = 0x0F;
const int pcdCalcCrc = 0x03;

// PICC Commands
const int piccReqIdl = 0x26;
const int piccReqAll = 0x52;
const int piccAntiColl = 0x93;
const int piccSelectTag = 0x93;
const int piccAuthent1A = 0x60;
const int piccAuthent1B = 0x61;
const int piccRead = 0x30;
const int piccWrite = 0xA0;
const int piccDecrement = 0xC0;
const int piccIncrement = 0xC1;
const int piccRestore = 0xC2;
const int piccTransfer = 0xB0;
const int piccHalt = 0x50;

// Status
const int miOk = 0;
const int miNoTagErr = 1;
const int miErr = 2;

// Mfrc522 Registers
const int reserved00 = 0x00;
const int commandReg = 0x01;
const int commIEnReg = 0x02;
const int divlEnReg = 0x03;
const int commIrqReg = 0x04;
const int divIrqReg = 0x05;
const int errorReg = 0x06;
const int status1Reg = 0x07;
const int status2Reg = 0x08;
const int fifoDataReg = 0x09;
const int fifoLevelReg = 0x0A;
const int waterLevelReg = 0x0B;
const int controlReg = 0x0C;
const int bitFramingReg = 0x0D;
const int collReg = 0x0E;
const int modeReg = 0x11;
const int txModeReg = 0x12;
const int rxModeReg = 0x13;
const int txControlReg = 0x14;
const int txControlRegMask = 0x03;
const int txAutoReg = 0x15;
const int tModeReg = 0x2A;
const int tPrescalerReg = 0x2B;
const int tReloadRegL = 0x2C;
const int tReloadRegH = 0x2D;
const int cRCResultRegL = 0x22; // CRC calculation result low byte
const int cRCResultRegM = 0x21; // CRC calculation result high byte

class WS1850S {
  static const int maxLen = 16;

  // PCD Commands

  static const int _resetPeriodMs = 10;
  late final I2C i2c;
  late final int i2cAddress;

  WS1850S({
    int bus = 1,
    int device = ws1850sDefaultI2Caddress,
  }) {
    i2c = I2C(bus);
    i2cAddress = device;
    _initialize();
  }

  void _initialize() {
    softReset();
    writeReg(tModeReg, 0x8D);
    writeReg(tPrescalerReg, 0x3E);
    writeReg(tReloadRegL, 30);
    writeReg(tReloadRegH, 0);
    writeReg(txAutoReg, 0x40);
    writeReg(modeReg, 0x3D);
    antennaOn();
  }

  void writeReg(int reg, int val) => i2c.writeByteReg(i2cAddress, reg, val);
  int readReg(int register) => i2c.readByteReg(i2cAddress, register);

  void close() {
    i2c.dispose(); // Changed from close() to dispose()
  }

  void setBitMask(int reg, int mask) {
    var tmp = readReg(reg);
    writeReg(reg, tmp | mask);
  }

  void clearBitMask(int reg, int mask) {
    var tmp = readReg(reg);
    writeReg(reg, tmp & (~mask));
  }

  Future<void> delayMicroseconds(int us) async {
    await Future.delayed(Duration(microseconds: us));
  }

  /// Initiates a soft reset
  void softReset() {
    writeReg(commandReg, pcdSoftReset);
    sleep(Duration(milliseconds: _resetPeriodMs));
  }

  void antennaOn() => setBitMask(txControlReg, txControlRegMask);
  void antennaOff() => clearBitMask(txControlReg, txControlRegMask);

  Future<Map<String, dynamic>> mfrc522ToCard(
      int command, List<int> sendData) async {
    List<int> backData = [];
    int backLen = 0;
    int status = miErr;
    int irqEn = 0x00;
    int waitIRq = 0x00;

    if (command == pcdAuthEnt) {
      irqEn = 0x12;
      waitIRq = 0x10;
    }
    if (command == pcdTransceive) {
      irqEn = 0x77;
      waitIRq = 0x30;
    }

    writeReg(commIEnReg, irqEn | 0x80);
    clearBitMask(commIrqReg, 0x80);
    setBitMask(fifoLevelReg, 0x80);
    writeReg(commandReg, pcdIdle);

    for (var i = 0; i < sendData.length; i++) {
      writeReg(fifoDataReg, sendData[i]);
    }

    writeReg(commandReg, command);
    if (command == pcdTransceive) {
      setBitMask(bitFramingReg, 0x80);
    }

    int i = 2000;
    int n = 0;
    do {
      await delayMicroseconds(350); // Adding delay like in Python version
      n = readReg(commIrqReg);
      i--;
    } while (i != 0 && ((n & 0x01) == 0) && ((n & waitIRq) == 0));

    clearBitMask(bitFramingReg, 0x80);

    if (i != 0) {
      if ((readReg(errorReg) & 0x1B) == 0x00) {
        status = miOk;

        if ((n & irqEn & 0x01) != 0) {
          // Changed to compare with 0
          status = miNoTagErr;
        }

        if (command == pcdTransceive) {
          n = readReg(fifoLevelReg);
          int lastBits = readReg(controlReg) & 0x07;
          if (lastBits != 0) {
            backLen = (n - 1) * 8 + lastBits;
          } else {
            backLen = n * 8;
          }

          if (n == 0) {
            n = 1;
          }
          if (n > maxLen) {
            n = maxLen;
          }

          for (i = 0; i < n; i++) {
            backData.add(readReg(fifoDataReg));
          }
        }
      } else {
        status = miErr;
      }
    }

    return {
      'status': status,
      'backData': backData,
      'backLen': backLen,
    };
  }

  Future<Map<String, dynamic>> request(int reqMode) async {
    writeReg(bitFramingReg, 0x07);
    List<int> tagType = [reqMode];

    var result = await mfrc522ToCard(pcdTransceive, tagType);
    if ((result['status'] != miOk) || (result['backLen'] != 0x10)) {
      result['status'] = miErr;
    }

    return result;
  }

  Future<Map<String, dynamic>> anticoll() async {
    writeReg(bitFramingReg, 0x00);
    List<int> serNum = [piccAntiColl, 0x20];

    var result = await mfrc522ToCard(pcdTransceive, serNum);

    if (result['status'] == miOk) {
      var backData = result['backData'] as List<int>;
      if (backData.length == 5) {
        int serNumCheck = 0;
        for (int i = 0; i < 4; i++) {
          serNumCheck = serNumCheck ^ backData[i];
        }
        if (serNumCheck != backData[4]) {
          result['status'] = miErr;
        }
        result['uid'] = backData;
      } else {
        result['status'] = miErr;
      }
    }

    return result;
  }

  Future<List<int>> calculateCRC(List<int> pIndata) async {
    clearBitMask(divIrqReg, 0x04);
    setBitMask(fifoLevelReg, 0x80);

    for (int i = 0; i < pIndata.length; i++) {
      writeReg(fifoDataReg, pIndata[i]);
    }
    writeReg(commandReg, pcdCalcCrc);

    int i = 0xFF;
    while (true) {
      int n = readReg(divIrqReg);
      i--;
      if (i == 0 || (n & 0x04) > 0) break;
    }

    return [readReg(cRCResultRegL), readReg(cRCResultRegM)];
  }

  Future<int> selectTag(List<int> serNum) async {
    List<int> buf = [piccSelectTag, 0x70];
    buf.addAll(serNum);

    var crc = await calculateCRC(buf);
    buf.addAll(crc);

    var result = await mfrc522ToCard(pcdTransceive, buf);

    if (result['status'] == miOk && result['backLen'] == 0x18) {
      return result['backData'][0];
    }
    return 0;
  }

  Future<int> authenticate(int authMode, int blockAddr, List<int> sectorKey,
      List<int> serNum) async {
    List<int> buff = [authMode, blockAddr];
    buff.addAll(sectorKey);
    buff.addAll(serNum.sublist(0, 4));

    var result = await mfrc522ToCard(pcdAuthEnt, buff);

    if ((result['status'] != miOk) || ((readReg(status2Reg) & 0x08) == 0)) {
      return miErr;
    }

    return miOk;
  }

  void stopCrypto1() {
    clearBitMask(status2Reg, 0x08);
  }

  Future<List<int>> readTag(int blockAddr) async {
    List<int> recvData = [piccRead, blockAddr];
    var crc = await calculateCRC(recvData);
    recvData.addAll(crc);

    var result = await mfrc522ToCard(pcdTransceive, recvData);

    if (result['status'] != miOk) {
      dev.log("Error while reading!");
      return [];
    }

    var backData = result['backData'] as List<int>;
    if (backData.length == 16) {
      dev.log("Sector $blockAddr $backData");
      return backData;
    }
    return [];
  }

  Future<int> writeTag(int blockAddr, List<int> writeData) async {
    List<int> buff = [piccWrite, blockAddr];
    var crc = await calculateCRC(buff);
    buff.addAll(crc);

    var result = await mfrc522ToCard(pcdTransceive, buff);
    if (result['status'] != miOk ||
        result['backLen'] != 4 ||
        (result['backData'][0] & 0x0F) != 0x0A) {
      dev.log("Error while writing");
      return 1;
    }

    List<int> buf = List.from(writeData);
    crc = await calculateCRC(buf);
    buf.addAll(crc);

    result = await mfrc522ToCard(pcdTransceive, buf);
    if (result['status'] != miOk ||
        result['backLen'] != 4 ||
        (result['backData'][0] & 0x0F) != 0x0A) {
      dev.log("Error while writing");
      return 2;
    } else {
      dev.log("Data written successfully");
      return 0;
    }
  }

  Future<void> dumpClassic1K(List<int> key, List<int> uid) async {
    dev.log("Dumping entire MIFARE 1K card...");
    // Typically 16 sectors of 4 blocks each = 64 blocks total
    for (int blockAddr = 0; blockAddr < 64; blockAddr++) {
      // Authenticate each block with key A
      int status = await authenticate(piccAuthent1A, blockAddr, key, uid);
      if (status == miOk) {
        var blockData = await readTag(blockAddr);
        if (blockData.isNotEmpty) {
          dev.log("Block $blockAddr : $blockData");
        } else {
          dev.log("Failed reading block $blockAddr");
        }
        stopCrypto1();
      } else {
        dev.log("Authentication failed for block $blockAddr");
      }
    }
  }
}

class SimpleWS1850S {
  final WS1850S ws1850s;
  final List<int> key;
  final int trailerBlock;

  SimpleWS1850S()
      : ws1850s = WS1850S(),
        key = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF],
        trailerBlock = 11;

  void dispose() {
    ws1850s.close();
  }

  Future<Map<String, dynamic>> read() async {
    var result = await _readNoBlock(trailerBlock);
    while (result['id'] == null) {
      result = await _readNoBlock(trailerBlock);
    }
    return result;
  }

  Future<int?> readId() async {
    var id = await _readIdNoBlock();
    while (id == null) {
      id = await _readIdNoBlock();
    }
    return id;
  }

  Future<Map<String, dynamic>> write(String text) async {
    var result = await _writeNoBlock(text, trailerBlock);
    while (result['id'] == null) {
      await Future.delayed(Duration(milliseconds: 50));
      result = await _writeNoBlock(text, trailerBlock);
    }
    return result;
  }

  // Below are private methods adapted from those in Basicws1850s

  Future<Map<String, dynamic>> _readNoBlock(int trailerBlock) async {
    try {
      if (!_checkTrailerBlock(trailerBlock)) {
        throw ArgumentError('Invalid Trailer Block $trailerBlock');
      }

      var blockAddr = [trailerBlock - 3, trailerBlock - 2, trailerBlock - 1];
      var result = await ws1850s.request(piccReqIdl);
      if (result['status'] != miOk) {
        return {'id': null, 'text': null};
      }

      result = await ws1850s.anticoll();
      if (result['status'] != miOk) {
        return {'id': null, 'text': null};
      }

      var id = _uidToNum(result['uid']);
      await ws1850s.selectTag(result['uid']);
      var status = await ws1850s.authenticate(
          piccAuthent1A, trailerBlock, key, result['uid']);

      var data = <int>[];
      var textRead = '';

      if (status == miOk) {
        for (var blockNum in blockAddr) {
          var block = await ws1850s.readTag(blockNum);
          if (block.isNotEmpty) {
            data.addAll(block);
          }
        }
        if (data.isNotEmpty) {
          textRead = String.fromCharCodes(data);
        }
      }
      ws1850s.stopCrypto1();
      return {'id': id, 'text': textRead};
    } catch (e) {
      ws1850s.stopCrypto1();
      return {'id': null, 'text': null};
    }
  }

  Future<int?> _readIdNoBlock() async {
    var result = await ws1850s.request(piccReqIdl);
    if (result['status'] != miOk) {
      return null;
    }
    result = await ws1850s.anticoll();
    if (result['status'] != miOk) {
      return null;
    }
    return _uidToNum(result['uid']);
  }

  Future<Map<String, dynamic>> _writeNoBlock(
      String text, int trailerBlock) async {
    try {
      if (!_checkTrailerBlock(trailerBlock)) {
        throw ArgumentError('Invalid Trailer Block');
      }

      var blockAddr = [trailerBlock - 3, trailerBlock - 2, trailerBlock - 1];
      var reqRes = await ws1850s.request(piccReqIdl);
      if (reqRes['status'] != miOk) {
        return {'id': null, 'text': null};
      }

      var collRes = await ws1850s.anticoll();
      if (collRes['status'] != miOk) {
        return {'id': null, 'text': null};
      }

      var id = _uidToNum(collRes['uid']);
      var size = await ws1850s.selectTag(collRes['uid']);
      if (size == 0) {
        return {'id': null, 'text': null};
      }

      var auth = await ws1850s.authenticate(
          piccAuthent1A, trailerBlock, key, collRes['uid']);
      if (auth != miOk) {
        ws1850s.stopCrypto1();
        return {'id': null, 'text': null};
      }

      var data = text.padRight(blockAddr.length * 16).codeUnits;
      for (var i = 0; i < blockAddr.length; i++) {
        await ws1850s.writeTag(
            blockAddr[i], data.sublist(i * 16, (i + 1) * 16));
        await Future.delayed(Duration(milliseconds: 50));
      }

      ws1850s.stopCrypto1();
      return {'id': id, 'text': text, 'status': 'success'};
    } catch (e) {
      ws1850s.stopCrypto1();
      return {'id': null, 'text': null};
    }
  }

  bool _checkTrailerBlock(int trailerBlock) {
    return (trailerBlock + 1) % 4 == 0;
  }

  int _uidToNum(List<int> uid) {
    var n = 0;
    for (var i = 0; i < 5; i++) {
      n = n * 256 + uid[i];
    }
    return n;
  }
}
