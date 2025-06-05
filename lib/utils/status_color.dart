import 'package:flutter/material.dart';

Color get statusColor {
  String? status;
    switch (status) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.pink;
      case '3':
        return Colors.yellow;
      case '4':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }