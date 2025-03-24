import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:plant_care/core/models/failure.dart';
import 'package:plant_care/features/water_control/repositories/water_control_prediction_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:plant_care/features/water_control/views/widgets/water_control_data.dart';

class WeatherSection extends StatefulWidget {
  const WeatherSection({super.key});

  @override
  State<WeatherSection> createState() => _WeatherSectionState();
}

class _WeatherSectionState extends State<WeatherSection> {
  TextEditingController locationController = TextEditingController();
  String city = "";
  String? country;
  bool isLoading = true;
  @override
  void initState() {
    // Get user's location

    _loadWeatherData();
    super.initState();
  }

  void _loadWeatherData() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        setState(() {
          // Update UI to show error or prompt user to enable location
        });
        return;
      }

      // Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permission denied
          setState(() {
            // Update UI to show permission denied message
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission permanently denied
        setState(() {
          // Update UI to guide user to app settings
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print(position);

      // Perform reverse geocoding to get address information
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      print(placeMarks);

      if (placeMarks.isNotEmpty) {
        Placemark place = placeMarks[0];
        city = place.locality ?? ""; // This is the city name
        country = place.country;

        print("Location: $city, $country");

        // Now you can use city name along with coordinates for your weather API
        // await fetchWeatherData(position.latitude, position.longitude, city);

        await _getWeatherReport(city);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error getting location or address: $e");
      setState(() {
        isLoading = false;
        // Update UI to show error
      });
    }
  }

  String? error;

  List<dynamic> weatherReport = [];

  Future<void> _getWeatherReport(String location) async {
    final result =
        await WaterControlPredictionRepository().getWeatherReport(location);
    print(result);
    final _ = switch (result) {
      fpdart.Right(value: List<dynamic> value) => weatherReport = value,
      fpdart.Left(value: Failure value) => error = value.message,
    };
    print(weatherReport);
    setState(() {});
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBar(
          controller: locationController,
          onChanged: (value) {},
          onSubmitted: (value) {
            print(value);
            city = value;
            country = null;
            locationController.clear();
            if (city.isNotEmpty) {
              _getWeatherReport(city);
            }
          },
          trailing: [
            IconButton(
              onPressed: () async {
                city = locationController.text;
                country = null;
                locationController.clear();
                if (city.isNotEmpty) {
                  _getWeatherReport(city);
                }
              },
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        Card(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLoading
              ? const SizedBox(
                  height: 165,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          "City:",
                        ),
                        Text(
                          " $city",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await _getWeatherReport(city);
                            setState(() {
                              isLoading = false;
                            });
                          },
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(),
                                )
                              : const Icon(Icons.refresh),
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, left: 15, bottom: 8, right: 8),
                            child: Column(
                              children: [
                                WaterControlData(
                                    text: "Temperature",
                                    value: weatherReport[0].toString()),
                                WaterControlData(
                                    text: "Humidity",
                                    value: weatherReport[2].toString()),
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                WaterControlData(
                                    text: "Wind Speed",
                                    value: weatherReport[3].toString()),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(weatherReport[4].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        )),
                  ],
                ),
        ))
      ],
    );
  }
}
