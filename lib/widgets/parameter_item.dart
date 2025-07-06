import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/score_paramter.dart';

class ParameterItem extends StatelessWidget {
  final String title;
  final Rx<ScoreParameter> parameter;
  final IconData icon;
  
  const ParameterItem({
    Key? key,
    required this.title,
    required this.parameter,
    required this.icon,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blue[600]),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Obx(() => Chip(
          label: Text('${parameter.value.marks}'),
          backgroundColor: _getScoreColor(parameter.value.marks),
        )),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score (0-10):',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(11, (index) {
                    return Obx(() => FilterChip(
                      label: Text('$index'),
                      selected: parameter.value.marks == index,
                      onSelected: (selected) {
                        if (selected) {
                          parameter.value.marks = index;
                          parameter.refresh();
                        }
                      },
                      selectedColor: _getScoreColor(index),
                      backgroundColor: Colors.grey[100],
                    ));
                  }),
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Remarks (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  maxLines: 2,
                  onChanged: (value) {
                    parameter.value.remarks = value;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green[100]!;
    if (score >= 6) return Colors.yellow[100]!;
    if (score >= 4) return Colors.orange[100]!;
    return Colors.red[100]!;
  }
}