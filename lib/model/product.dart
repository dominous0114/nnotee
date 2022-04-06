class ProductModel {
  String id;
  String storeId;
  String catalogId;
  String catalogName;
  String name;
  String price;

  ProductModel(
      {this.id,
      this.storeId,
      this.catalogId,
      this.catalogName,
      this.name,
      this.price});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
        id: json["id"] as String == null ? null : json["id"],
        storeId: json["store_id"] as String == null ? null : json["store_id"],
        catalogId: json["catalog_id"] as String == null? null : json["catalog_id"],
        catalogName: json["catalog_name"] as String == null? null : json["catalog_name"],
        name: json["name"] as String == null ? null : json["name"],
        price: json["price"] as String == null ? null : json["price"],
       
    );
  }
}
