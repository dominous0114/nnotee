class ChatModel {
  String id,
      cusName,
      storeName,
      customerPic,
      storePic,
      storeUsername,
      customerUsername;
  String storeId;
  String customerId;
  String customerToken;
  String storeToken;
  String customerTel;
  String storeTel;

  ChatModel(
      this.id,
      this.storeName,
      this.cusName,
      this.customerPic,
      this.storePic,
      this.storeId,
      this.customerId,
      this.storeUsername,
      this.customerUsername,
      this.customerToken,
      this.storeToken,
      this.customerTel,
      this.storeTel);
}
