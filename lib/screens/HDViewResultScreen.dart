import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/MIAColors.dart';

class HDViewResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  HDViewResultScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: miaPrimaryColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ).paddingSymmetric(horizontal: 8),
          title: Text(
            'Result',
            style: TextStyle(
              color: Colors.black, // Màu chữ
              fontWeight: FontWeight.bold,
              fontSize: 16.0, // Kích thước chữ
            ),
          )),
      body: Center(
        child: data['plant'] != null
            ? _buildPlantInfo(data['plant'])
            : _buildEstimates(data['estimate']),
      ),
    );
  }

  Widget _buildPlantInfo(Map<String, dynamic> plant) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Plant: ${plant['name']}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            'Description: ${plant['description'] ?? 'description'}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            'Category: ${plant['plantCategories'][0]['category']['name'] ?? 'abc'}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          for (var image in plant['images'])
            Image.network(image['url']), // Hiển thị
        ],
      ),
    );
  }

  Widget _buildEstimates(List<dynamic> estimates) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 48.0),
            child: Text(
              'Plant Undefine!Some Predictions:',
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
          for (var estimate in estimates)
            Column(
              children: [
                Text(
                  '${estimate['plant']['name']}: ${(estimate['confidence'] * 100).toStringAsFixed(2)}%',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
                for (var image in estimate['plant']['images'])
                  Image.network(image['url']),
                Divider(
                  color: Colors.black, // Màu của đường phân cách
                  height: 4.0,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
