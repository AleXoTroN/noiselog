

class Entry {
  String type;
  String startDate;
  String endDate;
  String source;

  Entry({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.source
  });

  Entry.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        startDate = json['startDate'],
        endDate = json['endDate'],
        source = json['source'];

  Map<String, dynamic> toJson()=>{
        "type": type,
        "startDate": startDate,
        "endDate": endDate,
        "source": source,
      };
  }