import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class CodeBlockView extends StatelessWidget {
  final String data;
  final String? language;
  const CodeBlockView(this.data, {this.language, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return HighlightView(
      data,
      backgroundColor: Colors.transparent,
      theme: monokaiSublimeTheme,
      language: language ?? 'txt',
    );
  }
}