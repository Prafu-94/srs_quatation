// ignore_for_file: missing_return
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:srs_quatation/model/quationModelClass.dart';
import 'package:pdf/widgets.dart' as pw;

import '../global/global_icons.dart';
import '../global/global_string.dart';
import '../main.dart';
import '../model/coustomer_detail_model.dart';
import '../view/pdf_view.dart';
import '../view/quatation_generate_page.dart';

class QuatationCotroller extends GetxController {
  TextEditingController totalPayableTextEditingController =
      TextEditingController();
  TextEditingController structurePriceTextEditingController =
      TextEditingController();
  TextEditingController discomMeterTextEditingController =
      TextEditingController();
  TextEditingController ppaStampTextEditingController = TextEditingController();
  pw.Document docData = pw.Document();
  var internetConnection;
  bool isInternetConnectionStarted = false;
  RxString selectedPanelType = 'Mono-Bificial'.obs;
  Database? db;

  DatabaseReference ref = FirebaseDatabase.instance.ref("coustomer_detail/");
  Rx<TypeOfProject> typeOfProject = TypeOfProject.Residential.obs;
  List<CoustomerDetailModel> coustomerDetailModel = [];
  List<String> panelType = [
    'Mono-Bificial',
    'Mono-Bificial TopCorn',
    'Monocrystal',
    'Polycrystal',
  ];

  List<String> projectType = [
    'Urban',
    'Rural',
  ];
  RxString selectPanelComapany = 'Goldi'.obs;
  List<String> panelCompany = [
    'Adani',
    'Waree',
    'Goldi',
    'Redrew',
    'Pahal',
    'Rayzon',
    'Vikram',
  ];

  List<String> inverterCompany = [
    'Solar Yann',
    'Waree',
    'Growat',
    'Goodwi',
    'Vsole',
    'Deye',
  ];
  late File _pdfFile;
  late String _filePath;

  @override
  void dispose() {
    internetConnection!.cancel();
    db!.close();
    super.dispose();
  }

  RxBool canAllowToGenerateQuatation = true.obs;
  SharedPreferences? prefs;

  @override
  void onInit() async {
    prefs = await SharedPreferences.getInstance();
    loadFirebaseData();
    await internetListner();
    super.onInit();
  }

