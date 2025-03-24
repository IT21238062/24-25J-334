import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:plant_care/core/models/failure.dart';

class WaterControlPredictionRepository {
  Future<Either<Failure, int>> getWaterControlPrediction() async {
    try {
      final String waterLevelPredictionUrl =
          "${dotenv.env['BASE_URL']}/predict/water-level";
      final response = await http.get(Uri.parse(waterLevelPredictionUrl));
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return Right(body["data"]["water_level"]);
      } else {
        return Left(Failure(message: response.body));
      }
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<dynamic>>> getWeatherReport(
      String cityName) async {
    try {
      final String weatherReportUrl =
          "${dotenv.env['BASE_URL']}/weather?city_name=$cityName";
      final response = await http.get(Uri.parse(weatherReportUrl));
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return Right(body["data"]["weather_data"]);
      } else {
        return Left(Failure(message: response.body));
      }
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
