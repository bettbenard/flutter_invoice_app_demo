import 'package:invoice_app/app/data/models/model.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

const currency = 'KSh';
const uuid = Uuid();
final ymd = DateFormat.yMd();

String get uid => uuid.v4();

String formatDate(DateTime dt) => ymd.format(dt);

DateTime dtFromStr(String str) {
  var dts = str.split('/').map((e) => int.parse(e)).toList();
  return DateTime(dts[2], dts[0], dts[1]);
}

// VAT Amount
double calculateTaxAmount(double amount, double vatRate) {
  return amount * vatRate / 100;
}

// Gross Amount (including VAT)
double calculateGrossAmount(double amount, double vatRate) {
  return amount +
      double.parse(calculateTaxAmount(amount, vatRate).toStringAsFixed(1));
}

// item subtotal
double calculateItemSubTotal(double unitPrice, double vat, int quantity) {
  return double.parse(
      (calculateGrossAmount(unitPrice, vat) * quantity).toStringAsFixed(1));
}

// invoice totals
double calculateInvoiceTotal(List<ItemEntry> itemEntries) {
  var total = 0.0;
  for (var e in itemEntries) {
    total += calculateItemSubTotal(e.unitPrice, e.vat.rate, e.quantity);
  }
  return total;
}

// format number to two decimal places
final numberFormat = NumberFormat('##########.00');
String twoDecimals(double value) {
  return numberFormat.format(value);
}
