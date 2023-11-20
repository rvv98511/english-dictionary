class WordModel {
  int? word_id;
  String? word, pronounce, meaning;

  WordModel ({
    required this.word_id,
    required this.word,
    required this.pronounce,
    required this.meaning
  });

  //From Json
  WordModel.fromJson(Map json) {
    this.word_id = json["word_id"];
    this.word = json["word"];
    this.pronounce = json["pronounce"];
    this.meaning = json["meaning"];
  }

  //From Json kiểu viết tắt
  // WordModel.fromJson1(Map json) :
  //   this.word_id = json["word_id"],
  //   this.word = json["word"],
  //   this.pronounce = json["pronounce"],
  //   this.meaning = json["meaning"];

  //Đẩy dữ liệu lên database
  toJson() {
    return {
      "word_id" : this.word_id,
      "word": this.word,
      "pronounce": this.pronounce,
      "meaning": this.meaning
    };
  }
}