  Future<void> internetListner() async {
    internetConnection =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          isInternetConnectionStarted = true;
          print("isInternetConnectionStarted:$isInternetConnectionStarted");
          break;
        case InternetStatus.disconnected:
          isInternetConnectionStarted = false;
          print("isInternetConnectionStarted:$isInternetConnectionStarted");
          break;
      }
    });
  }

  void saveDataOnlineOrOffline(CoustomerDetailModel coustomerDetail,
      QuatationModel quatationModel, String dateToday, String now) {
    if (isInternetConnectionStarted) {
      saveCoustomerData(coustomerDetail, quatationModel, dateToday, now);
    } else {
      saveDataInLocalDatabase(coustomerDetail, quatationModel, dateToday, now);
    }
  }

  void saveDataInLocalDatabase(CoustomerDetailModel coustomerDetail,
      QuatationModel quatationModel, String dateToday, String now) async {}

  void saveCoustomerData(CoustomerDetailModel coustomerDetail,
      QuatationModel quatationModel, String dateToday, String time) async {
    await ref.push().set({
      "Quatation Number": coustomerDetail.quatationNumber,
      "Coustomer Name": coustomerDetail.coustomerName,
      "Mobile Number": coustomerDetail.mobileNumber,
      "Address": coustomerDetail.address,
      "Location": coustomerDetail.location,
      "Project Type": coustomerDetail.projectType!.value,
      "Time": dateToday.toString(),
      "Date": time.toString(),
      "Project Details": {
        "customerPayable": quatationModel.customerPayable!.value,
        "Subsidy": quatationModel.subsidy!.value,
        "Total Payable": quatationModel.totalPayable!.value,
        "Panel Type": quatationModel.panelType!.value,
        "Watt": quatationModel.watt!.value,
        "PPA Stamp Charge": quatationModel.ppaStampCharge!.value,
        "Discom Meter Charge": quatationModel.discomeCharges!.value,
        "Structure Price": quatationModel.structurePrice!.value,
        "Inverter Company": quatationModel.inverterCompany!.value,
        "Panel Company": quatationModel.panelCompany!.value,
        "KW": quatationModel.kw!.value,
        "No Of Panel": quatationModel.noOfPanel!.value,
        "Plant Registration Fees": quatationModel.plantRegistrationFee!.value,
      },
    });
  }

  Stream<List<CoustomerDetailModel>> fetchCustomerDetails() {
    return ref.onValue.map((event) {
      final dataSnapshot = event.snapshot;
      Map<String, dynamic> data =
          Map<String, dynamic>.from(dataSnapshot.value as Map);
      coustomerDetailModel.clear();
      coustomerDetailModel = data.entries.map((e) {
        return CoustomerDetailModel.fromJson(
            Map<String, dynamic>.from(e.value));
      }).toList();
      return coustomerDetailModel;
    });
  }

  void loadFirebaseData() async {
    canAllowToGenerateQuatation.value = prefs!.getBool("is_app_on") ?? true;
    print("canAllowToGenerateQuatation:$canAllowToGenerateQuatation");
    final db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await db.collection('is_start_app').doc("ejLING2zg4w9FPhmr7Cr").get();

    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      canAllowToGenerateQuatation.value = data["is_app_on"];
      prefs!.setBool("is_app_on", canAllowToGenerateQuatation.value);
    }
  }

  Future<void> _savePdfToTemporaryDirectory(Future<Uint8List> fileData) async {
    final tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/temp_pdf_file.pdf';
    _pdfFile = File(_filePath);
    Uint8List data = await fileData;
    await _pdfFile.writeAsBytes(data);
  }

  Future<Uint8List?> makePdf(QuatationModel quatationModel, String date,
      CoustomerDetailModel coustomerDetailModel) async {
    final gajanandSolarLogo = selectedFirm == SelectedFirm.ShreeGajanandSolar
        ? await imageFromAssetBundle(gajanand_solar_logo)
        : await imageFromAssetBundle(shree_ram_solar_logo);
    List<pw.Widget> widgets = [];
    final pdf = pw.Document();
    final subjectContainer = pw.Container(
      margin: pw.EdgeInsets.only(
        top: Get.height * 0.01,
        bottom: Get.height * 0.01,
      ),
      decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#ff781f'),
          border: pw.Border.all(
            color: PdfColor.fromHex('#000000'),
            width: 2,
          )),
      width: 1000,
      height: Get.height * 0.04,
      child: pw.Text('Subject: Proposal For Solar Rooftop Project',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
          )),
      alignment: pw.Alignment.center,
    );
    final projectDetail = pw.Container(
      decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#ff781f'),
          border: pw.Border.all(
            color: PdfColor.fromHex('#000000'),
            width: 2,
          )),
      width: 1000,
      height: Get.height * 0.028,
      child: pw.Text('Project Details',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
          )),
      alignment: pw.Alignment.center,
    );
    final projectDetailSubData = pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#000000')),
      children: [
        pw.TableRow(
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 6),
                  child: pw.Text(
                    'Customer Name:-',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Divider(height: 0.4),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 6),
                  child: pw.Text(
                    'Type Of Project:-',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Divider(height: 0.4),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 6),
                  child: pw.Text(
                    'Quatation No:-',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 6, bottom: 0.5),
                  child: pw.Text(
                    coustomerDetailModel.coustomerName!,
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                pw.Divider(height: 0.4),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 6, bottom: 0.9),
                  child: pw.Text(
                    coustomerDetailModel.projectType!.value,
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                pw.Divider(height: 0.4),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 6),
                  child: pw.Text(
                    coustomerDetailModel.quatationNumber!,
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 6),
                  child: pw.Text(
                    'Contact No:-',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Divider(height: 0.4),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 6),
                  child: pw.Text(
                    'City:-',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Divider(height: 0.4),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 6),
                  child: pw.Text(
                    'Reference:-',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 6, bottom: 0.5),
                  child: pw.Text(
                    coustomerDetailModel.mobileNumber!,
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                pw.Divider(height: 0.4),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 6, bottom: 0.9),
                  child: pw.Text(
                    coustomerDetailModel.location!,
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                pw.Divider(height: 0.4, thickness: 2),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 6),
                  child: pw.Text(
                    '',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    final addressDetail = pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#000000')),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 6),
              child: pw.Text(
                'Address:-',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                coustomerDetailModel.address!,
                style: const pw.TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
    final sizedBox = pw.SizedBox(height: 8);
    final detailTableHeadLine = pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#000000')),
      children: [
        pw.TableRow(
          children: [
            pw.Container(
              alignment: pw.Alignment.center,
              width: Get.width * 0.09,
              color: PdfColor.fromHex('#ff781f'),
              child: pw.Text('Sr. No.',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              color: PdfColor.fromHex('#ff781f'),
              child: pw.Text('Description',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              color: PdfColor.fromHex('#ff781f'),
              child: pw.Text('Qty.',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              color: PdfColor.fromHex('#ff781f'),
              child: pw.Text('Price',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              width: Get.width * 0.12,
              color: PdfColor.fromHex('#ff781f'),
              child: pw.Column(children: [
                pw.Text('Remarks',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ]),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
                padding: pw.EdgeInsets.only(
                    top: typeOfProject.value == TypeOfProject.Residential
                        ? Get.height * 0.036
                        : 0),
                child: pw.Center(
                  child: pw.Text('1',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14)),
                )),
            pw.Container(
              width: Get.width * 0.5,
              alignment: pw.Alignment.centerLeft,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 5),
                    child: pw.Text(
                      'EPC of ${quatationModel.kw} KW Solar Rooftop Plant',
                    ),
                  ),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Divider(height: 0.4),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 5),
                      child: pw.Text(
                        'Government Subsidy',
                      ),
                    ),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Divider(height: 0.4),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 5, top: 0.42),
                      child: pw.Text(
                          'Plant amount after subsidy offer by $solarFirmName',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                ],
              ),
            ),
            pw.Padding(
                padding: pw.EdgeInsets.only(
                    top: typeOfProject.value == TypeOfProject.Residential
                        ? Get.height * 0.036
                        : 0),
                child: pw.Center(
                  child: pw.Text('1 NOS'),
                )),
            pw.Container(
              width: Get.width * 0.14,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Row(
                    children: [
                      pw.SizedBox(width: 2),
                      pw.Text('Rs.'),
                      pw.Spacer(),
                      pw.Text('${quatationModel.totalPayable}'),
                      pw.SizedBox(width: 2),
                    ],
                  ),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Divider(height: 0.4),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Row(
                      children: [
                        pw.SizedBox(width: 2),
                        pw.Text('Rs.'),
                        pw.Spacer(),
                        pw.Text('-${quatationModel.subsidy}'),
                        pw.SizedBox(width: 2),
                      ],
                    ),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Divider(height: 0.4),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Container(
                      alignment: pw.Alignment.center,
                      height: Get.height * 0.04,
                      color: PdfColor.fromHex('#FFD700'),
                      child: pw.Row(
                        children: [
                          pw.SizedBox(width: 2),
                          pw.Text('Rs.',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              )),
                          pw.Spacer(),
                          pw.Text('${quatationModel.customerPayable}',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              )),
                          pw.SizedBox(width: 2),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              width: Get.width * 0.18,
              child: pw.Column(
                children: [
                  pw.Text('-'),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Divider(height: 0.4),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Text('-'),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Divider(height: 0.4),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Text('-'),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Divider(height: 0.4),
                  if (typeOfProject.value == TypeOfProject.Residential)
                    pw.Text('-'),
                ],
              ),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Center(
              child: pw.Text('2',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.only(left: 5),
              width: Get.width * 0.5,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Premium material cost with elevated structure 1 st leg upto feet',
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(top: Get.height * 0.01),
              child: pw.Center(
                child: pw.Text('1 NOS'),
              ),
            ),
            pw.Container(
              width: Get.width * 0.14,
              child: pw.Row(
                children: [
                  pw.SizedBox(width: 2),
                  pw.Padding(
                      padding: pw.EdgeInsets.only(top: Get.height * 0.01),
                      child: pw.Text('Rs.')),
                  pw.Spacer(),
                  pw.Padding(
                      padding: pw.EdgeInsets.only(top: Get.height * 0.01),
                      child: pw.Text('${quatationModel.structurePrice}')),
                  pw.SizedBox(width: 2),
                ],
              ),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              width: Get.width * 0.18,
              child: pw.Text('Included',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Center(
              child: pw.Text('3',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.only(left: 5),
              width: Get.width * 0.5,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'On site fabrication charges',
              ),
            ),
            pw.Center(
              child: pw.Text('1 NOS'),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              width: Get.width * 0.14,
              child: pw.Text('-'),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              width: Get.width * 0.18,
              child: pw.Column(
                children: [
                  pw.Text('-'),
                ],
              ),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Center(
              child: pw.Text('4',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.only(left: 5),
              width: Get.width * 0.5,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Extra charges (Material,Labour,etc.)',
              ),
            ),
            pw.Center(
              child: pw.Text('1 NOS'),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              width: Get.width * 0.14,
              child: pw.Text('-'),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              width: Get.width * 0.18,
              child: pw.Column(
                children: [
                  pw.Text('-'),
                ],
              ),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Center(
              child: pw.Text('5',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.only(left: 5),
              width: Get.width * 0.5,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Discom meter charge',
              ),
            ),
            pw.Center(
              child: pw.Text('1 NOS'),
            ),
            pw.Container(
              width: Get.width * 0.14,
              child: pw.Row(
                children: [
                  pw.SizedBox(width: 2),
                  pw.Text('Rs.'),
                  pw.Spacer(),
                  pw.Text('${quatationModel.discomeCharges}'),
                  pw.SizedBox(width: 2),
                ],
              ),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              width: Get.width * 0.18,
              child: pw.Text('Included',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Center(
              child: pw.Text('6',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.only(left: 5),
              width: Get.width * 0.5,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'PPA stamp paper duty',
              ),
            ),
            pw.Center(
              child: pw.Text('1 NOS'),
            ),
            pw.Container(
              width: Get.width * 0.14,
              child: pw.Row(
                children: [
                  pw.SizedBox(width: 2),
                  pw.Text('Rs.'),
                  pw.Spacer(),
                  pw.Text('${quatationModel.ppaStampCharge}'),
                  pw.SizedBox(width: 2),
                ],
              ),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              width: Get.width * 0.18,
              child: pw.Text('Included',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Center(
              child: pw.Text('7',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.only(left: 5),
              width: Get.width * 0.5,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'GST',
              ),
            ),
            pw.Center(
              child: pw.Text(''),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.only(right: 2),
              alignment: pw.Alignment.centerRight,
              width: Get.width * 0.14,
              child: pw.Text('13.8%'),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              width: Get.width * 0.18,
              child: pw.Text(
                'Included',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Center(
              child: pw.Text('8',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.only(left: 5),
              width: Get.width * 0.5,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Plant registration fees',
              ),
            ),
            pw.Center(
              child: pw.Text(''),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.only(right: 2),
              alignment: pw.Alignment.centerRight,
              width: Get.width * 0.14,
              child: pw.Text(quatationModel.plantRegistrationFee.toString()),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              width: Get.width * 0.18,
              child: pw.Text(
                'Included',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
    final grandTotal = pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#000000')),
      children: [
        pw.TableRow(
          children: [
            pw.Container(
                alignment: pw.Alignment.center,
                color: PdfColor.fromHex('#87CEEB'),
                width: 157.9,
                child: pw.Text('Grand Total:-',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold))),
            pw.Container(
              color: PdfColor.fromHex('#87CEEB'),
              padding: const pw.EdgeInsets.only(left: 40),
              child: pw.Text(
                'Rs. ${quatationModel.totalPayable}',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
    final notesPaymentCondition = pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Notes:-',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
              decoration: pw.TextDecoration.underline,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Container(
                margin: const pw.EdgeInsets.only(right: 10),
                width: 10,
                height: 10,
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#000000'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
              ),
              pw.Text('Offer valid only for 7 days from the quatation date.'),
            ],
          ),
          pw.Row(
            children: [
              pw.Container(
                margin: const pw.EdgeInsets.only(right: 10),
                width: 10,
                height: 10,
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#000000'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
              ),
              pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 6),
                  child: pw.Text(
                      'DISCOM Meter charge considered as per GUVNL guidelines, it\'s would differ after feasibility\nand that charge is payable as actual')),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Payment Conditions:-',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
              decoration: pw.TextDecoration.underline,
            ),
          ),
          pw.Row(
            children: [
              pw.Container(
                margin: const pw.EdgeInsets.only(right: 10),
                width: 10,
                height: 10,
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#000000'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8),
                child: pw.Text(
                    '10,000/kw advance with documents and remaining payment After DISCOM charge Quatation\nMaterial will be dispatched only after the 100% payment is received.'),
              ),
            ],
          ),
        ],
      ),
    );
    final paymentDetailContainer = pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.all(5),
      width: Get.width * 0.8,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BANK DETAIL:',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
              decoration: pw.TextDecoration.underline,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Bank Name:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                firm_bank_name,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#fd5532'),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Bank Account No:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                firm_bank_account_number,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#fd5532'),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'RTGS/IFSC Code:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                bank_ifsc_code,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#fd5532'),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'GSTIN NI:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                gst_number,
                style: pw.TextStyle(
                  color: PdfColor.fromHex('#fd5532'),
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
    );

    final billOfMaterial = pw.Container(
      margin: pw.EdgeInsets.only(
          top: typeOfProject.value == TypeOfProject.Residential ? 10 : 40),
      decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#ff781f'),
          border: pw.Border.all(
            color: PdfColor.fromHex('#000000'),
            width: 2,
          )),
      width: 1000,
      height: Get.height * 0.028,
      child: pw.Text('Bill Of Material',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
          )),
      alignment: pw.Alignment.center,
    );
    final billOfMaterialTable = pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#000000')),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#ff781f')),
          children: [
            pw.Center(
                child: pw.Text('Sr. No.',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Center(
                child: pw.Text('Material Description',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Center(
                child: pw.Text('Brand Make',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Center(
                child: pw.Text('Qty.',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Column(
              children: [
                pw.SizedBox(height: 1),
                pw.Text('1'),
                pw.Divider(height: 1),
                pw.Text('2'),
                pw.Divider(height: 1),
                pw.Text('3'),
                pw.Divider(height: 1),
                pw.Text('4'),
                pw.Divider(height: 1),
                pw.Text('5'),
                pw.Divider(height: 1),
                pw.Text('6'),
                pw.Divider(height: 1),
                pw.Text('7'),
                pw.Divider(height: 1),
                pw.Text('8'),
                pw.Divider(height: 1),
                pw.Text('9'),
                pw.SizedBox(height: 1),
              ],
            ),
            pw.Column(
              children: [
                pw.SizedBox(height: 1),
                pw.Text('Solar Panel'),
                pw.Divider(height: 1),
                pw.Text('Solar Inverter'),
                pw.Divider(height: 1),
                pw.Text('Panel Type'),
                pw.Divider(height: 1),
                pw.Text('Solar Structure'),
                pw.Divider(height: 1),
                pw.Text('Solar DC Cable'),
                pw.Divider(height: 1),
                pw.Text('Solar AC Cable'),
                pw.Divider(height: 1),
                pw.Text('Earthing Kit'),
                pw.Divider(height: 1),
                pw.Text('LA Cable'),
                pw.Divider(height: 1),
                pw.Text('AC-DC (BOX)'),
                pw.SizedBox(height: 1),
              ],
            ),
            pw.Column(
              children: [
                pw.SizedBox(height: 1),
                pw.Text(
                    "${quatationModel.panelCompany!} (${quatationModel.watt}) watt's"),
                pw.Divider(height: 1),
                pw.Text(quatationModel.inverterCompany!.value),
                pw.Divider(height: 1),
                pw.Text(quatationModel.panelType!.value),
                pw.Divider(height: 1),
                pw.Text('M.S Hot Dip Galvanize (80 Micron)'),
                pw.Divider(height: 1),
                pw.Text('Polycab/Hylum'),
                pw.Divider(height: 1),
                pw.Text('Polycab/Hylum'),
                pw.Divider(height: 1),
                pw.Text('Vasudhara/Connect/Wiptech'),
                pw.Divider(height: 1),
                pw.Text('Apar/Hylum'),
                pw.Divider(height: 1),
                pw.Text('Schneider/Polycab/L&T'),
                pw.SizedBox(height: 1),
              ],
            ),
            pw.Column(
              children: [
                pw.SizedBox(height: 1),
                pw.Text('${quatationModel.noOfPanel} NOS.'),
                pw.Divider(height: 1),
                pw.Text('1 Nos.'),
                pw.Divider(height: 1),
                pw.Text('1 Nos.'),
                pw.Divider(height: 1),
                pw.Text('As per Requirement'),
                pw.Divider(height: 1),
                pw.Text('As per Requirement'),
                pw.Divider(height: 1),
                pw.Text('As per Requirement'),
                pw.Divider(height: 1),
                pw.Text('3 NOS.'),
                pw.Divider(height: 1),
                pw.Text('1 NOS.'),
                pw.Divider(height: 1),
                pw.Text('As per Requirement'),
                pw.SizedBox(height: 1),
              ],
            ),
          ],
        ),
      ],
    );
    final note = pw.Row(
      children: [
        pw.Text('Note: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
        pw.Text(
            'If in any condition, any material is not available which is committed for supply,just inform us.',
            style: const pw.TextStyle(fontSize: 11))
      ],
    );
    final projectComplition = pw.Text('Project Completion:-',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold));
    final completionLine = pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Row(
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(right: 10),
            width: 10,
            height: 10,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#000000'),
              borderRadius: const pw.BorderRadius.all(
                pw.Radius.circular(6),
              ),
            ),
          ),
          pw.Text(
              'Installation complete in 60 days (Subject to payment completion)'),
        ],
      ),
    );
    final warranty = pw.Text('Warranty',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold));
    final warrentyLine1 = pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Row(
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(right: 10),
            width: 9,
            height: 9,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#000000'),
              borderRadius: const pw.BorderRadius.all(
                pw.Radius.circular(6),
              ),
            ),
          ),
          pw.Text(
              'Warranty period starts from the date on which Bi-directional Meter is installed.'),
        ],
      ),
    );
    final warrentyLine2 = pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Row(
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(right: 10),
            width: 9,
            height: 9,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#000000'),
              borderRadius: const pw.BorderRadius.all(
                pw.Radius.circular(6),
              ),
            ),
          ),
          pw.Text(selectedFirm == SelectedFirm.ShreeGajanandSolar
              ? 'Solar inverter has 10 years warranty.'
              : 'Solar inverter has 5 years warranty.'),
        ],
      ),
    );
    final warrentyLine3 = pw.Row(
      children: [
        pw.Container(
          margin: const pw.EdgeInsets.only(right: 10),
          width: 9,
          height: 9,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#000000'),
            borderRadius: const pw.BorderRadius.all(
              pw.Radius.circular(6),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 5),
          child: pw.Text(
              'Solar Panel 30 years of Product Warranty Linear power warranty for 25 years with\n2.5% for 1st year degradation and 0.67% from year 2 to year 30'),
        ),
      ],
    );
    final boldWarrentyLine = pw.Padding(
        padding: const pw.EdgeInsets.only(left: 18, top: 2),
        child: pw.Text(
            '(Warranty claim conditions will as per Manufacturer Guidelines)',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
    final systemStandardWarrenty = pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Row(
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(right: 10),
            width: 9,
            height: 9,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#000000'),
              borderRadius: const pw.BorderRadius.all(
                pw.Radius.circular(6),
              ),
            ),
          ),
          pw.Text('Full System 5 years standard warranty'),
        ],
      ),
    );
    final forShreeGajanandSolar = pw.Padding(
      padding: const pw.EdgeInsets.only(top: 34),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('For, $solarFirmName',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Accepted By',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
    final stampLine = pw.Padding(
      padding: const pw.EdgeInsets.only(top: 84),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Authorized Signatory',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Customer Signatory',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
    widgets.add(subjectContainer);
    widgets.add(projectDetail);
    widgets.add(projectDetailSubData);
    widgets.add(addressDetail);
    widgets.add(sizedBox);
    widgets.add(detailTableHeadLine);
    widgets.add(grandTotal);
    widgets.add(sizedBox);
    widgets.add(notesPaymentCondition);
    widgets.add(paymentDetailContainer);
    widgets.add(billOfMaterial);
    widgets.add(sizedBox);
    widgets.add(billOfMaterialTable);
    widgets.add(sizedBox);
    widgets.add(note);
    widgets.add(sizedBox);
    widgets.add(sizedBox);
    widgets.add(projectComplition);
    widgets.add(completionLine);
    widgets.add(sizedBox);
    widgets.add(sizedBox);
    widgets.add(warranty);
    widgets.add(warrentyLine1);
    widgets.add(warrentyLine2);
    widgets.add(warrentyLine3);
    widgets.add(boldWarrentyLine);
    widgets.add(systemStandardWarrenty);
    widgets.add(forShreeGajanandSolar);
    widgets.add(stampLine);
    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Image(gajanandSolarLogo, height: 100, width: 100),
                pw.Text(solarFirmName,
                    style: pw.TextStyle(
                        fontSize: 26, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Date:- $date',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ],
        ),
        build: (context) => widgets,
      ),
    );
    await _savePdfToTemporaryDirectory(pdf.save());
    Get.to(PdfView(_pdfFile));
    return null;
  }
}
