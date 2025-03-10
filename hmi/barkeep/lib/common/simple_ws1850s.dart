import 'ws1850s.dart';

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
