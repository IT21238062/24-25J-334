import 'package:flutter/material.dart';
import 'package:plant_care/features/crop_prediction/repositories/download_report.dart';
import 'package:plant_care/features/crop_prediction/views/widgets/form_card.dart';
import 'package:plant_care/features/crop_prediction/views/widgets/image_card.dart';

class CropPredictionPage extends StatefulWidget {
  const CropPredictionPage({super.key, required this.title});
  final String title;

  @override
  State<CropPredictionPage> createState() => _CropPredictionPageState();
}

class _CropPredictionPageState extends State<CropPredictionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Downloading report...'),
                ),
              );
              await DownloadReportRepository().downloadReport();
              if (context.mounted) {
                print("Showing success snackbar");
                // hide the snackbar
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report downloaded successfully'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: const [
          FormCard(),
          SizedBox(
            height: 20,
          ),
          ImageCard(),
        ],
      ),
    );
  }
}
