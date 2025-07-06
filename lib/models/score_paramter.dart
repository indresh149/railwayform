class ScoreParameter {
  int marks = 0;
  String remarks = '';
  
  Map<String, dynamic> toJson() => {
    'marks': marks,
    'remarks': remarks,
  };
  
  static ScoreParameter fromJson(Map<String, dynamic> json) {
    final param = ScoreParameter();
    param.marks = json['marks'] ?? 0;
    param.remarks = json['remarks'] ?? '';
    return param;
  }
}