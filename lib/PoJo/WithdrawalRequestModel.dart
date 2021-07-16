class WithdrawalRequestModel {
  String? sId;
  String? withdrawalMethodId;
  String? accountNo;
  dynamic amount;
  String? status;
  String? note;
  String? userId;
  String? createdAt;
  String? updatedAt;

  WithdrawalRequestModel(
      {this.sId,
      this.withdrawalMethodId,
      this.accountNo,
      this.amount,
      this.status,
      this.note,
      this.userId,
      this.createdAt,
      this.updatedAt});

  WithdrawalRequestModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    withdrawalMethodId = json['withdrawalMethodId'];
    accountNo = json['accountNo'];
    amount = json['amount'];
    status = json['status'];
    note = json['note'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['withdrawalMethodId'] = this.withdrawalMethodId;
    data['accountNo'] = this.accountNo;
    data['amount'] = this.amount;
    data['status'] = this.status;
    data['note'] = this.note;
    data['userId'] = this.userId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
