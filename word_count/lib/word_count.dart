import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';

// TODO think about archetecture
// Map out the way the data will flow for the 2 different states, pipe / no pipe;
// Maybe start over

// Please get some version control up in here

enum InputFlag { byteCount, lineCount, wordCount, charCount, showAll }

void main(List<String> arguments) async {
  exitCode = 0;

  ArgParser inputParser = setupParser();

  try {
    ArgResults results = inputParser.parse(arguments);
    InputFlag? parsedInputFlag = parseInputFlag(results, arguments);
    Map<String, Stream> streamMap = getStreamToParse(results);
    Stream parsedStream = streamMap.entries.first.value;
    String parsedStreamName = streamMap.entries.first.key == "stdin" ? '' : streamMap.entries.first.key;

    if (parsedInputFlag == null) {
      await printCount(InputFlag.showAll, parsedStream,  parsedStreamName);
    } else {
      await printCount(parsedInputFlag, parsedStream, parsedStreamName);
    }

    exit(0);
  } catch (e) {
    stderr.writeln(e);
    exit(2);
  }
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
  return {streamKey : streamToPass };
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

ArgParser setupParser() {
  ArgParser baseParser = ArgParser();
  baseParser.addFlag("byteCount", abbr: "c", negatable: false);
  baseParser.addFlag("lineCount", abbr: "l", negatable: false);
  baseParser.addFlag("wordCount", abbr: "w", negatable: false);
  baseParser.addFlag("characterCount", abbr: "m", negatable: false);
  return baseParser;
}

bool checkIfStdinPassedInText(String text) {
  if (text == '') {
    return false;
  } else {
    return true;
  }
}

Future<String> listenOnStdInData() async {
  String fullText = '';
  await for (final line in stdin.transform(utf8.decoder)) {
    fullText = fullText + line;
  }
  return fullText;
}

Future<int> lineCount(Stream stream) async {
  int count = 0;
  Stream<String> lines =
      stream.transform(utf8.decoder).transform(LineSplitter());
  count = await lines.length;
  return count;
}

Future<int> byteCount(Stream stream) async {
  int count = 0;
  await for (final byte in stream) {
    count = byte.length + count;
  }
  return count;
}

Future<List<int>> allCount(Stream stream) async {
  List bytes = await stream.toList();
  int byteCount = 0, lineCount = 0, wordCount = 0;
  String fullText = '';

  for (List<int> byte in bytes) {
    String convertedByte = Utf8Decoder().convert(byte);
    fullText = fullText + convertedByte;
    byteCount = byteCount + byte.length;
  }

  List<String> lines = LineSplitter().convert(fullText);
  for (String line in lines) {
    lineCount = lineCount + 1;
    String stringWithAllWhiteSpaceRemoved =
        line.replaceAll(RegExp(r"\s\b|\b\s"), " ");
    List<String> splitString = stringWithAllWhiteSpaceRemoved.split(' ');
    splitString.removeWhere((element) => element == ' ' || element == '');
    wordCount = wordCount + splitString.length;
  }

  return [byteCount, lineCount, wordCount];
}

Future<int> wordCount(Stream stream) async {
  Stream<String> lines =
      stream.transform(utf8.decoder).transform(LineSplitter());
  int wordCount = 0;
  await for (String line in lines) {
    String stringWithAllWhiteSpaceRemoved =
        line.replaceAll(RegExp(r"\s\b|\b\s"), " ");
    List<String> splitString = stringWithAllWhiteSpaceRemoved.split(' ');
    splitString.removeWhere((element) => element == ' ' || element == '');
    wordCount = wordCount + splitString.length;
  }
  return wordCount;
}

Future<int> characterCount(Stream stream) async {
  int count = 0;
  Stream<String> textOutput = stream.transform(utf8.decoder);
  await for (String text in textOutput) {
    count = count + text.length;
  }

  return count;
}

Future<void> printCount(InputFlag commandName, Stream fileStream, String fileName) async {
  try {
    switch (commandName) {
      case InputFlag.byteCount:
        int byteCountVal = await byteCount(fileStream);
        String outputString = "$byteCountVal $fileName";
        stdout.write(outputString);
        exit(0);

      case InputFlag.lineCount:
        int lines = await lineCount(fileStream);
        String outputString = "$lines $fileName";
        stdout.writeln(outputString);
        exit(0);

      case InputFlag.wordCount:
        int wordCountVal = await wordCount(fileStream);
        String outputString = "$wordCountVal $fileName";
        stdout.writeln(outputString);
        exit(0);

      case InputFlag.charCount:
        int characterCountVal = await characterCount(fileStream);
        String outputString = "$characterCountVal $fileName";
        stdout.writeln(outputString);
        exit(0);

      case InputFlag.showAll:
        List<int> allCountList = await allCount(fileStream);
        int byteCountVal = allCountList[0];
        int lines = allCountList[1];
        int wordCountVal = allCountList[2];
        String outputString = "$wordCountVal $lines $byteCountVal $fileName";
        stdout.writeln(outputString);
        exit(0);

      default:
        exit(0);
    }
  } catch (e) {
    stdout.write(e.toString());
    exit(2);
  }
}
