import 'package:test/test.dart';
import 'package:uuid/validation.dart';
import 'package:invoice_app/app/utils/util.dart' as utils;

void main() {
  test('Expects a valid uuid', () {
    final uuid = utils.uid;
    expect(UuidValidation.isValidUUID(fromString: uuid), true);
  });

  test('Number should be between 100,000 - 1,000,000 (excluding)', () {
    final invoiceNo = utils.generateRandomNumber();
    expect(invoiceNo, invoiceNo.clamp(100000, 1000000));
  });

  test('Given the amount and the VAT rate, calculates the VAT amount', () {
    expect(utils.calculateTaxAmount(10, 16), equals(1.6));
  });

  test(
      'Given the amount and the VAT rate, calculate the Gross Amount (including VAT)',
      () {
    expect(utils.calculateGrossAmount(10, 16), equals(11.6));
  });
}
