class RequireEstModel {
  String id;
  String storeId;
  String storeName;
  String storeTel;
  String storeLati;
  String storeLongi;
  String storePic;
  String storeUsername;
  String storeToken;
  String distance;
  String header;
  String detail;
  String price;
  String statusName;

  RequireEstModel(
      {this.id,
      this.storeId,
      this.storeName,
      this.storeTel,
      this.storeLati,
      this.storeLongi,
      this.storePic,
      this.storeUsername,
      this.storeToken,
      this.distance,
      this.header,
      this.detail,
      this.price,
      this.statusName});

  factory RequireEstModel.fromJson(Map<String, dynamic> json) {
    return RequireEstModel(
      id: json["id"] as String == null ? null : json["id"],
      storeId: json["store_id"] as String == null ? null : json["store_id"],
      storeName: json["storeName"] as String == null ? null : json["storeName"],
      storeTel: json["storeTel"] as String == null ? null : json["storeTel"],
      storeLati: json["storeLati"] as String == null ? null : json["storeLati"],
      storeLongi:
          json["storeLongi"] as String == null ? null : json["storeLongi"],
      storePic: json["storePic"] as String == null ? null : json["storePic"],
      storeUsername: json["storeUsername"] as String == null
          ? null
          : json["storeUsername"],
      storeToken:
          json["storeToken"] as String == null ? null : json["storeToken"],
      distance: json["distance"] as String == null ? null : json["distance"],
      header: json["header"] as String == null ? null : json["header"],
      detail: json["detail"] as String == null ? null : json["detail"],
      price: json["price"] as String == null ? null : json["price"],
      statusName:
          json["status_name"] as String == null ? null : json["status_name"],
    );
  }
}
