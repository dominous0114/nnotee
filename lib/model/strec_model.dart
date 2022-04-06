class StoreRecordModel {
  String recId;
  String storeId;
  String id;
  String name;
  String username;
  String password;
  String email;
  String tel;
  String pic;
  String token;

  StoreRecordModel(
      {this.recId,
      this.storeId,
      this.id,
      this.name,
      this.username,
      this.password,
      this.email,
      this.tel,
      this.pic,
      this.token});

  StoreRecordModel.fromJson(Map<String, dynamic> json) {
    recId = json['rec_id'];
    storeId = json['store_id'];
    id = json['id'];
    name = json['name'];
    username = json['username'];
    password = json['password'];
    email = json['email'];
    tel = json['tel'];
    pic = json['pic'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rec_id'] = this.recId;
    data['store_id'] = this.storeId;
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['password'] = this.password;
    data['email'] = this.email;
    data['tel'] = this.tel;
    data['pic'] = this.pic;
    data['token'] = this.token;
    return data;
  }
}
