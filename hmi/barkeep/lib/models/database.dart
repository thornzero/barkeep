
import 'package:sqlite3/sqlite3.dart' as sql;


const String _databasePath = "./db";

class JukeboxDB {
  final db = sql.sqlite3.open(_databasePath);
  JukeboxDB();

  String stripInvalidCharacters(String input) {
    return input.replaceAll(RegExp(r'[\\\/\:\*\?\"\<\>\|\-\.]'), '_');
  }


  void readMetadata(String id) {
    
  }

  void updateMetadata(String path) {

  }

  void dispose() {
    db.dispose();
  }
}
