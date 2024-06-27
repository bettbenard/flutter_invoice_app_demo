import 'package:flutter/material.dart';
import '../../utils/util.dart' as utils;

Widget subTotals(double subTotals, double totalVat) {
  const style = TextStyle(fontWeight: FontWeight.bold);
  return Align(
    alignment: Alignment.topRight,
    child: SizedBox(
      width: 300,
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: const Text(
              'Sub Total',
              style: style,
            ),
            trailing: Text(
              utils.twoDecimals(subTotals),
              style: style,
            ),
            dense: true,
          ),
          ListTile(
            title: const Text(
              'VAT',
              style: style,
            ),
            trailing: Text(
              utils.twoDecimals(totalVat),
              style: style,
            ),
            dense: true,
          ),
          ListTile(
            title: const Text(
              'Total Amount',
              style: style,
            ),
            trailing: Text(
              utils.twoDecimals(subTotals + totalVat),
              style: style,
            ),
            dense: true,
          ),
        ],
      ),
    ),
  );
}
