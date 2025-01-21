import 'package:get/get.dart';

class QuatationModel {
  RxInt? watt=0.obs;
  RxInt? noOfPanel=0.obs;
  RxString? kw=''.obs;
  RxString? panelCompany=''.obs;
  RxString? panelType=''.obs;
  RxString? inverterCompany=''.obs;
  RxInt? totalPayable=0.obs;
  RxInt? structurePrice=0.obs;
  RxInt? discomeCharges=0.obs;
  RxInt? ppaStampCharge=0.obs;
  RxInt? subsidy=0.obs;
  RxInt? customerPayable=0.obs;
  RxInt? plantRegistrationFee=0.obs;

  QuatationModel({
    this.watt,
    this.noOfPanel,
    this.kw,
    this.panelCompany,
    this.panelType,
    this.inverterCompany,
    this.totalPayable,
    this.structurePrice,
    this.discomeCharges,
    this.ppaStampCharge,
    this.subsidy,
    this.customerPayable,//
    this.plantRegistrationFee,
  });

  QuatationModel.fromJson(Map<String, dynamic> json) {
    watt!.value=json['Watt'];
    noOfPanel!.value=json['No Of Panel'];
    kw!.value=json['KW'];
    panelCompany!.value=json['Panel Company'];
    panelType!.value=json['Panel Type'];
    inverterCompany!.value=json['Inverter Company'];
    totalPayable!.value=json['Total Payable'];
    structurePrice!.value=json['Structure Price'];
    discomeCharges!.value=json['Discom Meter Charge'];
    ppaStampCharge!.value=json['PPA Stamp Charge'];
    subsidy!.value=json['Subsidy'];
    customerPayable!.value=json['customerPayable'];
    plantRegistrationFee!.value=json['Plant Registration Fees'];
  }
}
