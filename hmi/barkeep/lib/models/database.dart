import 'dart:convert';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:metadata_god/metadata_god.dart';

const String _databasePath = "./db";
const String _metadataTable = "jukebox_metadata";

extension PictureEncoding on Picture {
  /// Encode the Picture object to a Base64 string.
  String encodeToBase64() {
    String jsonStr = jsonEncode({
      'mimeType': mimeType,
      'data': base64Encode(data), // Convert Uint8List to base64 string
    });
    return base64Encode(utf8.encode(jsonStr)); // Convert JSON string to Base64
  }

  /// Decode a Base64 string back to a Picture object.
  static Picture decodeFromBase64(String base64Str) {
    String jsonStr =
        utf8.decode(base64Decode(base64Str)); // Decode Base64 to JSON string
    Map<String, dynamic> jsonMap = jsonDecode(jsonStr); // Parse JSON string
    return Picture(
      mimeType: jsonMap['mimeType'],
      data: base64Decode(
          jsonMap['data']), // Convert base64 string back to Uint8List
    );
  }
}

extension MetadataList on Metadata {
  List<Object?> toObjectList() {
    return <Object?>[
      title,
      durationMs,
      artist,
      album,
      albumArtist,
      trackNumber,
      trackTotal,
      discNumber,
      discTotal,
      year,
      genre,
      picture,
      fileSize
    ];
  }
}

class JukeboxDB {
  final db = sql.sqlite3.open(_databasePath);
  JukeboxDB() {
    init();
  }

  void init() {
    db.execute('''
      CREATE TABLE IF NOT EXISTS $_metadataTable (
        id TEXT UNIQUE PRIMARY KEY,
        title TEXT NOT NULL,
        duration REAL,
        artist TEXT,
        album TEXT,
        album_artist TEXT,
        track_number INTEGER,
        track_total INTEGER,
        disc_number INTEGER,
        disc_total INTEGER,
        year INTEGER,
        genre TEXT
        picture BLOB,
        filesize BLOB
      );
    ''');
  }

  String stripInvalidCharacters(String input) {
    return input.replaceAll(RegExp(r'[\\\/\:\*\?\"\<\>\|\-\.]'), '_');
  }

  Future<void> createMetadata(List<String> playlist) async {
    final sql.PreparedStatement insert = db.prepare('''
        INSERT INTO $_metadataTable (
          id,
          title,
          duration,
          artist,
          album, 
          album_artist, 
          track_number, 
          track_total, 
          disc_number, 
          disc_total, 
          year, 
          genre, 
          picture, 
          filesize
        )
        VALUES (?)
    ''');
    for (var id in playlist) {
      var findResult = db.select('SELECT * FROM $_metadataTable WHERE id = ?',
          [stripInvalidCharacters(id)]);
      if (findResult.isEmpty) {
        var data = await MetadataGod.readMetadata(file: id);
        insert.execute([
          id,
          data.title,
          data.durationMs,
          data.artist,
          data.album,
          data.albumArtist,
          data.trackNumber,
          data.trackTotal,
          data.discNumber,
          data.discTotal,
          data.year,
          data.genre,
          data.picture!.encodeToBase64(),
          data.fileSize
        ]);
      }
    }
    insert.dispose();
  }

  Metadata readMetadata(String id) {
    final sql.ResultSet resultSet = db.select(
        'SELECT * FROM $_metadataTable WHERE id = ?',
        [stripInvalidCharacters(id)]);
    if (resultSet.isEmpty) return Metadata();
    final sql.Row row = resultSet.first;
    return Metadata(
      title: row['title'],
      durationMs: row['duration'],
      artist: row['artist'],
      album: row['album'],
      albumArtist: row['album_artist'],
      trackNumber: row['track_number'],
      trackTotal: row['track_total'],
      discNumber: row['disc_number'],
      discTotal: row['disc_total'],
      year: row['year'],
      genre: row['genre'],
      picture: PictureEncoding.decodeFromBase64(row['picture']! as String),
      fileSize: BigInt.from(row['filesize']!),
    );
  }

  Future<void> updateMetadata(String path) async {
    var data = await MetadataGod.readMetadata(file: path);
    db.execute('''
        UPDATE $_metadataTable
        SET title = ?,
         duration = ?, 
           artist = ?, 
            album = ?, 
     album_artist = ?, 
     track_number = ?,
      track_total = ?, 
      disc_number = ?, 
       disc_total = ?, 
             year = ?, 
            genre = ?, 
          picture = ?, 
         filesize = ?
        WHERE id = ?
    ''', [
      data.title,
      data.durationMs,
      data.artist,
      data.album,
      data.albumArtist,
      data.trackNumber,
      data.trackTotal,
      data.discNumber,
      data.discTotal,
      data.year,
      data.genre,
      data.picture!.encodeToBase64(),
      data.fileSize,
      stripInvalidCharacters(path)
    ]);
  }

  void deleteMetadata(String id) {
    db.execute('DELETE FROM $_metadataTable WHERE id = ?',
        [stripInvalidCharacters(id)]);
  }

  void dispose() {
    db.dispose();
  }
}
