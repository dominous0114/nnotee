class StoreModel {
  String id;
  String adminId;
  String name;
  String username;
  String password;
  String email;
  String tel;
  String pic;
  String latitude;
  String longitude;
  String status;
  String detail;
  String token;
  String rate;

  StoreModel(
      {this.id,
      this.adminId,
      this.name,
      this.username,
      this.password,
      this.email,
      this.tel,
      this.pic,
      this.latitude,
      this.longitude,
      this.status,
      this.detail,
      this.token,
      this.rate});

  StoreModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    adminId = json['admin_id'];
    name = json['name'];
    username = json['username'];
    password = json['password'];
    email = json['email'];
    tel = json['tel'];
    pic = json['pic'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    detail = json['detail'];
    token = json['token'];
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['admin_id'] = this.adminId;
    data['name'] = this.name;
    data['username'] = this.username;
    data['password'] = this.password;
    data['email'] = this.email;
    data['tel'] = this.tel;
    data['pic'] = this.pic;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['status'] = this.status;
    data['detail'] = this.detail;
    data['token'] = this.token;
    data['rate'] = this.rate;
    return data;
  }
}
