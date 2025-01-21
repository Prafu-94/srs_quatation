// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:srs_quatation/controller/quatationController.dart';
import 'package:srs_quatation/global/global_string.dart';
import 'package:srs_quatation/model/coustomer_detail_model.dart';
import 'package:srs_quatation/model/quationModelClass.dart';

import '../main.dart';

enum TypeOfProject { Residential, Commercial }

class QuatationGeneratePage extends StatelessWidget {
  QuatationGeneratePage({super.key});

  QuatationCotroller controller = Get.put(QuatationCotroller());
  Rx<QuatationModel> quatationModel = QuatationModel(
    kw: "3.24".obs,
    customerPayable: 90000.obs,
    discomeCharges: 2950.obs,
    inverterCompany: "Solar Yann".obs,
    noOfPanel: 6.obs,
    panelCompany: "Adani".obs,
    panelType: "Mono-Bificial".obs,
    plantRegistrationFee: 2000.obs,
    ppaStampCharge: 300.obs,
    structurePrice: 40000.obs,
    subsidy: 78000.obs,
    totalPayable: 168000.obs,
    watt: 540.obs,
  ).obs;
  RxString kw = '3.24'.obs;

  Rx<CoustomerDetailModel> coustomerDetail = CoustomerDetailModel(
    coustomerName: selectedFirm == SelectedFirm.ShreeGajanandSolar
        ? "Dinesh Bhavsar"
        : "Tarunbhai Patel",
    address: selectedFirm == SelectedFirm.ShreeGajanandSolar
        ? "19, Laxminagar, Punagam, Surat"
        : "622, Jalaram Society, Rankuva, Navsari",
    location:
        selectedFirm == SelectedFirm.ShreeGajanandSolar ? "Surat" : "Chikhali",
    mobileNumber: selectedFirm == SelectedFirm.ShreeGajanandSolar
        ? "9726196140"
        : "8200423670",
    projectType: "Urban".obs,
    quatationNumber: "111",
  ).obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(
      () => Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(4.0),
              width: Get.width * 0.45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepOrange)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Quatation Number:"),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.38,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        coustomerDetail.value.quatationNumber = value;
                      },
                      decoration: InputDecoration(
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: coustomerDetail.value.quatationNumber,
                          hintStyle: const TextStyle(color: Colors.grey)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            Container(
              padding: const EdgeInsets.all(4.0),
              width: Get.width * 0.45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepOrange)),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Enter Name"),
                      Text("Enter Mobile Number"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: TextField(
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            coustomerDetail.value.coustomerName = value;
                          },
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(color: Colors.grey),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            hintText: 'Enter Customer Name',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            coustomerDetail.value.mobileNumber = value;
                          },
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(color: Colors.grey),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            hintText: 'Customer Mobile Number',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Project Type"),
                      Text("Location"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black),
                        ),
                        width: MediaQuery.of(context).size.width * 0.45,
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.01),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: coustomerDetail.value.projectType!.value,
                          elevation: 16,
                          items: controller.projectType
                              .map<DropdownMenuItem<String>>(
                                  (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                              .toList(),
                          onChanged: (value) {
                            coustomerDetail.value.projectType!.value = value!;
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: TextField(
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            coustomerDetail.value.location = value;
                          },
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(color: Colors.grey),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            hintText: 'Enter Location',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Address:-",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.72,
                        child: TextField(
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            coustomerDetail.value.address = value;
                          },
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(color: Colors.grey),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            hintText: 'Enter Customer Address',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            Container(
              padding: const EdgeInsets.all(4.0),
              width: Get.width * 0.45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Generate Quatation For::",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: [
                      Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Radio(
                            value: TypeOfProject.Residential,
                            groupValue: controller.typeOfProject.value,
                            onChanged: (TypeOfProject? value) {
                              controller.typeOfProject.value = value!;
                            },
                          ),
                          const Text('Residential'),
                        ],
                      ),
                      Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Radio(
                            value: TypeOfProject.Commercial,
                            groupValue: controller.typeOfProject.value,
                            onChanged: (TypeOfProject? value) {
                              controller.typeOfProject.value = value!;
                            },
                          ),
                          const Text('Commercial'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            Container(
              padding: const EdgeInsets.all(4.0),
              width: Get.width * 0.45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Enter Watt\'s',
                            textAlign: TextAlign.center),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.04),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.38,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              quatationModel.value.watt!.value =
                                  int.parse(value);
                              double kwFractional = quatationModel.value.watt! *
                                  quatationModel.value.noOfPanel!.value /
                                  1000;
                              quatationModel.value.kw!.value =
                                  kwFractional.toString();
                            },
                            decoration: InputDecoration(
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                hintText: '540 watt',
                                hintStyle: const TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Enter Number of Panel',
                            textAlign: TextAlign.center),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.04),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.38,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              quatationModel.value.noOfPanel!.value =
                                  int.parse(value);
                              double kwFractional = quatationModel.value.watt! *
                                  quatationModel.value.noOfPanel!.value /
                                  1000;
                              quatationModel.value.kw!.value =
                                  kwFractional.toString();
                            },
                            decoration: InputDecoration(
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                hintText: '6 panels',
                                hintStyle: const TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(quatationModel.value.kw!.value),
                ],
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  width: MediaQuery.of(context).size.width * 0.46,
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.01),
                  child: Column(
                    children: [
                      const Text('Panel Company', textAlign: TextAlign.center),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      DropdownButton<String>(
                        value: quatationModel.value.panelCompany!.value,
                        elevation: 16,
                        items: controller.panelCompany
                            .map<DropdownMenuItem<String>>(
                                (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                            .toList(),
                        onChanged: (value) {
                          quatationModel.value.panelCompany!.value = value!;
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  width: MediaQuery.of(context).size.width * 0.46,
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.01),
                  child: Column(
                    children: [
                      const Text("Panel Type"),
                      DropdownButton<String>(
                        value: quatationModel.value.panelType!.value,
                        elevation: 16,
                        isExpanded: true,
                        items: controller.panelType
                            .map<DropdownMenuItem<String>>(
                                (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                            .toList(),
                        onChanged: (value) {
                          quatationModel.value.panelType!.value = value!;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.02),
            Container(
              width: Get.width * 0.45,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent)),
              child: Column(
                children: [
                  const Text('Inverter Company', textAlign: TextAlign.center),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  DropdownButton<String>(
                    value: quatationModel.value.inverterCompany!.value,
                    elevation: 16,
                    items: controller.inverterCompany
                        .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (value) {
                      quatationModel.value.inverterCompany!.value = value!;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: Get.height * 0.016),
            TextField(
              controller: controller.totalPayableTextEditingController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                quatationModel.value.totalPayable!.value = int.parse(value);
                quatationModel.value.customerPayable!.value =
                    quatationModel.value.totalPayable!.value -
                        quatationModel.value.subsidy!.value;
              },
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: '165000 (Enter total amount)',
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            TextField(
              controller: controller.structurePriceTextEditingController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                quatationModel.value.structurePrice!.value = int.parse(value);
              },
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText:
                    '${quatationModel.value.structurePrice}   (Structure Price)',
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            TextField(
              controller: controller.discomMeterTextEditingController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                quatationModel.value.discomeCharges!.value = int.parse(value);
              },
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText:
                    '${quatationModel.value.discomeCharges}   (Discom Meter Charge)',
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            TextField(
              controller: controller.ppaStampTextEditingController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                quatationModel.value.ppaStampCharge!.value = int.parse(value);
              },
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText:
                    '${quatationModel.value.ppaStampCharge}   (PPA Stamp Charge)',
              ),
            ),
            if (controller.typeOfProject.value == TypeOfProject.Residential)
              SizedBox(height: Get.height * 0.02),
            if (controller.typeOfProject.value == TypeOfProject.Residential)
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  quatationModel.value.subsidy!.value = int.parse(value);
                  quatationModel.value.customerPayable!.value =
                      quatationModel.value.totalPayable!.value -
                          quatationModel.value.subsidy!.value;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  hintText: '78000 Subsidy',
                ),
              ),
            const Divider(color: Colors.grey),
            Preview(quatationModel: quatationModel.value),
            if (controller.canAllowToGenerateQuatation.value)
              ElevatedButton(
                onPressed: () {
                  DateTime dateToday = DateTime.now();
                  // List<String> formatedDate =
                  //     DateFormat('dd-MM-yyyy').format(dateToday).split('-');
                  String formatedDate=DateFormat('dd-MM-yyyy').format(dateToday);
                  DateFormat formatter = DateFormat('HH:mm:ss');
                  String formattedTime = formatter.format(dateToday);
                  controller.saveDataOnlineOrOffline(coustomerDetail.value,
                      quatationModel.value, formattedTime, formatedDate);
                  controller.makePdf(quatationModel.value, formatedDate,
                      coustomerDetail.value);
                },
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(Colors.red.shade800)),
                child: const Text(
                  'Generate Quatation',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
          ],
        ),
      ),
    ));
  }
}

class Preview extends StatelessWidget {
  QuatationModel? quatationModel = QuatationModel();

  Preview({
    @required this.quatationModel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(bottom: 6),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.deepOrangeAccent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: Get.height * 0.01),
            const Text('Quatation Preview',
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const Divider(color: Colors.grey),
            Container(
              decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(6),
              child: Text(
                'KW:${quatationModel!.kw}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 6),
                const Text('System Total Price'),
                const Spacer(),
                Text(quatationModel!.totalPayable.toString()),
                const SizedBox(width: 6),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 6),
                const Text('Government Subsidy'),
                const Spacer(),
                Text('-${quatationModel!.subsidy.toString()}'),
                const SizedBox(width: 6),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 6),
                const Text(
                  'Rate After Subsidy',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  quatationModel!.customerPayable.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 6),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const SizedBox(width: 6),
                const Text('Structure price'),
                const Spacer(),
                Text(quatationModel!.structurePrice.toString()),
                const SizedBox(width: 6),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 6),
                const Text('Discometer charge'),
                const Spacer(),
                Text(quatationModel!.discomeCharges.toString()),
                const SizedBox(width: 6),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 6),
                const Text('PPA Stamp Charge'),
                const Spacer(),
                Text(
                  '${quatationModel!.ppaStampCharge}',
                ),
                const SizedBox(width: 6),
              ],
            ),
            const Divider(),
            Card(
              elevation: 12,
              color: Colors.blue[100],
              child: SizedBox(
                height: Get.height * 0.05,
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    const Text(
                      'Total Payable',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      quatationModel!.totalPayable.toString(),
                      style: TextStyle(
                          color: Colors.red[600], fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
