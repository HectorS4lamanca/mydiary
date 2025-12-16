class Diary {
  int id;
  String title;
  String description;
  String date;
  String imagename;

  Diary(
    this.id,
    this.title,
    this.description,
    this.date,
    this.imagename,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'imagename': imagename,
    };
  }

  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      map['id'],
      map['title'],
      map['description'],
      map['date'],
      map['imagename'],
    );
  }
}
