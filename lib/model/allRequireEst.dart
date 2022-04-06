class AllRequireEstModel {
  String id;
  String customerId;
  String customerName;
  String header;
  String detail;
  String price;
  String status;

  AllRequireEstModel(
      {this.id,
      this.customerId,
      this.customerName,
      this.header,
      this.detail,
      this.price,
      this.status});

  factory AllRequireEstModel.fromJson(Map<String, dynamic> json) {
    return AllRequireEstModel(
      id: json["id"] as String == null ? null : json["id"],
      customerId:
          json["customer_id"] as String == null ? null : json["customer_id"],
      customerName: json["name"] as String == null ? null : json["name"],
      header: json["header"] as String == null ? null : json["header"],
      detail: json["detail"] as String == null ? null : json["detail"],
      price: json["price"] as String == null ? null : json["price"],
      status: json["status"] as String == null ? null : json["status"],
    );
  }
}
