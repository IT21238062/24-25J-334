import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:plant_care/core/models/failure.dart';
import 'package:plant_care/core/models/sensor_data.dart';
import 'package:plant_care/core/repositories/weather_repository.dart';
import 'package:plant_care/core/widgets/custom_button.dart';
import 'package:plant_care/core/widgets/result_card.dart';
import 'package:plant_care/features/water_control/repositories/water_control_prediction_repository.dart';
import 'package:plant_care/features/water_control/views/widgets/water_control_data_card.dart';
import 'package:plant_care/features/water_control/views/widgets/weather_section.dart';

class WaterControlPage extends StatefulWidget {
  const WaterControlPage({super.key, required this.title});
  final String title;

  @override
  State<WaterControlPage> createState() => _WaterControlPageState();
}

class _WaterControlPageState extends State<WaterControlPage> {
  int? waterLevel;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            const WeatherSection(),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder<SensorData>(
                stream: WeatherRepository().getWeatherData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return WaterControlDataCard(
                      lightSense: snapshot.data?.lightSense ?? 0,
                      smoke: snapshot.data?.smoke ?? 0,
                      soilMoisture: snapshot.data?.soilMoisture ?? 0,
                      soilTemperature: snapshot.data?.soilTemperature ?? 0,
                      humidity: snapshot.data?.humidity ?? 0,
                      temperature: snapshot.data?.temperature ?? 0,
                    );
                  } else if (snapshot.hasError) {
                    return const Text("Error");
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            CustomButton(
              title: 'Predict Water Level',
              onPressed: () async {
                setState(() {
                  waterLevel = null;
                  error = null;
                });
                final result = await WaterControlPredictionRepository()
                    .getWaterControlPrediction();

                final _ = switch (result) {
                  fpdart.Right(value: int value) => waterLevel = value,
                  fpdart.Left(value: Failure value) => error = value.message,
                };
                setState(() {});
              },
            ),
            const SizedBox(
              height: 20,
            ),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            if (waterLevel != null)
              ResultCard(
                prediction: waterLevel.toString(),
                title: 'Water Level',
              ),
          ],
        ),
      ),
    );
  }
}
