import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart'
    if (dart.library.io) 'file_download_io.dart';

class FileService {
  /// Download a file with the given content and filename
  static Future<void> downloadFile({
    required String content,
    required String filename,
  }) async {
    final bytes = utf8.encode(content);
    await saveFile(bytes: bytes, filename: filename);
  }

  /// Pick and read a JSON file
  static Future<String?> pickJsonFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        return utf8.decode(bytes);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
