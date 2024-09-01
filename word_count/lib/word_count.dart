import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:word_count/command_line_helper.dart';
import 'package:word_count/counters.dart';

// TODO think about archetecture
// Map out the way the data will flow for the 2 different states, pipe / no pipe;
// Maybe start over




class WordCounter {


Future<void> count(List<String> arguments) async {
  CommandLineHelper commandLineHelper = CommandLineHelper();
  ArgParser inputParser = commandLineHelper.setupParser();

  try {
    ArgResults results = inputParser.parse(arguments);
    InputFlag? parsedInputFlag = commandLineHelper.parseInputFlag(results, arguments);
    Map<String, Stream> streamMap = commandLineHelper.getStreamToParse(results);
    Stream parsedStream = streamMap.entries.first.value;
    String parsedStreamName = streamMap.entries.first.key == "stdin"
        ? ''
        : streamMap.entries.first.key;
    if (parsedInputFlag == null) {
      await _printCount(InputFlag.showAll, parsedStream, parsedStreamName);
    } else {
      await _printCount(parsedInputFlag, parsedStream, parsedStreamName);
    }
    exit(0);
  } catch (e) {
    stderr.writeln(e);
    exit(2);
  }
}

  Future<void> _printCount(
      InputFlag commandName, Stream fileStream, String fileName) async {
    String outputString = '';
    Counters counters = Counters();
    try {
      switch (commandName) {
        case InputFlag.byteCount:
          int byteCountVal = await counters.byteCount(fileStream);
          outputString = "$byteCountVal $fileName";
          break;

        case InputFlag.lineCount:
          int lines = await counters.lineCount(fileStream);
          outputString = "$lines $fileName";
          break;

        case InputFlag.wordCount:
          int wordCountVal = await counters.wordCount(fileStream);
          outputString = "$wordCountVal $fileName";
          break;

        case InputFlag.charCount:
          int characterCountVal = await counters.characterCount(fileStream);
          outputString = "$characterCountVal $fileName";
          break;

        case InputFlag.showAll:
          List<int> allCountList = await counters.allCount(fileStream);
          int byteCountVal = allCountList[0];
          int lineCountVal = allCountList[1];
          int wordCountVal = allCountList[2];
          outputString = "$wordCountVal $lineCountVal $byteCountVal $fileName";
          break;

        default:
          break;
      }
      stdout.write(outputString);
      exit(0);
    } catch (e) {
      stdout.write(e.toString());
      exit(2);
    }
  }

}






