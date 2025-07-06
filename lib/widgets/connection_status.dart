import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scorecard_controller.dart';

class ConnectionStatus extends StatelessWidget {
  final ScoreCardController controller = Get.find();
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.pendingSubmissions.isNotEmpty
      ? Card(
          color: Colors.orange[50],
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${controller.pendingSubmissions.length} submission(s) pending upload',
                    style: TextStyle(color: Colors.orange[800]),
                  ),
                ),
                if (controller.isOnline.value)
                  TextButton(
                    onPressed: () => controller.submitPendingData(),
                    child: Text('Upload Now'),
                  ),
              ],
            ),
          ),
        )
      : SizedBox());
  }
}