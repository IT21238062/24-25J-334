import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:plant_care/core/models/failure.dart';
import 'package:plant_care/features/crop_prediction/model/form_data.dart';

class CropPredictionRepository {
  Future<Either<Failure, String>> getPredictedCrop(FormData formData) async {
    try {
      print(formData.toJson());
      final String cropPredictionUrl = "${dotenv.env['BASE_URL']}/predict/crop";
      print(cropPredictionUrl);
      final response = await http.post(Uri.parse(cropPredictionUrl),
          headers: {"Content-Type": "application/json"},
          body: formData.toJson());
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        final body = json.decode(response.body) as Map<String, dynamic>;
        return Right(body["data"]["predicted_crop"]);
      } else {
        print(json.decode(response.body));
        return Left(Failure(message: response.body));
      }
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> getPredictedCropFromImage(XFile image) async {
    try {
      final url = Uri.parse(
          "${dotenv.env['BASE_URL']}/predict/soil-type"); // Replace with your FastAPI endpoint
      final request = http.MultipartRequest('POST', url);
      final imageFile = File(image.path);

      // Attach the file to the request
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final body = json.decode(responseData);
        print(body);

        return Right(body["data"]["predicted_soil_type"]);
      } else {
        final responseData = await response.stream.bytesToString();
        return Left(
          Failure(message: responseData),
        );
      }
    } catch (e) {
      return Left(
        Failure(
          message: e.toString(),
        ),
      );
    }
  }
}
