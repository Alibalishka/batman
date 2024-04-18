library batman;

import 'dart:convert';
import 'dart:io';

class JsonToDartGenerator {
  final Map<String, dynamic> jsonData;
  final String className;

  JsonToDartGenerator(this.jsonData, this.className);

  String generate() {
    final buffer = StringBuffer();
    buffer.writeln(
        'import \'package:flutter/material.dart\';'); // Import dart:ui package

    // Generate class header
    buffer.writeln('class $className {');
    buffer.writeln();

    // Generate static const variables
    _generateVariables(buffer, jsonData, '');

    // Generate class footer
    buffer.writeln('}');
    return buffer.toString();
  }

  void _generateVariables(
      StringBuffer buffer, Map<dynamic, dynamic> data, String prefix) {
    data.forEach((key, value) {
      if (value is Map) {
        _generateVariables(buffer, value, '$prefix$key.');
      } else {
        if (key == 'value') {
          final type = _getType(data['type']);

          buffer.writeln(
              '  static const $type ${_toCamelCase('$prefix$key')} = ${getValue(value)};');
        }
      }
    });
  }

  dynamic _getType(dynamic type) {
    if (type == 'color') {
      return 'Color';
    }
  }

  dynamic getValue(String value) {
    if (value.toString().contains('#')) {
      return fromHex(value);
    } else if (value.toString().contains('{')) {
      return _toCamelCase(value.replaceAll('{', '')).replaceAll('}', '');
    } else {
      return "$value";
    }
  }

  static String fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('0xFF');
    buffer.write(hexString.replaceFirst('#', ''));
    return hexString == '#ffffff00'
        ? "Colors.transparent"
        : "Color(${buffer.toString()})";
  }
}

String _toCamelCase(String key) {
  // Remove any dashes and replace dots with camel case
  final transformedKey =
      key.replaceAll('-', '').replaceAll('.', '_').toLowerCase();

  final withoutValueSuffix = transformedKey.replaceAll('_value', '');

  // Split the key by underscores
  final parts = withoutValueSuffix.split('_');

  // Capitalize each part except the first one
  final capitalizedParts =
      parts.map((part) => part == parts.first ? part : part.capitalize());

  // Join the parts back together
  return capitalizedParts.join();
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart json_to_dart.dart <json_file>');
    exit(1);
  }

  print('ALI' + args.toString());

  final jsonFile = args[0];
  final jsonString = File(jsonFile).readAsStringSync();
  final jsonData = json.decode(jsonString);

  final generator = JsonToDartGenerator(jsonData, 'Assets');
  final dartCode = generator.generate();

  final outputFilePath =
      'lib/assets.dart'; // Change this to your desired output file path
  File(outputFilePath).writeAsStringSync(dartCode);

  print('Dart class generated successfully at $outputFilePath');
}
