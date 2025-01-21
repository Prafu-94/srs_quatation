import 'package:get/get.dart';
import 'package:srs_quatation/model/quationModelClass.dart';

class CoustomerDetailModel {
  String? coustomerName;
  String? mobileNumber;
  RxString? projectType = "".obs;
  String? location;
  String? address;
  String? quatationNumber;
  String? date;
  String? time;
  QuatationModel? projectDetails;

  CoustomerDetailModel({
    this.coustomerName,
    this.mobileNumber,
    this.projectType,
    this.location,
    this.address,
    this.quatationNumber,
    this.date,
    this.time,
    this.projectDetails,
  });

  CoustomerDetailModel.fromJson(Map<String, dynamic> json) {
    coustomerName = json['Coustomer Name'];
    mobileNumber = json['Mobile Number'];
    projectType!.value = json['Project Type'];
    location = json['Location'];
    address = json['Address'];
    quatationNumber = json['Quatation Number'];
    date = json['Date'];
    time = json['Time'];
    projectDetails = QuatationModel.fromJson(Map<String, dynamic>.from(json['Project Details']));
  }
}
