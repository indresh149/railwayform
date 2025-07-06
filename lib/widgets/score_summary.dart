import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scorecard_controller.dart';

class ScoreSummary extends StatelessWidget {
  final ScoreCardController controller;
  
  const ScoreSummary({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Score:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                Obx(() => Text(
                  '${controller.totalScore}/150',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                )),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Percentage:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Obx(() => Text(
                  '${controller.scorePercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getGradeColor(controller.scoreGrade),
                  ),
                )),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grade:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getGradeColor(controller.scoreGrade),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.scoreGrade,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )),
              ],
            ),
            SizedBox(height: 16),
            _buildScoreBar(),
            SizedBox(height: 12),
            _buildGradeIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar() {
    return Obx(() {
      double percentage = controller.scorePercentage / 100;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${controller.scorePercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[300],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _getGradeColor(controller.scoreGrade),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildGradeIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGradeChip('A+', Colors.green[600]!, controller.scoreGrade == 'A+'),
        _buildGradeChip('A', Colors.green[500]!, controller.scoreGrade == 'A'),
        _buildGradeChip('B+', Colors.blue[500]!, controller.scoreGrade == 'B+'),
        _buildGradeChip('B', Colors.orange[500]!, controller.scoreGrade == 'B'),
        _buildGradeChip('C', Colors.orange[600]!, controller.scoreGrade == 'C'),
        _buildGradeChip('D', Colors.red[600]!, controller.scoreGrade == 'D'),
      ],
    );
  }

  Widget _buildGradeChip(String grade, Color color, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Text(
        grade,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return Colors.green[600]!;
      case 'A':
        return Colors.green[500]!;
      case 'B+':
        return Colors.blue[500]!;
      case 'B':
        return Colors.orange[500]!;
      case 'C':
        return Colors.orange[600]!;
      case 'D':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}