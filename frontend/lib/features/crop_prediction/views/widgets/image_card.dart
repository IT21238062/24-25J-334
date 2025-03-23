import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:image_picker/image_picker.dart';
import 'package:plant_care/core/widgets/custom_button.dart';
import 'package:plant_care/features/crop_prediction/repositories/crop_prediction_repository.dart';

class ImageCard extends StatefulWidget {
  const ImageCard({super.key});

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  XFile? _pickedImage;
  String? error;
  String? result;

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = image; // Update the state with the selected image
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage, // Open image picker on card tap
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: Card(
                child: SizedBox(
                  height: 150,
                  child: Center(
                      child: Icon(
                    Icons.image,
                    size: 40,
                  )),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          if (_pickedImage != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Image",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Image.file(
                    File(_pickedImage!.path), // Display the selected image
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                CustomButton(
                  title: 'Predict',
                  onPressed: () async {
                    error = null;
                    result = null;
                    final res = await CropPredictionRepository()
                        .getPredictedCropFromImage(_pickedImage!);
                    print(res);
                    final _ = switch (res) {
                      fp.Right(value: final r) => setState(() {
                          result = r;
                        }),
                      fp.Left(value: final l) => setState(() {
                          error = l.message;
                        }),
                    };
                  },
                ),
                if (result != null || error != null)
                  Card(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: error == null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Prediction",
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    result!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              error!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                    ),
                  )
              ],
            ),
        ],
      ),
    );
  }
}
