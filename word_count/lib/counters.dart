import 'dart:convert';

class Counters {
  Future<int> lineCount(Stream stream) async {
    Stream<String> lines =
        stream.transform(utf8.decoder).transform(LineSplitter());
    int count = await lines.length;
    return count;
  }

  Future<int> byteCount(Stream stream) async {
    int count = 0;
    await for (final byte in stream) {
      count = byte.length + count;
    }
    return count;
  }

  Future<int> wordCount(Stream stream) async {
    Stream<String> lines =
        stream.transform(utf8.decoder).transform(LineSplitter());
    int wordCount = 0;
    await for (String line in lines) {
      wordCount = wordCount + _wordCountForLine(line);
    }
    return wordCount;
  }

  int _wordCountForLine(String line) {
    String stringWithAllWhiteSpaceRemoved =
        line.replaceAll(RegExp(r"\s\b|\b\s"), " ");
    List<String> splitString = stringWithAllWhiteSpaceRemoved.split(' ');
    splitString.removeWhere((element) => element == ' ' || element == '');
    return splitString.length;
  }

  Future<int> characterCount(Stream stream) async {
    int count = 0;
    Stream<String> textOutput = stream.transform(utf8.decoder);
    await for (String text in textOutput) {
      count = count + text.length;
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
    lineCount = lines.length;
    for (String line in lines) {
      wordCount = wordCount + _wordCountForLine(line);
    }
    return [byteCount, lineCount, wordCount];
  }
}