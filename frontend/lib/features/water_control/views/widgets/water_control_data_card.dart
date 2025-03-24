import 'package:flutter/material.dart';
import 'package:plant_care/features/water_control/views/widgets/water_control_data.dart';

class WaterControlDataCard extends StatelessWidget {
  const WaterControlDataCard({
    super.key,
    required this.lightSense,
    required this.smoke,
    required this.soilMoisture,
    required this.soilTemperature,
    required this.humidity,
    required this.temperature,
  });
  final int lightSense;
  final int smoke;
  final double soilMoisture;
  final double soilTemperature;
  final int humidity;
  final double temperature;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Row(
      children: [
        // Left Column
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8.0, left: 15, bottom: 8, right: 8),
            child: Column(
              children: [
                WaterControlData(
                    text: "Light Sense", value: lightSense.toInt().toString()),
                WaterControlData(
                    text: "Smoke", value: smoke.toInt().toString()),
                WaterControlData(
                    text: "Soil Moisture",
                    value: soilMoisture.toStringAsFixed(3)),
              ],
            ),
          ),
        ),

        // Right Column
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              left: 8,
              bottom: 8,
              right: 15,
            ),
            child: Column(
              children: [
                WaterControlData(
                    text: "Soil Temperature",
                    value: soilTemperature.toStringAsFixed(1)),
                WaterControlData(
                    text: "Humidity", value: humidity.toStringAsFixed(1)),
                WaterControlData(
                    text: "Temperature", value: temperature.toStringAsFixed(1)),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
