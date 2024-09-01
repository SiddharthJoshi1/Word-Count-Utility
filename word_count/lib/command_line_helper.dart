import 'dart:io';

import 'package:args/args.dart';

enum InputFlag { byteCount, lineCount, wordCount, charCount, showAll }

class CommandLineHelper {
  ArgParser setupParser() {
    ArgParser baseParser = ArgParser();
    baseParser.addFlag("byteCount", abbr: "c", negatable: false);
    baseParser.addFlag("lineCount", abbr: "l", negatable: false);
    baseParser.addFlag("wordCount", abbr: "w", negatable: false);
    baseParser.addFlag("characterCount", abbr: "m", negatable: false);
    return baseParser;
  }

  InputFlag? parseInputFlag(ArgResults results, List<String> arguments) {
    InputFlag? inputFlag;
    if (results.wasParsed("byteCount")) {
      inputFlag = InputFlag.byteCount;
    } else if (results.wasParsed("lineCount")) {
      inputFlag = InputFlag.lineCount;
    } else if (results.wasParsed("wordCount")) {
      inputFlag = InputFlag.wordCount;
    } else if (results.wasParsed("characterCount")) {
      inputFlag = InputFlag.charCount;
    }
    return inputFlag;
  }

    Map<String, Stream> getStreamToParse(ArgResults results) {
    Stream streamToPass;
    String streamKey = '';
    if (results.rest.isNotEmpty) {
      bool isFilePath = FileSystemEntity.isFileSync(results.rest[0]);
      if (isFilePath) {
        String filePath = results.rest[0];
        streamKey = filePath;
        streamToPass = File(filePath).openRead();
      } else {
        throw Exception("Error: Parsed input is not a file path");
      }
    } else {
      //pass in stdin
      streamKey = "stdin";
      streamToPass = stdin;
    }
    return {streamKey: streamToPass};
  }
}