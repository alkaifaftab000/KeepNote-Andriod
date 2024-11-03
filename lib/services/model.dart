import 'package:intl/intl.dart';

class Model {
  late String id;
  String date;
  late int pin;
  late String title;
  late String content;
  late int bin;
  late int archive;
  late int hide;

  Model({
    required this.id,

    String? date,
    this.pin = 0,
    this.title = 'Sample Heading Not From Database',
    this.content =
        'This is the sample content, just for debugging (not from the database)',
    this.bin = 0,
    this.archive = 0,
    this.hide = 0,
  }) : date = date ?? DateFormat('d MMMM, y').format(DateTime.now());

  factory Model.fromList(List<dynamic> detail) {
    return Model(
      id: detail[0] as String,
      date: detail[1] as String,
      pin: detail[2] as int,
      title: detail[3] as String,
      content: detail[4] as String,
      bin: detail[5] as int,
      archive: detail[6] as int,
      hide:detail[7] as int
    );
  }

  // Factory method to create a Model instance from Firestore data
  factory Model.fromFirestore(Map<String, dynamic> data) {
    return Model(
      id: data['Id'] as String? ?? 'Unknown ID', // Changed to match Firestore
      date: data['Date'] as String? ??
          DateFormat('d MMMM, y')
              .format(DateTime.now()), // Changed to match Firestore
      pin: (data['Pin'] as int?) ?? 0,
      title: data['Title'] as String? ?? 'Sample Heading Not From Database',
      content: data['Content'] as String? ??
          'This is the sample content, just for debugging (not from the database)',
      bin: (data['Bin'] as int?) ?? 0,
      archive: (data['Archive'] as int?) ?? 0,
      hide:(data['Hide'] as int?) ?? 0
    );
  }

  // Add a toFirestore method to ensure consistency
  Map<String, dynamic> toFirestore() {
    return {
      'Id': id,
      'Date': date,
      'Pin': pin,
      'Title': title,
      'Content': content,
      'Bin': bin,
      'Archive': archive,
      'Hide':hide
    };
  }
}
