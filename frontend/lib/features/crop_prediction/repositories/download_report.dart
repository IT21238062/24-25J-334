import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DownloadReportRepository {
  Future<String?> downloadReport() async {
    final url =
        Uri.parse("${dotenv.env['BASE_URL']}/crop-prediction/download-report");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Check the content type to determine if it's a PDF
        final contentType = response.headers['content-type'];

        // If the response is a direct PDF file
        if (contentType?.contains('application/pdf') == true ||
            response.body.startsWith('%PDF')) {
          // Handle permissions based on platform and Android version
          bool permissionGranted = false;

          if (Platform.isAndroid) {
            print("Android");
            print(await _isAndroid13OrHigher());
            // For Android 13+ (SDK 33+)
            if (await _isAndroid13OrHigher()) {
              // On Android 13+, we don't need storage permission for app-specific directories
              permissionGranted = true;
            } else {
              // For Android 12 and below
              var status = await Permission.storage.request();
              permissionGranted = status.isGranted;

              // If permission is still denied, show a dialog explaining why it's needed
              if (!permissionGranted) {
                print("Storage permission denied: ${status.name}");
                // You should show a dialog here explaining why the permission is needed
                // and guiding the user to app settings
                return "permission_denied";
              }
            }
            print(permissionGranted);
          } else if (Platform.isIOS) {
            // iOS doesn't need explicit permission for app documents directory
            permissionGranted = true;
          }

          if (!permissionGranted) {
            return "permission_denied";
          }

          // Get appropriate directory based on platform
          final Directory directory = await _getDownloadDirectory();

          print("Directory: ${directory.path}");

          // Generate a unique filename with timestamp
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final filePath =
              '/storage/emulated/0/Download/crop_report_$timestamp.pdf';
          print("File path: $filePath");

          // Write the PDF file directly from response bytes
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          print("PDF saved to: $filePath");
          return filePath;
        }
        // If it's JSON response
        else {
          try {
            final body = json.decode(response.body);
            return body["data"]["report"];
          } catch (e) {
            print("Error parsing JSON: $e");
            return null;
          }
        }
      } else {
        print("Error: HTTP ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error downloading report: $e");
      return null;
    }
  }

  // Helper method to check Android version
  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33; // Android 13 is API level 33
    }
    return false;
  }

  // Helper method to get the appropriate download directory
  Future<Directory> _getDownloadDirectory() async {
    Directory directory;

    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        // For Android 13+, use app-specific directory
        print("Android 13+");
        print(await getExternalStorageDirectory());
        print(await getExternalCacheDirectories());
        print(await getExternalStorageDirectories());
        directory = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      } else {
        // Try to use the Downloads directory first
        try {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            // Fall back to external storage
            final externalDir = await getExternalStorageDirectory();
            if (externalDir == null) {
              // Last resort: use app documents directory
              directory = await getApplicationDocumentsDirectory();
            } else {
              directory = externalDir;
            }
          }
        } catch (e) {
          // If there's any error, use app documents directory
          directory = await getApplicationDocumentsDirectory();
        }
      }
    } else {
      // For iOS
      directory = await getApplicationDocumentsDirectory();
    }

    return directory;
  }
}
