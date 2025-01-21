import '../main.dart';

enum SelectedFirm { ShreeGajanandSolar, ShreeRamSolar }

//Shree Gajanand Solar
String solarFirmName = selectedFirm == SelectedFirm.ShreeGajanandSolar
    ? "Shree Gajanand Solar"
    : "Shree Ram Solar";
String firm_bank_name = selectedFirm == SelectedFirm.ShreeGajanandSolar
    ? "Bank of Baroda"
    : "State Bank of India";
String firm_bank_account_number =
    selectedFirm == SelectedFirm.ShreeGajanandSolar
        ? "35640200001944"
        : "35110326097";
String bank_ifsc_code = selectedFirm == SelectedFirm.ShreeGajanandSolar
    ? "BARB0DBPUNA"
    : "SBIN0050861";
String gst_number = selectedFirm == SelectedFirm.ShreeGajanandSolar
    ? "24DZZPB0587A1ZD"
    : '24BEJPP1031A1Z7';

// Shree Ram Solar
// String solarFirmName="Shree Ram Solar";
// String firm_bank_name="State Bank of India";
// String firm_bank_account_number="35110326097";
// String bank_ifsc_code="SBIN0050861";
// String gst_number="24BEJPP1031A1Z7";
