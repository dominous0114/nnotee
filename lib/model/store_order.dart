class OrderModel {
  String id;
  String ordersId;
  String storeId;
  String storeName;
  String name;
  String detail;
  String totalprice;
  String telCus;
  String statusName;
  String storePic;
  String storeTel;
  String storelati;
  String storelongi;
  String storeUsername;
  String numReview;

  OrderModel(
      {this.id,
      this.ordersId,
      this.storeId,
      this.storeName,
      this.name,
      this.detail,
      this.totalprice,
      this.telCus,
      this.statusName,
      this.storePic,
      this.storeTel,
      this.storelati,
      this.storelongi,
      this.storeUsername,
      this.numReview});

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json["id"] as String == null ? null : json["id"],
      ordersId: json["orders_id"] as String == null ? null : json["orders_id"],
      storeId: json["store_id"] as String == null ? null : json["store_id"],
      storeName: json["Sname"] as String == null ? null : json["Sname"],
      name: json["name"] as String == null ? null : json["name"],
      detail: json["detail"] as String == null ? null : json["detail"],
      totalprice:
          json["totalprice"] as String == null ? null : json["totalprice"],
      telCus: json["telCus"] as String == null ? null : json["telCus"],
      statusName:
          json["status_name"] as String == null ? null : json["status_name"],
      storePic: json["storePic"] as String == null ? null : json["storePic"],
      storeTel: json["storeTel"] as String == null ? null : json["storeTel"],
      storelati: json["storelati"] as String == null ? null : json["storelati"],
      storelongi:
          json["storelongi"] as String == null ? null : json["storelongi"],
      storeUsername: json["storeUsername"] as String == null
          ? null
          : json["storeUsername"],
      numReview:
          json["num_review"] as String == null ? null : json["num_review"],
    );
  }
}
