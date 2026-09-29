import 'dart:math';

/// Ein Tagebucheintrag. Wird als JSON-Datei gespeichert.
class Entry {
  Entry({
    required this.id,
    required this.date,
    required this.updatedAt,
    this.title = '',
    this.body = '',
    this.mood,
    List<String>? images,
  }) : images = images ?? <String>[];

  factory Entry.create({DateTime? date, String title = '', String body = ''}) {
    final now = DateTime.now();
    return Entry(
      id: newId(),
      date: date ?? now,
      updatedAt: now,
      title: title,
      body: body,
    );
  }

  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        title: (json['title'] as String?) ?? '',
        body: (json['body'] as String?) ?? '',
        mood: json['mood'] as int?,
        images: ((json['images'] as List?) ?? const []).cast<String>().toList(),
      );

  final String id;
  DateTime date;
  DateTime updatedAt;
  String title;
  String body;

  /// 0 (schlecht) bis 4 (sehr gut), null = keine Angabe.
  int? mood;

  /// Dateinamen der Bilder im Bilder-Ordner.
  List<String> images;

  bool get isEmpty => title.trim().isEmpty && body.trim().isEmpty && images.isEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'title': title,
        'body': body,
        if (mood != null) 'mood': mood,
        'images': images,
      };

  static final _rng = Random.secure();

  static String newId() {
    final t = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    // Obergrenze bewusst ohne Bit-Shift: `1 << 32` ist im Web (JavaScript) 0.
    final r = _rng.nextInt(0x7fffffff).toRadixString(36);
    return '$t$r';
  }
}
