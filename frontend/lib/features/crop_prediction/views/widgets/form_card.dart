import 'package:flutter/material.dart';
import 'package:fpdart/src/either.dart';
import 'package:plant_care/core/widgets/custom_button.dart';
import 'package:plant_care/features/crop_prediction/model/form_data.dart';
import 'package:plant_care/features/crop_prediction/repositories/crop_prediction_repository.dart';

class FormCard extends StatefulWidget {
  const FormCard({super.key});

  @override
  State<FormCard> createState() => _FormCardState();
}

class _FormCardState extends State<FormCard> {
  final _formKey = GlobalKey<FormState>();
  final _intControllers = List.generate(3, (_) => TextEditingController());
  final _doubleControllers = List.generate(4, (_) => TextEditingController());

  String? prediction;
  String? error;

  final Map<String, List<String>> labels = {
    "int": ["Nitrogen(N)", "Phosphorus(P)", "Potassium(K)"],
    "double": ["Temperature", "Humidity", "pH", "Rainfall"],
  };

  @override
  void dispose() {
    for (var controller in _intControllers) {
      controller.dispose();
    }
    for (var controller in _doubleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nutrition',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ..._intControllers.asMap().entries.map((entry) {
              int index = entry.key;
              TextEditingController controller = entry.value;
              return TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: labels['int']![index]),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a numeric value';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              );
            }),
            const SizedBox(height: 16),
            const Text(
              'Condition',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ..._doubleControllers.asMap().entries.map((entry) {
              int index = entry.key;
              TextEditingController controller = entry.value;
              return TextFormField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    InputDecoration(labelText: labels['double']![index]),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter numeric value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              );
            }),
            const SizedBox(height: 16),
            CustomButton(
              title: 'Predict Crop',
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Form is valid, process the input

                  error = null;
                  prediction = null;

                  Map<String, dynamic> data = {};

                  _intControllers.asMap().forEach((index, controller) {
                    data[labels['int']![index]] = int.parse(controller.text);
                  });

                  _doubleControllers.asMap().forEach((index, controller) {
                    data[labels['double']![index]] =
                        double.parse(controller.text);
                  });

                  final predictedResult = await CropPredictionRepository()
                      .getPredictedCrop(FormData.fromMap(data));
                  print(predictedResult);
                  final _ = switch (predictedResult) {
                    Left(value: final l) => setState(() {
                        error = l.message;
                      }),
                    Right(value: final r) => setState(() {
                        prediction = r;
                      }),
                  };
                }
              },
            ),
            const SizedBox(
              height: 20,
            ),
            if (prediction != null && prediction!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Prediction"),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          Text(
                            prediction!,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            if (error != null && error!.isNotEmpty)
              Card(
                child: Column(
                  children: [
                    Text(
                      "Error",
                      style: TextStyle(color: Colors.red[700]),
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 30,
                        ),
                        Text(
                          error!,
                          style: TextStyle(color: Colors.red[700]),
                        )
                      ],
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
