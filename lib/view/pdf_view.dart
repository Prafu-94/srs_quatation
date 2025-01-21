import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart' as pd;
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';

class PdfView extends StatelessWidget {
  File pdfFile;

  PdfView(this.pdfFile, {super.key});

  pd.PdfController? pdfController;

  void loadPdf() {
    pdfController =
        pd.PdfController(document: pd.PdfDocument.openFile(pdfFile.path));
  }

  @override
  Widget build(BuildContext context) {
    loadPdf();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: Get.height * 0.88,
            child: pd.PdfView(
              controller: pdfController!,
              onDocumentLoaded: (document) {},
              onPageChanged: (page) {},
              scrollDirection: Axis.vertical,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await Share.shareXFiles([XFile(pdfFile.path)]);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red.shade900),
            ),
            child: const Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(
                  Icons.share,
                  color: Colors.white,
                ),
                SizedBox(width: 4),
                Text(
                  "Share",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
