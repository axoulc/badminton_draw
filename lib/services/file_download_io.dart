import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/// Mobile/Desktop implementation using dart:io
Future<void> saveFile({
  required Uint8List bytes,
  required String filename,
}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(bytes);
  // Note: On mobile, files are saved to app documents directory
  // For user-accessible downloads, consider using share_plus or similar package
}
