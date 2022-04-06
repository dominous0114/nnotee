class TrackModel {
  String id;
  String ordersId;
  String trackingName;
  String date;

  TrackModel(
      {this.id,
      this.ordersId,
      this.trackingName,
      this.date,
      });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
        id: json["id"] as String == null ? null : json["id"],
        ordersId: json["orders_id"] as String == null ? null : json["orders_id"],
        trackingName: json["TrackingName"] as String == null ? null : json["TrackingName"],
        date: json["date"] as String == null ? null : json["date"],       
    );
  }
}
