import 'dart:io';
import 'dart:developer' as dev;

class Megaind {
  const Megaind({required String id});

  final String id = '0';

  Future<String> megaind(List<String> args) async {
    try {
      var result = await Process.run("megaind", args);
      return result.stdout;
    } catch (e) {
      dev.log("megaind call failed: $e");
    }
    return '';
  }

  Future<String> getVersion() async {
    return await megaind(['-v']);
  }

  Future<String> getWarranty() async {
    return await megaind(['-warranty']);
  }

  Future<List<String>> getStack() async {
    var result = await megaind(['-list']);
    return result.split('\n');
  }

  Future<BoardStatus> getStatus() async {
    var pattern = RegExp(
        r'Firmware ver ([\d.]+), CPU temperature (\d+) C, Power source ([\d.]+) V, Raspberry ([\d.]+) V');
    var board = await megaind([id, 'board']);
    var vbrd = await megaind([id, 'vbrd']);
    var match = pattern.firstMatch(board);

    return (match != null)
        ? BoardStatus(
            fwVersion: match.group(0)!,
            cpuTemperature: int.parse(match.group(1)!),
            sourceVoltage: double.parse(match.group(2)!),
            piVoltage: double.parse(match.group(3)!),
            boardVoltage: double.parse(vbrd),
          )
        : BoardStatus(
            fwVersion: 'na',
            cpuTemperature: 0,
            sourceVoltage: 0.0,
            piVoltage: 0.0,
            boardVoltage: 0.0,
          );
  }

  Future<bool> readOptoInChannel(int channel) async {
    var result = await megaind([id, 'optord', channel.toString()]);
    return bool.parse(result);
  }

  Future<int> readOptoInputs() async {
    var res = await megaind([id, 'optord']);
    return int.parse(res);
  }

  /// Read dry opto transitions count<br>
  /// Usage: megaind (id) countrd (channel)<br>
  /// Example:<br><code>megaind 0 countrd 2</code> Read transitions count of opto input pin #2 on Board #0
  Future<int> readOptoCounter(int channel) async {
    var res = await megaind([id, 'countrd', channel.toString()]);
    return int.parse(res);
  }

  Future<void> optoCounterReset(int channel) async {
    await megaind([id, 'countrst', channel.toString()]);
  }

  /// Read frequency applied to opto inputs<br>
  /// Usage: megaind (id) ifrd (channel)
  /// Example: megaind 0 ifrd 2; Read the signal frequency applied to opto input channel #2 on Board #0
  Future<int> readOptoFrequency(int channel) async {
    var res = await megaind([id, 'ifrd', channel.toString()]);
    return int.parse(res);
  }
}

class BoardStatus {
  BoardStatus({
    required String fwVersion,
    required int cpuTemperature,
    required double sourceVoltage,
    required double piVoltage,
    required double boardVoltage,
  });

  String? fwVersion;
  int? cpuTemperature;
  double? sourceVoltage;
  double? piVoltage;
  double? boardVoltage;
}
