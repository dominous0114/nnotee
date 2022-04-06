class ReviewsModel {
  String id;
  String name;
  String pic;
  String num;
  String detail;
  String score;
  String rate;

  ReviewsModel(
      {this.id,
      this.name,
      this.pic,
      this.num,
      this.detail,
      this.score,
      this.rate,
      });

  factory ReviewsModel.fromJson(Map<String, dynamic> json) {
    return ReviewsModel(
        id: json["store_id"] as String == null ? null : json["store_id"],
        name: json["name"] as String == null ? null : json["name"],
        pic: json["pic"] as String == null ? null : json["pic"],
        detail: json["detail"] as String == null ? null : json["detail"],
        score: json["score"] as String == null ? null : json["score"],
        num: json["num_review"] as String == null ? null : json["num_review"],
        rate: json["rate"] as String == null ? null : json["rate"],
    );
  }
}
